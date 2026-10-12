/**
 * Trading pair selection for the watchlist, driven by the "配置交易对" dialog.
 *
 * The selection lives in the URL search params, so it survives navigation
 * between symbols, is shareable, and lets the layout loader filter server side.
 */

import { type FvgRules } from "./fvg-scan";

/** Binance is the only supported source, the dialog shows it read only. */
export const DATA_SOURCE = "Binance";

/** 100万+ … 1000万+ (24h quote volume in USDT). */
export const VOLUME_STEPS = [
  1_000_000, 2_000_000, 3_000_000, 4_000_000, 5_000_000,
  6_000_000, 7_000_000, 8_000_000, 9_000_000, 10_000_000,
] as const;

/** 30天+ … 120天+ (days since listing). */
export const DAYS_STEPS = [30, 60, 90, 120] as const;

/**
 * Patterns that are always excluded, on top of whatever the user configures.
 * They come from the freqtrade `pair_blacklist` and are matched the same way
 * (regex against `BASE/QUOTE`), so `USDC/.*` drops USDC/USDT and so on.
 * Users cannot remove them from the dialog on purpose: the exclusion is forced.
 */
export const FORCED_BLACKLIST: readonly string[] = [
  "BNB/.*",
  "USDC/.*",
  "USD1/.*",
  "XAUT/.*",
  "XRP/.*",
  "DOGE/.*",
  "U/.*",
  "BUSD/.*",
  "USDP/.*",
  "USDS/.*",
  "USDT/.*",
  "TUSD/.*",
  "PAX/.*",
  "USDD/.*",
  "USDX/.*",
  "USDN/.*",
  "USDQ/.*",
  "USDZ/.*",
  "LTC/.*",
  "EUR/.*",
  "RLUSD/.*",
  "PAXG/.*",
] as const;

/** FVG scan options exposed in the dialog. */
export const FVG_LOOKBACK_STEPS = [20, 30, 40, 60] as const;
export const FVG_AGE_STEPS = [7, 15, 30] as const;
export const FVG_GAP_STEPS = [0.1, 0.3, 0.5, 1] as const;
/** How many gap boxes the chart draws at once. */
export const FVG_MAX_BOX_STEPS = [10, 20, 30, 50, 100] as const;

export type PairConfig = {
  minVolume: number;
  minDays: number;
  blacklist: string[];
  whitelist: string[];
  fvg: FvgRules;
};

export const DEFAULT_PAIR_CONFIG: PairConfig = {
  minVolume: 1_000_000,
  minDays: 30,
  blacklist: [],
  whitelist: [],
  // Defaults follow fvg_scanner.py: 40 days of daily candles, gaps formed in the
  // last 15 days, at least 0.3% wide, bullish only (spot goes long).
  fvg: {
    enabled: true,
    lookbackDays: 40,
    maxAgeDays: 15,
    minGapPct: 0.3,
    bullishOnly: true,
    maxBoxes: 20,
  },
};

export const PARAM_KEYS = {
  volume: "vol",
  days: "days",
  fvg: "fvg",
  fvgLookback: "fvgDays",
  fvgAge: "fvgAge",
  fvgGap: "fvgGap",
  fvgBull: "fvgBull",
  fvgMaxBoxes: "fvgMax",
} as const;

function pickStep(value: number, steps: readonly number[], fallback: number) {
  return steps.includes(value) ? value : fallback;
}

export function parsePairConfig(searchParams: URLSearchParams): PairConfig {
  const volume = Number(searchParams.get(PARAM_KEYS.volume));
  const days = Number(searchParams.get(PARAM_KEYS.days));
  const fallbackFvg = DEFAULT_PAIR_CONFIG.fvg;
  const fvgFlag = searchParams.get(PARAM_KEYS.fvg);
  const bullishFlag = searchParams.get(PARAM_KEYS.fvgBull);
  return {
    minVolume: pickStep(volume, VOLUME_STEPS, DEFAULT_PAIR_CONFIG.minVolume),
    minDays: pickStep(days, DAYS_STEPS, DEFAULT_PAIR_CONFIG.minDays),
    // The lists stay out of the URL (they can hold hundreds of patterns) and
    // come from IndexedDB instead; see `parseStoredPairConfig`.
    blacklist: [],
    whitelist: [],
    fvg: {
      enabled: fvgFlag === null ? fallbackFvg.enabled : fvgFlag !== "0",
      lookbackDays: pickStep(
        Number(searchParams.get(PARAM_KEYS.fvgLookback)),
        FVG_LOOKBACK_STEPS,
        fallbackFvg.lookbackDays,
      ),
      maxAgeDays: pickStep(
        Number(searchParams.get(PARAM_KEYS.fvgAge)),
        FVG_AGE_STEPS,
        fallbackFvg.maxAgeDays,
      ),
      minGapPct: pickStep(
        Number(searchParams.get(PARAM_KEYS.fvgGap)),
        FVG_GAP_STEPS,
        fallbackFvg.minGapPct,
      ),
      bullishOnly: bullishFlag === null ? fallbackFvg.bullishOnly : bullishFlag !== "0",
      maxBoxes: pickStep(
        Number(searchParams.get(PARAM_KEYS.fvgMaxBoxes)),
        FVG_MAX_BOX_STEPS,
        fallbackFvg.maxBoxes ?? 20,
      ),
    },
  };
}

/**
 * Only the small scalar rules go into the URL; the black / white lists live in
 * IndexedDB and are merged back in by the store.
 */
export function pairConfigSearch(config: PairConfig) {
  const params = new URLSearchParams();
  params.set(PARAM_KEYS.volume, String(config.minVolume));
  params.set(PARAM_KEYS.days, String(config.minDays));
  params.set(PARAM_KEYS.fvg, config.fvg.enabled ? "1" : "0");
  params.set(PARAM_KEYS.fvgLookback, String(config.fvg.lookbackDays));
  params.set(PARAM_KEYS.fvgAge, String(config.fvg.maxAgeDays));
  params.set(PARAM_KEYS.fvgGap, String(config.fvg.minGapPct));
  params.set(PARAM_KEYS.fvgBull, config.fvg.bullishOnly ? "1" : "0");
  params.set(PARAM_KEYS.fvgMaxBoxes, String(config.fvg.maxBoxes ?? 20));
  return `?${params.toString()}`;
}

/** The same rules without the lists, for persisting alongside them. */
export function withoutLists(config: PairConfig) {
  return pairConfigSearch({ ...config, blacklist: [], whitelist: [] });
}

/**
 * Reads the rules persisted in IndexedDB. They are stored as the same query
 * string the URL uses; a JSON row (written by an earlier build) is still read.
 */
export function parseStoredPairConfig(value: string | null | undefined): PairConfig {
  if (!value) return DEFAULT_PAIR_CONFIG;
  const trimmed = value.trim();
  if (trimmed.startsWith("{")) {
    try {
      const raw = JSON.parse(trimmed) as Partial<PairConfig>;
      const scalars = parsePairConfig(
        new URLSearchParams(
          withoutLists({
            minVolume: raw.minVolume ?? DEFAULT_PAIR_CONFIG.minVolume,
            minDays: raw.minDays ?? DEFAULT_PAIR_CONFIG.minDays,
            blacklist: [],
            whitelist: [],
            fvg: { ...DEFAULT_PAIR_CONFIG.fvg, ...(raw.fvg ?? {}) },
          }).slice(1),
        ),
      );
      return {
        ...scalars,
        blacklist: toPatternList(raw.blacklist),
        whitelist: toPatternList(raw.whitelist),
      };
    } catch {
      return DEFAULT_PAIR_CONFIG;
    }
  }
  // Earlier builds stored just the query string, without the lists.
  return parsePairConfig(new URLSearchParams(trimmed));
}

/** Keeps the list entries as the user typed them, trimmed, de-duplicated. */
function toPatternList(value: unknown) {
  if (!Array.isArray(value)) return [];
  const out: string[] = [];
  for (const entry of value) {
    if (typeof entry !== "string") continue;
    const pattern = entry.trim();
    if (pattern.length > 0 && !out.includes(pattern)) out.push(pattern);
  }
  return out;
}

export function isDefaultPairConfig(config: PairConfig) {
  return (
    config.minVolume === DEFAULT_PAIR_CONFIG.minVolume &&
    config.minDays === DEFAULT_PAIR_CONFIG.minDays &&
    config.blacklist.length === 0 &&
    config.whitelist.length === 0 &&
    config.fvg.enabled === DEFAULT_PAIR_CONFIG.fvg.enabled &&
    config.fvg.lookbackDays === DEFAULT_PAIR_CONFIG.fvg.lookbackDays &&
    config.fvg.maxAgeDays === DEFAULT_PAIR_CONFIG.fvg.maxAgeDays &&
    config.fvg.minGapPct === DEFAULT_PAIR_CONFIG.fvg.minGapPct &&
    config.fvg.bullishOnly === DEFAULT_PAIR_CONFIG.fvg.bullishOnly &&
    config.fvg.maxBoxes === DEFAULT_PAIR_CONFIG.fvg.maxBoxes
  );
}

/** The fields the rules look at; anything fetched from Binance satisfies this. */
export type FilterablePair = {
  symbol: string;
  base: string;
  quote?: string;
  volume24h: number;
  listedDays: number;
};

/**
 * Black / white list entries are patterns, not plain symbols: `RLUSD/.*`,
 * `BTC`, `.*UP$` all work. They are matched Python `re.search` style (substring
 * match) against the `BASE/QUOTE` pair, the raw symbol and the base asset, so
 * the freqtrade style patterns in `fvg_scanner_config.json` behave the same.
 */
export function compilePattern(pattern: string) {
  try {
    return new RegExp(pattern, "i");
  } catch {
    return null;
  }
}

export function isValidPattern(pattern: string) {
  return compilePattern(pattern) !== null;
}

export function matchesPattern(pattern: string, pair: FilterablePair) {
  const regex = compilePattern(pattern);
  if (!regex) return false;
  const quote = pair.quote ?? "USDT";
  return regex.test(`${pair.base}/${quote}`) || regex.test(pair.symbol) || regex.test(pair.base);
}

/**
 * Blacklist always wins. A non-empty whitelist means "only these", and the
 * whitelisted pairs skip the volume / age thresholds; otherwise a pair has to
 * clear both.
 */
export function matchesPairConfig(pair: FilterablePair, config: PairConfig) {
  if (isForcedBlacklisted(pair)) return false;
  if (config.blacklist.some((pattern) => matchesPattern(pattern, pair))) return false;
  if (config.whitelist.length > 0) {
    return config.whitelist.some((pattern) => matchesPattern(pattern, pair));
  }
  return pair.volume24h >= config.minVolume && pair.listedDays >= config.minDays;
}

/** Built-in exclusions; they win over the whitelist as well. */
export function isForcedBlacklisted(pair: FilterablePair) {
  return FORCED_BLACKLIST.some((pattern) => matchesPattern(pattern, pair));
}

export function filterPairs<T extends FilterablePair>(pairs: T[], config: PairConfig): T[] {
  return pairs.filter((pair) => matchesPairConfig(pair, config));
}

/** "100万+" style label for a volume threshold. */
export function formatVolumeLabel(volume: number) {
  return `${Math.round(volume / 10_000)}万+`;
}

export function formatVolume(volume: number) {
  if (volume >= 100_000_000) return `${(volume / 100_000_000).toFixed(2)}亿`;
  if (volume >= 10_000) return `${(volume / 10_000).toFixed(0)}万`;
  return String(volume);
}

export function formatDaysLabel(days: number) {
  return `${days}天+`;
}

