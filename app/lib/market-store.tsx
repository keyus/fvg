import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from "react";
import { useSearchParams } from "react-router";
import { useNavigate } from "react-router";

import {
  INTERVALS,
  fetchKlines,
  fetchListingDays,
  fetchMarkPrice,
  fetchSpotUsdtSymbols,
  fetchTickers24h,
  mapWithConcurrency,
  pairColor,
  pairGlyph,
  type Interval,
} from "./binance";
import type { CmcResponse, CmcState } from "./cmc";
import { db, type KlineRow, type SettingRow } from "./db";
import { scanDailyFvgs, type FvgHit } from "./fvg-scan";
import { marketFromCandles, type Candle, type MarketData, type SymbolSpec } from "./market";
import {
  DEFAULT_PAIR_CONFIG,
  PARAM_KEYS,
  filterPairs,
  isDefaultPairConfig,
  isForcedBlacklisted,
  pairConfigSearch,
  parsePairConfig,
  parseStoredPairConfig,
  type PairConfig,
} from "./pair-config";

export type PairRow = {
  symbol: string;
  base: string;
  quote: string;
  price: number;
  changePct: number;
  volume24h: number;
  listedDays: number;
  color: string;
  glyph: string;
  /** Daily fair value gap found by the scan, when the FVG rule is on. */
  fvg?: FvgHit | null;
};

/** One "获取列表" run, kept as history in IndexedDB. */
export type Snapshot = {
  id?: number;
  createdAt: number;
  config: PairConfig;
  pairs: PairRow[];
};

export type Progress = { label: string; value: number } | null;

const KLINE_LIMIT = 1000;
/** Poll cadence for the symbol currently on screen. */
const AUTO_REFRESH_MS = 7_000;
/** A poll only asks for the tail: enough to refresh the forming candle. */
const POLL_LIMIT = 5;
/** IndexedDB writes are batched; live values go straight to the view. */
const PERSIST_INTERVAL_MS = 60_000;
const AGE_LOOKUP_CONCURRENCY = 8;
/** Daily candles are heavier than the age probe, but they are still cheap weight. */
const FVG_SCAN_CONCURRENCY = 12;

/** Chart period the app opens with (顶部的周期按钮). */
export const DEFAULT_INTERVAL: Interval = "1d";

type Store = {
  ready: boolean;
  snapshots: Snapshot[];
  activeSnapshot: Snapshot | null;
  activeId: number | null;
  /** Effective rules: scalars from the URL, black / white lists from IndexedDB. */
  config: PairConfig;
  /** CoinMarketCap snapshot of the pair on screen. */
  cmc: CmcState;
  /** All-time high / low of the pair on screen. */
  extremes: { ath: number; atl: number } | null;
  interval: Interval;
  symbol: string | null;
  market: MarketData | null;
  progress: Progress;
  message: string | null;
  loadingSymbol: boolean;
  updatedAt: number | null;
  selectSnapshot: (id: number) => void;
  removeSnapshot: (id: number) => Promise<void>;
  clearSnapshots: () => Promise<void>;
  fetchList: () => Promise<void>;
  savePairConfig: (config: PairConfig) => Promise<void>;
  loadSymbol: (symbol: string, forInterval?: Interval) => Promise<void>;
  refresh: () => Promise<void>;
  poll: () => Promise<void>;
  setInterval: (interval: Interval) => void;
  notify: (text: string) => void;
};

const MarketContext = createContext<Store | null>(null);

export function useMarket() {
  const store = useContext(MarketContext);
  if (!store) throw new Error("useMarket must be used inside <MarketProvider>");
  return store;
}

function specFromPair(pair: PairRow): SymbolSpec {
  return {
    symbol: pair.symbol,
    base: pair.base,
    name: pair.base,
    quote: pair.quote,
    exchange: "Binance",
    color: pair.color,
    glyph: pair.glyph,
    price: pair.price,
    driftPct: pair.changePct,
    volume24h: pair.volume24h,
    listedDays: pair.listedDays,
  };
}

/** Falls back to a synthetic row when a symbol is opened without a fetched list. */
function fallbackPair(symbol: string): PairRow {
  const base = symbol.endsWith("USDT") ? symbol.slice(0, -4) : symbol;
  return {
    symbol,
    base,
    quote: "USDT",
    price: 0,
    changePct: 0,
    volume24h: 0,
    listedDays: 0,
    color: pairColor(base),
    glyph: pairGlyph(base),
  };
}

export function MarketProvider({ children }: { children: ReactNode }) {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const [ready, setReady] = useState(false);
  const [snapshots, setSnapshots] = useState<Snapshot[]>([]);
  const [activeId, setActiveId] = useState<number | null>(null);
  const [interval, setIntervalState] = useState<Interval>(DEFAULT_INTERVAL);
  const [symbol, setSymbol] = useState<string | null>(null);
  const [market, setMarket] = useState<MarketData | null>(null);
  const [progress, setProgress] = useState<Progress>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [loadingSymbol, setLoadingSymbol] = useState(false);
  const [updatedAt, setUpdatedAt] = useState<number | null>(null);
  const [lists, setLists] = useState<{ blacklist: string[]; whitelist: string[] }>({
    blacklist: [],
    whitelist: [],
  });
  const [cmc, setCmc] = useState<CmcState>({ status: "idle" });
  /** All-time high / low of the pair, from Binance monthly candles. */
  const [extremes, setExtremes] = useState<{ ath: number; atl: number } | null>(null);

  const config = useMemo<PairConfig>(
    () => ({ ...parsePairConfig(searchParams), ...lists }),
    [searchParams, lists],
  );
  const configRef = useRef<PairConfig>(DEFAULT_PAIR_CONFIG);
  configRef.current = config;

  const notify = useCallback((text: string) => {
    setMessage(text);
    window.setTimeout(() => setMessage((current) => (current === text ? null : current)), 2600);
  }, []);

  const activeSnapshot = useMemo(
    () => snapshots.find((snapshot) => snapshot.id === activeId) ?? null,
    [snapshots, activeId],
  );
  const activePairs = activeSnapshot?.pairs ?? [];
  const pairsRef = useRef<PairRow[]>(activePairs);
  pairsRef.current = activePairs;
  // Refs keep the 7s poll stable: a changing dep would restart the timer on
  // every price tick and the poll would never fire.
  const symbolRef = useRef<string | null>(symbol);
  const intervalRef = useRef<Interval>(interval);
  const marketRef = useRef<MarketData | null>(market);
  const snapshotRef = useRef<Snapshot | null>(activeSnapshot);
  const activeIdRef = useRef<number | null>(activeId);
  const lastPersistRef = useRef(0);
  /** What the chart is currently showing, and the newest load request. */
  const shownRef = useRef<{ symbol: string; interval: Interval } | null>(null);
  const loadTokenRef = useRef(0);
  const cmcTokenRef = useRef(0);
  const extremesTokenRef = useRef(0);
  symbolRef.current = symbol;
  intervalRef.current = interval;
  marketRef.current = market;
  snapshotRef.current = activeSnapshot;
  activeIdRef.current = activeId;

  /* ---------------------------------------------------------------- boot */
  useEffect(() => {
    let cancelled = false;
    void (async () => {
      try {
        const [stored, setting, pairSetting] = await Promise.all([
          db.snapshots.toArray(),
          db.settings.get("interval"),
          db.settings.get("pairConfig"),
        ]);
        if (cancelled) return;
        const ordered = stored.sort((a, b) => b.createdAt - a.createdAt);
        setSnapshots(ordered);
        setActiveId(ordered[0]?.id ?? null);
        if (setting && (INTERVALS as readonly string[]).includes(setting.value)) {
          setIntervalState(setting.value as Interval);
        }
        // Black / white lists always come from IndexedDB; the rest of the rules
        // fall back to the saved config when the URL carries none.
        const storedConfig = parseStoredPairConfig(pairSetting?.value);
        setLists({ blacklist: storedConfig.blacklist, whitelist: storedConfig.whitelist });
        const urlHasConfig = new URLSearchParams(window.location.search).has(PARAM_KEYS.volume);
        if (!urlHasConfig && pairSetting?.value) {
          if (!isDefaultPairConfig(storedConfig)) {
            navigate({ search: pairConfigSearch(storedConfig) }, { replace: true });
          }
        }
      } finally {
        if (!cancelled) setReady(true);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [navigate]);

  /* ------------------------------------------------------------- klines */
  /** Fetches a full history and caches it per symbol+interval. */
  const loadKlines = useCallback(async (target: string, targetInterval: Interval) => {
    const candles = await fetchKlines(target, targetInterval, KLINE_LIMIT);
    const updated = Date.now();
    await db.klines.put({ symbol: target, interval: targetInterval, updatedAt: updated, candles });
    return { candles, updated };
  }, []);

  /**
   * Market cap / supply for the pair on screen, through our own server route:
   * the CoinMarketCap key never reaches the browser.
   */
  const loadCmc = useCallback(async (target: string) => {
    const base = target.endsWith("USDT") ? target.slice(0, -4) : target;
    const token = (cmcTokenRef.current += 1);
    setCmc({ status: "loading" });
    const ask = async (symbol: string) => {
      const response = await fetch(`/api/cmc?symbol=${encodeURIComponent(symbol)}`);
      return (await response.json()) as CmcResponse;
    };
    try {
      let payload = await ask(base);
      // Binance prefixes some pairs (1000PEPE, 1MBABYDOGE…) that CMC lists plain.
      if (!payload.ok && payload.reason === "not-found") {
        const stripped = base.replace(/^[0-9]+/, "");
        if (stripped && stripped !== base) payload = await ask(stripped);
      }
      if (token !== cmcTokenRef.current) return;
      setCmc(
        payload.ok
          ? { status: "ready", info: payload.info, project: payload.project }
          : { status: payload.reason === "not-found" ? "missing" : "error" },
      );
    } catch {
      if (token === cmcTokenRef.current) setCmc({ status: "error" });
    }
  }, []);

  /**
   * All-time high / low: CMC's public quotes endpoint has no ATH/ATL, but the
   * monthly candles cover a pair's whole Binance history in one request.
   */
  const loadExtremes = useCallback(async (target: string) => {
    const token = (extremesTokenRef.current += 1);
    try {
      const monthly = await fetchKlines(target, "1M", 1000);
      if (token !== extremesTokenRef.current || monthly.length === 0) return;
      let ath = Number.NEGATIVE_INFINITY;
      let atl = Number.POSITIVE_INFINITY;
      for (const candle of monthly) {
        ath = Math.max(ath, candle.h);
        atl = Math.min(atl, candle.l);
      }
      setExtremes({ ath, atl });
    } catch {
      if (token === extremesTokenRef.current) setExtremes(null);
    }
  }, []);

  const applyMarket = useCallback(
    (target: string, candles: Candle[], forInterval: Interval) => {
      if (candles.length === 0) return;
      const pair = pairsRef.current.find((row) => row.symbol === target) ?? fallbackPair(target);
      shownRef.current = { symbol: target, interval: forInterval };
      setMarket(marketFromCandles(specFromPair(pair), candles));
    },
    [],
  );

  const loadSymbol = useCallback(
    async (target: string, forInterval?: Interval) => {
      const upper = target.toUpperCase();
      // The interval is passed in, never read from a stale closure: switching
      // 1h -> 4h used to fire a second 1h request that landed after the 4h one.
      const wanted = forInterval ?? intervalRef.current;
      const token = (loadTokenRef.current += 1);
      setSymbol(upper);
      setLoadingSymbol(true);
      setExtremes(null);
      void loadCmc(upper);
      void loadExtremes(upper);
      // Never keep another pair's or another interval's candles on screen.
      if (shownRef.current?.symbol !== upper || shownRef.current?.interval !== wanted) {
        shownRef.current = null;
        setMarket(null);
      }
      try {
        // Warm start from the cached candles of *this* symbol+interval, then
        // refresh from Binance. Both are keyed, so a stale interval cannot leak in.
        const cached = await db.klines.get([upper, wanted]);
        if (token !== loadTokenRef.current) return;
        if (cached?.candles?.length) {
          applyMarket(upper, cached.candles, wanted);
          setUpdatedAt(cached.updatedAt);
        }
        const { candles, updated } = await loadKlines(upper, wanted);
        if (token !== loadTokenRef.current) return; // a newer request won
        applyMarket(upper, candles, wanted);
        setUpdatedAt(updated);
      } catch (error) {
        if (token === loadTokenRef.current) {
          console.error(error);
          notify(`拉取 ${upper} 失败`);
        }
      } finally {
        if (token === loadTokenRef.current) setLoadingSymbol(false);
      }
    },
    [applyMarket, loadCmc, loadExtremes, loadKlines, notify],
  );

  const refresh = useCallback(async () => {
    if (!symbol) {
      notify("请选择一个商品");
      return;
    }
    setLoadingSymbol(true);
    try {
      const wanted = intervalRef.current;
      void loadCmc(symbol);
      void loadExtremes(symbol);
      const [{ candles, updated }, price] = await Promise.all([
        loadKlines(symbol, wanted),
        fetchMarkPrice(symbol).catch(() => null),
      ]);
      applyMarket(symbol, candles, wanted);
      if (price !== null && activeSnapshot?.id !== undefined) {
        // Keep the watchlist price (and its IndexedDB row) in step with the mark price.
        const next = {
          ...activeSnapshot,
          pairs: activeSnapshot.pairs.map((row) =>
            row.symbol === symbol ? { ...row, price } : row,
          ),
        };
        setSnapshots((current) => current.map((item) => (item.id === next.id ? next : item)));
        await db.snapshots.put(next);
      }
      setUpdatedAt(updated);
    } catch (error) {
      console.error(error);
      notify(`更新 ${symbol} 失败`);
    } finally {
      setLoadingSymbol(false);
    }
  }, [activeSnapshot, applyMarket, loadCmc, loadExtremes, loadKlines, notify, symbol]);

  /** Keeps the watchlist row of the visible pair in step with the mark price. */
  const patchPairPrice = useCallback((target: string, price: number) => {
    setSnapshots((current) =>
      current.map((snapshot) =>
        snapshot.id === activeIdRef.current
          ? {
              ...snapshot,
              pairs: snapshot.pairs.map((row) => (row.symbol === target ? { ...row, price } : row)),
            }
          : snapshot,
      ),
    );
  }, []);

  /**
   * Light poll for the symbol on screen: asks for the last few candles only,
   * splices them over the cached series (replacing the forming candle) and
   * refreshes the mark price. Does nothing when no symbol is displayed.
   */
  const poll = useCallback(async () => {
    const target = symbolRef.current;
    if (!target) return;
    const currentInterval = intervalRef.current;
    try {
      const [tail, price] = await Promise.all([
        fetchKlines(target, currentInterval, POLL_LIMIT),
        fetchMarkPrice(target).catch(() => null),
      ]);
      const previous = marketRef.current;
      const shown = shownRef.current;
      // A poll that lands after a symbol/interval switch must not be applied.
      if (!previous || !shown || shown.symbol !== target || shown.interval !== currentInterval) return;
      if (previous.spec.symbol !== target || tail.length === 0) return;

      const byTime = new Map(previous.candles.map((candle) => [candle.t, candle]));
      for (const candle of tail) byTime.set(candle.t, candle);
      const candles = [...byTime.values()].sort((a, b) => a.t - b.t);
      const next = marketFromCandles(
        price !== null ? { ...previous.spec, price } : previous.spec,
        candles,
      );
      marketRef.current = next;
      const now = Date.now();
      setMarket(next);
      setUpdatedAt(now);
      if (price !== null) patchPairPrice(target, price);

      // Persisted on a slower cadence than the view: the polled candles and the
      // watchlist price.
      if (now - lastPersistRef.current >= PERSIST_INTERVAL_MS) {
        lastPersistRef.current = now;
        void db.klines.put({ symbol: target, interval: currentInterval, updatedAt: now, candles });
        const snapshot = snapshotRef.current;
        if (snapshot?.id !== undefined) void db.snapshots.put(snapshot);
      }
    } catch (error) {
      // A dropped poll is not worth interrupting the chart for.
      console.error("poll failed", error);
    }
  }, [patchPairPrice]);

  /* -------------------------------------------------------- auto refresh */
  useEffect(() => {
    if (!symbol) return;
    const timer = window.setInterval(() => {
      if (document.hidden) return;
      void poll();
    }, AUTO_REFRESH_MS);
    return () => window.clearInterval(timer);
  }, [poll, symbol]);

  /* ------------------------------------------------------------- actions */
  const fetchList = useCallback(async () => {
    const config = configRef.current;
    try {
      setProgress({ label: "读取 Binance 现货交易对", value: 0.04 });
      const [symbols, tickers] = await Promise.all([fetchSpotUsdtSymbols(), fetchTickers24h()]);

      setProgress({ label: "按成交量与名单筛选", value: 0.12 });
      const candidates: PairRow[] = [];
      for (const [pairSymbol, meta] of symbols) {
        const ticker = tickers.get(pairSymbol);
        if (!ticker) continue;
        candidates.push({
          symbol: pairSymbol,
          base: meta.base,
          quote: meta.quote,
          price: ticker.price,
          changePct: ticker.changePct,
          volume24h: ticker.volume24h,
          listedDays: 0,
          color: pairColor(meta.base),
          glyph: pairGlyph(meta.base),
        });
      }

      // Whitelisted pairs skip the thresholds, so they always get an age lookup.
      // The forced blacklist drops pairs before that lookup, saving the request.
      const whitelist = new Set(config.whitelist);
      const prefiltered = candidates.filter(
        (row) =>
          !isForcedBlacklisted(row) &&
          (whitelist.has(row.symbol) ||
            whitelist.has(row.base) ||
            row.volume24h >= config.minVolume),
      );

      setProgress({ label: "查询上线天数", value: 0.18 });
      const now = Date.now();
      const withAge = await mapWithConcurrency(
        prefiltered,
        AGE_LOOKUP_CONCURRENCY,
        async (row) => ({ ...row, listedDays: await fetchListingDays(row.symbol, now).catch(() => 0) }),
        (done, total) =>
          setProgress({ label: `查询上线天数 ${done}/${total}`, value: 0.18 + 0.4 * (done / total) }),
      );

      let pairs = filterPairs(withAge, config).sort((a, b) => b.volume24h - a.volume24h);

      // Daily FVG scan, same rules as fvg_scanner.py: 40 days of daily candles,
      // gaps formed in the last 15 days, and only ones price has not broken.
      if (config.fvg.enabled && pairs.length > 0) {
        const scanned = await mapWithConcurrency(
          pairs,
          FVG_SCAN_CONCURRENCY,
          async (row) => {
            const candles = await fetchKlines(row.symbol, "1d", config.fvg.lookbackDays + 10).catch(
              () => [] as Candle[],
            );
            return { ...row, fvg: candles.length ? scanDailyFvgs(candles, config.fvg, now) : null };
          },
          (done, total) =>
            setProgress({
              label: `扫描日线 FVG ${done}/${total}`,
              value: 0.6 + 0.36 * (done / total),
            }),
        );
        pairs = scanned
          .filter((row) => row.fvg)
          .sort((a, b) => Math.abs(a.fvg!.distancePct) - Math.abs(b.fvg!.distancePct));
      }

      const snapshot: Snapshot = { createdAt: Date.now(), config, pairs };
      const id = await db.snapshots.add(snapshot);

      setProgress({ label: "写入本地库", value: 0.98 });
      const stored = { ...snapshot, id };
      setSnapshots((current) => [stored, ...current]);
      setActiveId(stored.id ?? null);
      setProgress(null);
      notify(`获取完成，共 ${pairs.length} 个交易对`);
    } catch (error) {
      console.error(error);
      setProgress(null);
      notify("获取列表失败，请检查网络");
    }
  }, [notify]);

  /**
   * Persists the rules in IndexedDB and mirrors them into the URL. Stored as the
   * same query string the URL uses, so both paths share one parser.
   */
  const savePairConfig = useCallback(
    async (config: PairConfig) => {
      // The lists live only in IndexedDB; the URL keeps the small scalars.
      await db.settings.put({ key: "pairConfig", value: JSON.stringify(config) });
      setLists({ blacklist: config.blacklist, whitelist: config.whitelist });
      navigate({ search: pairConfigSearch(config) });
    },
    [navigate],
  );

  const selectSnapshot = useCallback((id: number) => setActiveId(id), []);

  const removeSnapshot = useCallback(
    async (id: number) => {
      await db.snapshots.delete(id);
      setSnapshots((current) => {
        const next = current.filter((snapshot) => snapshot.id !== id);
        setActiveId((active) => (active === id ? (next[0]?.id ?? null) : active));
        return next;
      });
    },
    [],
  );

  const clearSnapshots = useCallback(async () => {
    await db.snapshots.clear();
    setSnapshots([]);
    setActiveId(null);
  }, []);

  /**
   * Only records the choice: the chart route reloads when the interval changes,
   * which passes it explicitly instead of reading a stale closure.
   */
  const setIntervalAndReload = useCallback((next: Interval) => {
    setIntervalState(next);
    void db.settings.put({ key: "interval", value: next });
  }, []);

  const value: Store = {
    ready,
    snapshots,
    activeSnapshot,
    activeId,
    config,
    cmc,
    extremes,
    interval,
    symbol,
    market,
    progress,
    message,
    loadingSymbol,
    updatedAt,
    selectSnapshot,
    removeSnapshot,
    clearSnapshots,
    fetchList,
    savePairConfig,
    loadSymbol,
    refresh,
    poll,
    setInterval: setIntervalAndReload,
    notify,
  };

  return <MarketContext.Provider value={value}>{children}</MarketContext.Provider>;
}
