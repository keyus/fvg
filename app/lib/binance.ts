/**
 * Binance spot client (public REST, no key). All calls run in the browser, where
 * the API answers with permissive CORS headers.
 */

import type { Candle } from "./market";

const BASE = "https://api.binance.com";

export type BinancePair = {
  symbol: string;
  base: string;
  quote: string;
  price: number;
  changePct: number;
  volume24h: number;
  listedDays: number;
};

export const INTERVALS = ["1h", "4h", "1d"] as const;
export type Interval = (typeof INTERVALS)[number];

const DAY_MS = 86_400_000;

async function getJson<T>(path: string): Promise<T> {
  const response = await fetch(`${BASE}${path}`);
  if (!response.ok) throw new Error(`Binance ${path} -> ${response.status}`);
  return (await response.json()) as T;
}

/** Every tradable USDT spot symbol, without the metadata we have to fetch separately. */
export async function fetchSpotUsdtSymbols() {
  const info = await getJson<{
    symbols: Array<{
      symbol: string;
      baseAsset: string;
      quoteAsset: string;
      status: string;
      isSpotTradingAllowed: boolean;
    }>;
  }>("/api/v3/exchangeInfo?permissions=SPOT");

  const pairs = new Map<string, { base: string; quote: string }>();
  for (const item of info.symbols) {
    if (item.status !== "TRADING") continue;
    if (item.quoteAsset !== "USDT") continue;
    if (!item.isSpotTradingAllowed) continue;
    pairs.set(item.symbol, { base: item.baseAsset, quote: item.quoteAsset });
  }
  return pairs;
}

/** 24h price change and quote volume for every symbol, in one request. */
export async function fetchTickers24h() {
  const rows = await getJson<
    Array<{ symbol: string; lastPrice: string; priceChangePercent: string; quoteVolume: string }>
  >("/api/v3/ticker/24hr");

  const tickers = new Map<string, { price: number; changePct: number; volume24h: number }>();
  for (const row of rows) {
    tickers.set(row.symbol, {
      price: Number(row.lastPrice),
      changePct: Number(row.priceChangePercent),
      volume24h: Number(row.quoteVolume),
    });
  }
  return tickers;
}

/**
 * Age of a pair in days, taken from its first daily candle. Binance has no
 * listing date on the public API, and daily klines from `startTime=0` give the
 * first trading day.
 */
export async function fetchListingDays(symbol: string, now = Date.now()) {
  const rows = await getJson<unknown[][]>(
    `/api/v3/klines?symbol=${symbol}&interval=1d&limit=1&startTime=0`,
  );
  const first = rows[0]?.[0];
  if (typeof first !== "number") return 0;
  return Math.max(0, Math.floor((now - first) / DAY_MS));
}

export async function fetchKlines(symbol: string, interval: string, limit = 1000) {
  const rows = await getJson<unknown[][]>(
    `/api/v3/klines?symbol=${symbol}&interval=${interval}&limit=${Math.min(limit, 1000)}`,
  );
  return rows.map(
    (row): Candle => ({
      t: Number(row[0]),
      o: Number(row[1]),
      h: Number(row[2]),
      l: Number(row[3]),
      c: Number(row[4]),
      v: Number(row[5]),
    }),
  );
}

export async function fetchMarkPrice(symbol: string) {
  const row = await getJson<{ price: string }>(`/api/v3/ticker/price?symbol=${symbol}`);
  return Number(row.price);
}

/** Runs `worker` over `items` with a bounded number of parallel requests. */
export async function mapWithConcurrency<T, R>(
  items: T[],
  limit: number,
  worker: (item: T, index: number) => Promise<R>,
  onDone?: (done: number, total: number) => void,
) {
  const results = new Array<R>(items.length);
  let cursor = 0;
  let done = 0;
  const runners = Array.from({ length: Math.min(limit, items.length) }, async () => {
    while (cursor < items.length) {
      const index = cursor;
      cursor += 1;
      results[index] = await worker(items[index], index);
      done += 1;
      onDone?.(done, items.length);
    }
  });
  await Promise.all(runners);
  return results;
}

const KNOWN_COLORS: Record<string, string> = {
  BTC: "#f7931a",
  ETH: "#627eea",
  SOL: "#9945ff",
  BNB: "#f3ba2f",
  XRP: "#23292f",
  DOGE: "#c2a633",
  ADA: "#0f4fd8",
  AVAX: "#e84142",
  LINK: "#2a5ada",
  SUI: "#4da2ff",
  TON: "#0098ea",
  ARB: "#12aaff",
  OP: "#ff0420",
  APT: "#06b6d4",
  DOT: "#e6007a",
  TRX: "#eb0029",
  LTC: "#bfbbbb",
  NEAR: "#00c08b",
  ATOM: "#2e3148",
  UNI: "#ff007a",
};

/** Stable colour per base asset: a small palette for the majors, hash otherwise. */
export function pairColor(base: string) {
  const known = KNOWN_COLORS[base];
  if (known) return known;
  let hash = 0;
  for (let i = 0; i < base.length; i += 1) hash = (hash * 31 + base.charCodeAt(i)) % 360;
  return `hsl(${hash} 55% 48%)`;
}

export function pairGlyph(base: string) {
  if (base === "BTC") return "₿";
  if (base === "ETH") return "Ξ";
  if (base === "DOGE") return "Ð";
  return base.slice(0, 1).toUpperCase();
}
