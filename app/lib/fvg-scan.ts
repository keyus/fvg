/**
 * Port of the daily FVG scan in `fvg_scanner.py`.
 *
 * Detection is the same three-candle gap (bullish `low[i-1] > high[i-3]`,
 * bearish `high[i-1] < low[i-3]`), then each gap gets a freshness verdict:
 * fresh (never traded back into), partial (touched but the edge held),
 * disrespected (a close or a candle body broke through the far edge).
 * Only fresh / partial gaps count, and only the one nearest to the current
 * price is reported per pair, exactly like the script's dedupe.
 */

import type { Candle } from "./market";

export type FvgDirection = "bullish" | "bearish";
export type FvgStatus = "fresh" | "partial" | "filled" | "disrespected";

export type FvgRules = {
  enabled: boolean;
  /** Daily candles to request (the script's LOOKBACK_DAYS). */
  lookbackDays: number;
  /** Only gaps formed within this many days (FVG_MAX_AGE_DAYS). */
  maxAgeDays: number;
  /** Smallest gap worth keeping, in percent (FVG_MIN_SIZE_PCT). */
  minGapPct: number;
  /** Spot only longs, so bearish gaps are dropped by default. */
  bullishOnly: boolean;
  /**
   * Chart only (the scan ignores it): how many gap boxes are drawn in total,
   * newest kept. `null` = no limit.
   */
  maxBoxes: number | null;
};

export type FvgHit = {
  type: FvgDirection;
  top: number;
  bottom: number;
  gapPct: number;
  /** Detection bar open time (ms). */
  formedAt: number;
  ageDays: number;
  status: FvgStatus;
  /** How deep price pushed into the gap, in percent of its height. */
  intrusionPct: number;
  /** Current price to the near edge of the gap, in percent. */
  distancePct: number;
};

const DAY_MS = 86_400_000;

type RawFvg = { type: FvgDirection; top: number; bottom: number; gapPct: number; index: number };

export function detectFvgs(candles: Candle[], minGapPct: number): RawFvg[] {
  const found: RawFvg[] = [];
  for (let i = 3; i < candles.length; i += 1) {
    const before = candles[i - 3];
    const after = candles[i - 1];

    if (after.l > before.h) {
      const top = after.l;
      const bottom = before.h;
      const gapPct = ((top - bottom) / bottom) * 100;
      if (gapPct >= minGapPct) found.push({ type: "bullish", top, bottom, gapPct, index: i });
    }

    if (after.h < before.l) {
      const top = before.l;
      const bottom = after.h;
      const gapPct = ((top - bottom) / bottom) * 100;
      if (gapPct >= minGapPct) found.push({ type: "bearish", top, bottom, gapPct, index: i });
    }
  }
  return found;
}

function checkFreshness(candles: Candle[], fvg: RawFvg) {
  const gapHeight = fvg.top - fvg.bottom;
  if (gapHeight <= 0) return { status: "filled" as FvgStatus, intrusionPct: 100 };

  const after = candles.slice(fvg.index + 1);
  if (after.length === 0) return { status: "fresh" as FvgStatus, intrusionPct: 0 };

  let entered = false;
  let maxIntrusion = 0;
  let closedThrough = false;
  let bodyThrough = false;

  for (const candle of after) {
    if (fvg.type === "bullish") {
      if (candle.l <= fvg.top) {
        entered = true;
        maxIntrusion = Math.max(maxIntrusion, fvg.top - candle.l);
      }
      if (candle.c < fvg.bottom) closedThrough = true;
      if (Math.min(candle.o, candle.c) < fvg.bottom) bodyThrough = true;
    } else {
      if (candle.h >= fvg.bottom) {
        entered = true;
        maxIntrusion = Math.max(maxIntrusion, candle.h - fvg.bottom);
      }
      if (candle.c > fvg.top) closedThrough = true;
      if (Math.max(candle.o, candle.c) > fvg.top) bodyThrough = true;
    }
  }

  const intrusionPct = Math.round((maxIntrusion / gapHeight) * 1000) / 10;
  if (!entered) return { status: "fresh" as FvgStatus, intrusionPct: 0 };
  if (closedThrough || bodyThrough) return { status: "disrespected" as FvgStatus, intrusionPct };
  return { status: "partial" as FvgStatus, intrusionPct };
}

/**
 * Scans one pair's daily candles and returns the most actionable qualifying
 * gap (nearest to the current price), or `null` when nothing qualifies.
 */
export function scanDailyFvgs(
  candles: Candle[],
  rules: FvgRules,
  now = Date.now(),
): FvgHit | null {
  if (candles.length < 5) return null;
  const current = candles[candles.length - 1].c;
  if (!Number.isFinite(current) || current <= 0) return null;

  const cutoff = now - rules.maxAgeDays * DAY_MS;
  const hits: FvgHit[] = [];

  for (const raw of detectFvgs(candles, rules.minGapPct)) {
    if (rules.bullishOnly && raw.type !== "bullish") continue;
    const formedAt = candles[raw.index].t;
    if (formedAt < cutoff) continue;

    const freshness = checkFreshness(candles, raw);
    if (freshness.status !== "fresh" && freshness.status !== "partial") continue;

    hits.push({
      type: raw.type,
      top: raw.top,
      bottom: raw.bottom,
      gapPct: Math.round(raw.gapPct * 1000) / 1000,
      formedAt,
      ageDays: Math.floor((now - formedAt) / DAY_MS),
      status: freshness.status,
      intrusionPct: freshness.intrusionPct,
      distancePct:
        raw.type === "bullish"
          ? ((current - raw.top) / current) * 100
          : ((raw.bottom - current) / current) * 100,
    });
  }

  if (hits.length === 0) return null;
  hits.sort((a, b) => Math.abs(a.distancePct) - Math.abs(b.distancePct));
  return hits[0];
}
