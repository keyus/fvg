/**
 * Chart data model shared by the Binance loader, the indicator and the view.
 * All numbers come from real Binance klines; the helpers here only shape and
 * format them.
 */

export type Candle = { t: number; o: number; h: number; l: number; c: number; v: number };

export type SymbolSpec = {
  symbol: string;
  base: string;
  name: string;
  quote: string;
  exchange: string;
  color: string;
  glyph: string;
  price: number;
  driftPct: number;
  /** 24h quote volume in USDT. */
  volume24h: number;
  /** Days since the pair was listed. */
  listedDays: number;
};

export type Quote = {
  symbol: string;
  base: string;
  name: string;
  color: string;
  glyph: string;
  price: number;
  change: number;
  changePct: number;
};

export type MarketData = {
  spec: SymbolSpec;
  ticker: string;
  candles: Candle[];
  last: Candle;
  low: number;
  high: number;
  change: number;
  changePct: number;
  tick: number;
};

export const DEFAULT_SYMBOL = "BTCUSDT";

/**
 * Wraps a kline series into the shape the chart and the indicator expect.
 * `tick` is the smallest price step the pair quotes in, derived from the price
 * magnitude so the labels keep a sensible number of decimals.
 */
export function marketFromCandles(spec: SymbolSpec, candles: Candle[]): MarketData {
  const first = candles[0];
  const last = candles[candles.length - 1];
  let low = Number.POSITIVE_INFINITY;
  let high = Number.NEGATIVE_INFINITY;
  for (const candle of candles) {
    low = Math.min(low, candle.l);
    high = Math.max(high, candle.h);
  }
  const change = last.c - first.o;
  const decimals = priceDecimals(last.c);
  return {
    spec: { ...spec, price: last.c },
    ticker: spec.symbol,
    candles,
    last,
    low,
    high,
    change,
    changePct: first.o === 0 ? 0 : (change / first.o) * 100,
    tick: Number((10 ** -decimals).toFixed(decimals)),
  };
}

/* -------------------------------------------------------------------------- */
/* Clock                                                                      */
/* -------------------------------------------------------------------------- */

const MINUTE = 60_000;
const HOUR = 60 * MINUTE;

/** Asia/Shanghai is a fixed UTC+8 offset, so plain arithmetic stays deterministic. */
export const TZ_OFFSET = 8 * HOUR;
export const CANDLE_MS = 5 * MINUTE;
export const CANDLE_COUNT = 600;
/** Open time of the newest candle: 2026-10-12 03:15 (+08:00). */
const SESSION_END = Date.UTC(2026, 9, 11, 19, 15);

const WEEKDAYS = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];

const pad2 = (n: number) => String(n).padStart(2, "0");

function localClock(t: number) {
  const d = new Date(t + TZ_OFFSET);
  return {
    year: d.getUTCFullYear(),
    month: d.getUTCMonth() + 1,
    day: d.getUTCDate(),
    weekday: d.getUTCDay(),
    hour: d.getUTCHours(),
    minute: d.getUTCMinutes(),
  };
}

export function fmtClock(t: number) {
  const { hour, minute } = localClock(t);
  return `${pad2(hour)}:${pad2(minute)}`;
}

/** `周五 2026-10-02` (plus ` 08:00` for intraday charts). */
export function fmtFullStamp(t: number, withTime = true) {
  const { year, month, day, weekday, hour, minute } = localClock(t);
  const date = `${WEEKDAYS[weekday]} ${year}-${pad2(month)}-${pad2(day)}`;
  return withTime ? `${date} ${pad2(hour)}:${pad2(minute)}` : date;
}

export function isHourMark(t: number, every = 3) {
  const { hour, minute } = localClock(t);
  return minute === 0 && hour % every === 0;
}

export function isDayMark(t: number) {
  const { hour, minute } = localClock(t);
  return minute === 0 && hour === 0;
}

export function dayNumberOf(t: number) {
  return localClock(t).day;
}

/* -------------------------------------------------------------------------- */
/* Number formatting                                                          */
/* -------------------------------------------------------------------------- */

export function priceDecimals(value: number) {
  const v = Math.abs(value);
  if (v >= 100) return 2;
  if (v >= 1) return 3;
  return 5;
}

export function fmtPrice(value: number, decimals = priceDecimals(value)) {
  return value.toLocaleString("en-US", {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
}

/**
 * Watchlist price: fixed decimals with the trailing zeros trimmed, and no
 * thousands separator (`83906.08`, not `83,906.08`).
 */
export function fmtPriceCompact(value: number, decimals = priceDecimals(value)) {
  const text = value.toFixed(decimals);
  return text.includes(".") ? text.replace(/0+$/, "").replace(/\.$/, "") : text;
}

export function fmtDelta(value: number, decimals = priceDecimals(value)) {
  return fmtPrice(Math.abs(value), decimals);
}

export function fmtSigned(value: number, decimals = priceDecimals(value)) {
  return `${value < 0 ? "−" : "+"}${fmtDelta(value, decimals)}`;
}

export function fmtPct(value: number, decimals = 2) {
  return `${value.toFixed(decimals)}%`;
}
