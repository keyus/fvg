/**
 * TypeScript port of `pine-script/SuperOrderBlock.pine`
 * ("Super OrderBlock / FVG / BoS Tools by makuchaku & eFe", Pine v5).
 *
 * The Pine inputs are mirrored 1:1 (same names, same defaults) and the bar by
 * bar logic is transcribed literally, including the `_controlBox` behaviour:
 * a box grows one bar at a time while price has not crossed one of its edges,
 * then freezes on the bar that crosses.
 */

import type { Candle } from "./market";

export type BorderStyle = "solid" | "dashed" | "dotted";
export type Dir = "bull" | "bear";
export type BoxKind = "OB" | "FVG" | "RJB" | "BoS";
export type MarkerShape = "diamond" | "triangleUp" | "triangleDown" | "xcross";

/** Mirrors Pine's `color.new(color, transparency)` input pair. */
export type IndicatorColor = { color: string; transparency: number };

export type IndicatorConfig = {
  /**
   * Not a Pine input: only boxes and pivot marks inside the newest this-many
   * bars are drawn, so a long series stays readable while scrolling back.
   * `null` renders the whole series.
   */
  renderBars: number | null;

  plotOB: boolean;
  obBullColor: IndicatorColor;
  obBearColor: IndicatorColor;
  obBoxBorder: BorderStyle;
  obBorderTransparency: number;
  obMaxBoxSet: number;
  filterMitOB: boolean;
  mitOBColor: IndicatorColor;

  plotFVG: boolean;
  plotStructureBreakingFVG: boolean;
  fvgBullColor: IndicatorColor;
  fvgBearColor: IndicatorColor;
  fvgStructBreakingColor: IndicatorColor;
  fvgBoxBorder: BorderStyle;
  fvgBorderTransparency: number;
  /**
   * Per-direction cap, as in the Pine input. FVG gaps use the total cap below
   * instead, so this stays `null` for them.
   */
  fvgMaxBoxSet: number | null;
  /**
   * Not a Pine input: how many fair value gap boxes are drawn in total, newest
   * kept. `null` draws every gap that has not been invalidated.
   */
  fvgMaxBoxes: number | null;
  /**
   * Not a Pine input: length of a fair value gap box, in bars, counted from the
   * middle candle of the pattern. Fixed length when `fvgLengthMode` is "fixed",
   * otherwise the cap for a box that stops early on a retest.
   */
  fvgLengthBars: number | null;
  /**
   * Not a Pine input: "fixed" gives every gap the same length; "retest" stops a
   * box before the candle that trades back into it (see `fvgStopGapBars`).
   */
  fvgLengthMode: "fixed" | "retest";
  /**
   * Not a Pine input: when price trades back into a gap, the box stops this
   * many bars before the candle that entered it, so a box never runs through
   * the candles to its right.
   */
  fvgStopGapBars: number;
  filterMitFVG: boolean;
  mitFVGColor: IndicatorColor;

  plotRJB: boolean;
  rjbBullColor: IndicatorColor;
  rjbBearColor: IndicatorColor;
  rjbBoxBorder: BorderStyle;
  rjbBorderTransparency: number;
  rjbMaxBoxSet: number;
  filterMitRJB: boolean;
  mitRJBColor: IndicatorColor;

  plotPVT: boolean;
  pivotLookup: number;
  pvtTopColor: IndicatorColor;
  pvtBottomColor: IndicatorColor;

  plotBOS: boolean;
  useHighLowForBullishBoS: boolean;
  useHighLowForBearishBoS: boolean;
  bosBoxFlag: boolean;
  bosBoxLength: number;
  bosBullColor: IndicatorColor;
  bosBearColor: IndicatorColor;
  bosBoxBorder: BorderStyle;
  bosBorderTransparency: number;
  bosMaxBoxSet: number;

  plotHVB: boolean;
  hvbBullColor: IndicatorColor;
  hvbBearColor: IndicatorColor;
  hvbEMAPeriod: number;
  hvbMultiplier: number;

  plotPPDD: boolean;
  ppddBullColor: IndicatorColor;
  ppddBearColor: IndicatorColor;

  plotOBFVG: boolean;
  obfvgBullColor: IndicatorColor;
  obfvgBearColor: IndicatorColor;

  plotLabelOB: boolean;
  obLabelColor: string;
  obLabelSize: number;
  plotLabelFVG: boolean;
  /** Not Pine inputs: Pine has one `fvgLabelColor`, the chart wants one per direction. */
  fvgBullLabelColor: string;
  fvgBearLabelColor: string;
  fvgLabelSize: number;
  plotLabelRJB: boolean;
  rjbLabelColor: string;
  rjbLabelSize: number;
  plotLabelBOS: boolean;
  bosLabelColor: string;
  bosLabelSize: number;
};

/** Defaults copied from the Pine `input.*` declarations. */
export const DEFAULT_INDICATOR_CONFIG: IndicatorConfig = {
  renderBars: 300,

  plotOB: false,
  obBullColor: { color: "#2196f3", transparency: 90 },
  obBearColor: { color: "#f44336", transparency: 90 },
  obBoxBorder: "dashed",
  obBorderTransparency: 80,
  obMaxBoxSet: 6,
  filterMitOB: false,
  mitOBColor: { color: "#808080", transparency: 90 },

  plotFVG: true,
  plotStructureBreakingFVG: false,
  fvgBullColor: { color: "#000000", transparency: 90 },
  fvgBearColor: { color: "#000000", transparency: 90 },
  fvgStructBreakingColor: { color: "#2196f3", transparency: 90 },
  fvgBoxBorder: "dotted",
  fvgBorderTransparency: 100,
  fvgMaxBoxSet: null,
  fvgMaxBoxes: 20,
  fvgLengthBars: 20,
  fvgLengthMode: "fixed",
  fvgStopGapBars: 3,
  filterMitFVG: false,
  mitFVGColor: { color: "#808080", transparency: 92 },

  plotRJB: false,
  rjbBullColor: { color: "#4caf50", transparency: 90 },
  rjbBearColor: { color: "#f44336", transparency: 90 },
  rjbBoxBorder: "solid",
  rjbBorderTransparency: 80,
  rjbMaxBoxSet: 10,
  filterMitRJB: false,
  mitRJBColor: { color: "#808080", transparency: 90 },

  plotPVT: true,
  pivotLookup: 5,
  pvtTopColor: { color: "#808080", transparency: 0 },
  pvtBottomColor: { color: "#808080", transparency: 0 },

  plotBOS: false,
  useHighLowForBullishBoS: false,
  useHighLowForBearishBoS: false,
  bosBoxFlag: false,
  bosBoxLength: 3,
  bosBullColor: { color: "#4caf50", transparency: 90 },
  bosBearColor: { color: "#f44336", transparency: 90 },
  bosBoxBorder: "solid",
  bosBorderTransparency: 80,
  bosMaxBoxSet: 10,

  plotHVB: false,
  hvbBullColor: { color: "#4caf50", transparency: 0 },
  hvbBearColor: { color: "#f44336", transparency: 0 },
  hvbEMAPeriod: 12,
  hvbMultiplier: 1.5,

  plotPPDD: false,
  ppddBullColor: { color: "#4caf50", transparency: 0 },
  ppddBearColor: { color: "#f44336", transparency: 0 },

  plotOBFVG: true,
  obfvgBullColor: { color: "#4caf50", transparency: 0 },
  obfvgBearColor: { color: "#f44336", transparency: 0 },

  plotLabelOB: true,
  obLabelColor: "#808080",
  obLabelSize: 9,
  plotLabelFVG: true,
  fvgBullLabelColor: "#808080",
  fvgBearLabelColor: "#808080",
  fvgLabelSize: 9,
  plotLabelRJB: true,
  rjbLabelColor: "#808080",
  rjbLabelSize: 9,
  plotLabelBOS: true,
  bosLabelColor: "#808080",
  bosLabelSize: 9,
};

export type IndicatorBox = {
  id: string;
  kind: BoxKind;
  dir: Dir;
  /** Bar indices. `right` equals `bars.length` while the box is still open. */
  left: number;
  right: number;
  top: number;
  bottom: number;
  mitigated: boolean;
  fill: string;
  border: string;
  borderStyle: BorderStyle;
  label: string;
  labelColor: string;
  labelSize: number;
};

export type IndicatorMarker = {
  id: string;
  index: number;
  price: number;
  shape: MarkerShape;
  above: boolean;
  color: string;
};

export type IndicatorLevel = { index: number; price: number };

export type IndicatorResult = {
  boxes: IndicatorBox[];
  markers: IndicatorMarker[];
  pivotHighs: IndicatorLevel[];
  pivotLows: IndicatorLevel[];
  /** Bars recoloured by the High Volume Bar module. */
  highVolumeBars: Map<number, string>;
  counts: Record<BoxKind, number>;
};

function withAlpha({ color, transparency }: IndicatorColor) {
  const alpha = Math.max(0, Math.min(1, (100 - transparency) / 100));
  const raw = color.replace("#", "");
  const hex = raw.length === 3 ? raw.split("").map((c) => c + c).join("") : raw;
  const value = Number.parseInt(hex, 16);
  return `rgba(${(value >> 16) & 255}, ${(value >> 8) & 255}, ${value & 255}, ${alpha})`;
}

/** Pine `ta.ema`, seeded with the SMA of the first `length` values. */
function ema(values: number[], length: number) {
  const out = new Array<number>(values.length).fill(Number.NaN);
  if (length < 1 || values.length < length) return out;
  const alpha = 2 / (length + 1);
  let seed = 0;
  for (let i = 0; i < length; i += 1) seed += values[i];
  let prev = seed / length;
  out[length - 1] = prev;
  for (let i = length; i < values.length; i += 1) {
    prev = alpha * values[i] + (1 - alpha) * prev;
    out[i] = prev;
  }
  return out;
}

/** Pine `ta.pivothigh`: strictly higher than the left window, leftmost wins ties. */
function pivotHighAt(candles: Candle[], index: number, lookback: number) {
  const value = candles[index].h;
  for (let i = index - lookback; i < index; i += 1) if (candles[i].h >= value) return null;
  for (let i = index + 1; i <= index + lookback; i += 1) {
    if (i >= candles.length || candles[i].h > value) return null;
  }
  return value;
}

function pivotLowAt(candles: Candle[], index: number, lookback: number) {
  const value = candles[index].l;
  for (let i = index - lookback; i < index; i += 1) if (candles[i].l <= value) return null;
  for (let i = index + 1; i <= index + lookback; i += 1) {
    if (i >= candles.length || candles[i].l < value) return null;
  }
  return value;
}

export function runSuperOrderBlock(
  candles: Candle[],
  config: IndicatorConfig = DEFAULT_INDICATOR_CONFIG,
): IndicatorResult {
  const bars = candles.length;
  if (bars < 3) {
    return {
      boxes: [],
      markers: [],
      pivotHighs: [],
      pivotLows: [],
      highVolumeBars: new Map(),
      counts: { OB: 0, FVG: 0, RJB: 0, BoS: 0 },
    };
  }

  const live: Record<BoxKind, Record<Dir, IndicatorBox[]>> = {
    OB: { bull: [], bear: [] },
    FVG: { bull: [], bear: [] },
    RJB: { bull: [], bear: [] },
    BoS: { bull: [], bear: [] },
  };
  const cap: Record<BoxKind, number | null> = {
    OB: config.obMaxBoxSet,
    FVG: config.fvgMaxBoxSet,
    RJB: config.rjbMaxBoxSet,
    BoS: config.bosMaxBoxSet,
  };
  const filterMit: Record<BoxKind, boolean> = {
    OB: config.filterMitOB,
    FVG: config.filterMitFVG,
    RJB: config.filterMitRJB,
    BoS: false,
  };
  const mitColor: Record<BoxKind, IndicatorColor> = {
    OB: config.mitOBColor,
    FVG: config.mitFVGColor,
    RJB: config.mitRJBColor,
    BoS: config.mitRJBColor,
  };
  const borderStyle: Record<BoxKind, BorderStyle> = {
    OB: config.obBoxBorder,
    FVG: config.fvgBoxBorder,
    RJB: config.rjbBoxBorder,
    BoS: config.bosBoxBorder,
  };
  const borderAlpha: Record<BoxKind, number> = {
    OB: config.obBorderTransparency,
    FVG: config.fvgBorderTransparency,
    RJB: config.rjbBorderTransparency,
    BoS: config.bosBorderTransparency,
  };
  const labels: Record<BoxKind, { on: boolean; color: string; size: number }> = {
    OB: { on: config.plotLabelOB, color: config.obLabelColor, size: config.obLabelSize },
    FVG: {
      on: config.plotLabelFVG,
      color: config.fvgBullLabelColor,
      size: config.fvgLabelSize,
    },
    RJB: { on: config.plotLabelRJB, color: config.rjbLabelColor, size: config.rjbLabelSize },
    BoS: { on: config.plotLabelBOS, color: config.bosLabelColor, size: config.bosLabelSize },
  };

  const markers: IndicatorMarker[] = [];
  const pivotHighs: IndicatorLevel[] = [];
  const pivotLows: IndicatorLevel[] = [];
  const highVolumeBars = new Map<number, string>();

  let seq = 0;
  const windowStart = config.renderBars === null ? 0 : Math.max(0, bars - config.renderBars);
  const pushBox = (
    kind: BoxKind,
    dir: Dir,
    created: number,
    geometry: { left: number; right: number; top: number; bottom: number },
    colors: { bg: IndicatorColor; border: IndicatorColor },
  ) => {
    if (created < windowStart) return;
    const label = labels[kind];
    const labelColor =
      kind === "FVG"
        ? dir === "bull"
          ? config.fvgBullLabelColor
          : config.fvgBearLabelColor
        : label.color;
    const box: IndicatorBox = {
      id: `${kind}-${dir}-${(seq += 1)}`,
      kind,
      dir,
      left: geometry.left,
      right: geometry.right,
      top: geometry.top,
      bottom: geometry.bottom,
      mitigated: false,
      fill: withAlpha(colors.bg),
      border: withAlpha(colors.border),
      borderStyle: borderStyle[kind],
      label: label.on ? `${kind}${dir === "bull" ? "+" : "-"}` : "",
      labelColor,
      labelSize: label.size,
    };
    const list = live[kind][dir];
    list.push(box);
    const limit = cap[kind];
    if (limit !== null && list.length > limit) list.shift();
  };

  const border = (kind: BoxKind, color: IndicatorColor): IndicatorColor => ({
    color: color.color,
    transparency: borderAlpha[kind],
  });

  const overshoot = (bar: Candle, box: IndicatorBox) =>
    (bar.h > box.bottom && bar.l < box.bottom) || (bar.h > box.top && bar.l < box.top);

  const controlBoxes = (kind: BoxKind, bar: Candle, index: number) => {
    for (const dir of ["bull", "bear"] as const) {
      const list = live[kind][dir];
      for (let cursor = list.length - 1; cursor >= 0; cursor -= 1) {
        const box = list[cursor];
        if (kind === "FVG") {
          // A gap whose far edge has been closed through by a candle body is
          // void: it is dropped from the chart and stops being tracked.
          const bodyBroken =
            box.dir === "bull"
              ? Math.min(bar.o, bar.c) < box.bottom
              : Math.max(bar.o, bar.c) > box.top;
          if (bodyBroken) {
            list.splice(cursor, 1);
            continue;
          }
          const entered = bar.h > box.bottom && bar.l < box.top;
          if (entered) {
            box.mitigated = true;
            if (filterMit.FVG) {
              box.fill = withAlpha(mitColor.FVG);
              box.border = withAlpha(mitColor.FVG);
            }
            if (config.fvgLengthMode === "retest") {
              // Keep clear of the candle that traded back into the gap.
              box.right = Math.max(
                box.left + 1,
                Math.min(box.right, index - config.fvgStopGapBars),
              );
              continue;
            }
          }
          if (box.right !== index) continue;
          const capped =
            config.fvgLengthBars !== null &&
            index + 1 > box.left + config.fvgLengthBars;
          if (!capped) box.right = index + 1;
          continue;
        }
        if (box.right !== index) continue;
        const crossed = overshoot(bar, box);
        if (kind === "BoS" && config.bosBoxFlag) {
          if (!crossed) box.right = index + config.bosBoxLength - 1;
          continue;
        }
        if (crossed) {
          box.mitigated = true;
          if (filterMit[kind]) {
            box.fill = withAlpha(mitColor[kind]);
            box.border = withAlpha(mitColor[kind]);
          }
          continue;
        }
        box.right = index + 1;
      }
    }
  };

  const volumes = candles.map((candle) => candle.v ?? 0);
  const volumeEma = config.plotHVB ? ema(volumes, config.hvbEMAPeriod) : [];
  const lookback = config.pivotLookup;

  const isUp = (index: number) => candles[index].c > candles[index].o;
  const isDown = (index: number) => candles[index].c < candles[index].o;
  const isObUp = (back: number, index: number) =>
    isDown(index - back - 1) && isUp(index - back) && candles[index - back].c > candles[index - back - 1].h;
  const isObDown = (back: number, index: number) =>
    isUp(index - back - 1) && isDown(index - back) && candles[index - back].c < candles[index - back - 1].l;

  // Step values of the last confirmed pivots, as seen at the current bar.
  let stepTop = Number.NaN;
  let stepBottom = Number.NaN;
  let prevStepTop = Number.NaN;
  let prevStepBottom = Number.NaN;

  for (let i = 0; i < bars; i += 1) {
    const bar = candles[i];
    prevStepTop = stepTop;
    prevStepBottom = stepBottom;

    const pivotIndex = i - lookback;
    if (pivotIndex >= lookback) {
      const high = pivotHighAt(candles, pivotIndex, lookback);
      if (high !== null) {
        // The pivot prices still feed BoS/PPDD, only the drawn marks are windowed.
        if (pivotIndex >= windowStart) pivotHighs.push({ index: pivotIndex, price: high });
        stepTop = high;
      }
      const low = pivotLowAt(candles, pivotIndex, lookback);
      if (low !== null) {
        if (pivotIndex >= windowStart) pivotLows.push({ index: pivotIndex, price: low });
        stepBottom = low;
      }
    }

    if (config.plotOB && i >= 3) {
      if (isObUp(1, i)) {
        pushBox(
          "OB",
          "bull",
          i,
          { left: i - 2, right: i, top: candles[i - 2].h, bottom: Math.min(candles[i - 2].l, candles[i - 1].l) },
          { bg: config.obBullColor, border: border("OB", config.obBullColor) },
        );
      } else if (isObDown(1, i)) {
        pushBox(
          "OB",
          "bear",
          i,
          { left: i - 2, right: i, top: Math.max(candles[i - 2].h, candles[i - 1].h), bottom: candles[i - 2].l },
          { bg: config.obBearColor, border: border("OB", config.obBearColor) },
        );
      }
    }

    if (config.plotRJB && i >= 3) {
      if (isObDown(1, i)) {
        const trapped = candles[i - 2];
        const signal = candles[i - 1];
        if (signal.h < trapped.c + 0.2 * (trapped.h - trapped.c)) {
          pushBox(
            "RJB",
            "bear",
            i,
            { left: i - 2, right: i, top: trapped.h, bottom: trapped.c },
            { bg: config.rjbBearColor, border: border("RJB", config.rjbBearColor) },
          );
        }
        if (signal.h > trapped.h) {
          pushBox(
            "RJB",
            "bear",
            i,
            { left: i - 1, right: i, top: signal.h, bottom: signal.o },
            { bg: config.rjbBearColor, border: border("RJB", config.rjbBearColor) },
          );
        }
      } else if (isObUp(1, i)) {
        const trapped = candles[i - 2];
        const signal = candles[i - 1];
        if (signal.l > trapped.c - 0.2 * (trapped.c - trapped.l)) {
          pushBox(
            "RJB",
            "bull",
            i,
            { left: i - 2, right: i, top: trapped.c, bottom: trapped.l },
            { bg: config.rjbBullColor, border: border("RJB", config.rjbBullColor) },
          );
        }
        if (signal.l < trapped.l) {
          pushBox(
            "RJB",
            "bull",
            i,
            { left: i - 1, right: i, top: signal.o, bottom: signal.l },
            { bg: config.rjbBullColor, border: border("RJB", config.rjbBullColor) },
          );
        }
      }
    }

    if (i >= 2 && (config.plotFVG || config.plotStructureBreakingFVG)) {
      if (candles[i].l > candles[i - 2].h) {
        const structural =
          config.plotStructureBreakingFVG &&
          candles[i - 1].c > stepTop &&
          candles[i - 1].l < stepTop &&
          candles[i - 2].h < stepTop &&
          candles[i].l > stepTop;
        if (structural || config.plotFVG) {
          const color = structural ? config.fvgStructBreakingColor : config.fvgBullColor;
          pushBox(
            "FVG",
            "bull",
            i,
            // The box hangs off the right side of the middle candle of the pattern.
            { left: i - 1, right: i, top: candles[i].l, bottom: candles[i - 2].h },
            { bg: color, border: border("FVG", color) },
          );
        }
      } else if (candles[i].h < candles[i - 2].l) {
        const structural =
          config.plotStructureBreakingFVG &&
          candles[i - 1].c < stepBottom &&
          candles[i - 1].h > stepBottom &&
          candles[i - 2].l > stepBottom &&
          candles[i].h < stepBottom;
        if (structural || config.plotFVG) {
          const color = structural ? config.fvgStructBreakingColor : config.fvgBearColor;
          pushBox(
            "FVG",
            "bear",
            i,
            { left: i - 1, right: i, top: candles[i - 2].l, bottom: candles[i].h },
            { bg: color, border: border("FVG", color) },
          );
        }
      }
    }

    if (config.plotBOS && i >= 1) {
      const bullBreak = config.useHighLowForBullishBoS ? bar.h : bar.c;
      const prevBullBreak = config.useHighLowForBullishBoS ? candles[i - 1].h : candles[i - 1].c;
      const bearBreak = config.useHighLowForBearishBoS ? bar.l : bar.c;
      const prevBearBreak = config.useHighLowForBearishBoS ? candles[i - 1].l : candles[i - 1].c;

      if (Number.isFinite(stepTop) && prevBullBreak <= stepTop && bullBreak > stepTop) {
        pushBox(
          "BoS",
          "bull",
          i,
          {
            left: i,
            right: config.bosBoxFlag ? i + config.bosBoxLength : i + 1,
            top: stepTop,
            bottom: Number.isFinite(stepBottom) ? stepBottom : bar.l,
          },
          { bg: config.bosBullColor, border: border("BoS", config.bosBullColor) },
        );
      }
      if (Number.isFinite(stepBottom) && prevBearBreak >= stepBottom && bearBreak < stepBottom) {
        pushBox(
          "BoS",
          "bear",
          i,
          {
            left: i,
            right: config.bosBoxFlag ? i + config.bosBoxLength : i + 1,
            top: Number.isFinite(stepTop) ? stepTop : bar.h,
            bottom: stepBottom,
          },
          { bg: config.bosBearColor, border: border("BoS", config.bosBearColor) },
        );
      }
    }

    if (config.plotPPDD && i >= 2) {
      const topHit =
        (Math.max(bar.h, candles[i - 1].h) > stepTop && bar.c < stepTop) ||
        (Math.max(bar.h, candles[i - 1].h) > prevStepTop && bar.c < prevStepTop);
      const bottomHit =
        (Math.min(bar.l, candles[i - 1].l) < stepBottom && bar.c > stepBottom) ||
        (Math.min(bar.l, candles[i - 1].l) < prevStepBottom && bar.c > prevStepBottom);
      const bearish = isObDown(0, i) && topHit;
      const bullish = isObUp(0, i) && bottomHit;
      const bearishWeak = !bearish && isUp(i - 1) && isDown(i) && bar.c < candles[i - 1].o && topHit;
      const bullishWeak = !bullish && isDown(i - 1) && isUp(i) && bar.c > candles[i - 1].o && bottomHit;

      if (bearish) {
        markers.push({
          id: `ppdd-bear-${i}`,
          index: i,
          price: bar.h,
          shape: "triangleDown",
          above: true,
          color: withAlpha(config.ppddBearColor),
        });
      }
      if (bullish) {
        markers.push({
          id: `ppdd-bull-${i}`,
          index: i,
          price: bar.l,
          shape: "triangleUp",
          above: false,
          color: withAlpha(config.ppddBullColor),
        });
      }
      if (bearishWeak) {
        markers.push({
          id: `ppdd1-bear-${i}`,
          index: i,
          price: bar.h,
          shape: "xcross",
          above: true,
          color: withAlpha(config.ppddBearColor),
        });
      }
      if (bullishWeak) {
        markers.push({
          id: `ppdd1-bull-${i}`,
          index: i,
          price: bar.l,
          shape: "xcross",
          above: false,
          color: withAlpha(config.ppddBullColor),
        });
      }
    }

    if (config.plotOBFVG && i >= 3 && candles[i].h < candles[i - 2].l && isObDown(1, i)) {
      markers.push({
        id: `obfvg-bear-${i}`,
        index: i,
        price: bar.h,
        shape: "diamond",
        above: true,
        color: withAlpha(config.obfvgBearColor),
      });
    }
    // The bullish half of the same block. `SuperOrderBlock.pine` in this repo
    // stops before its plotshape line, but the chart it has to match draws both.
    if (config.plotOBFVG && i >= 3 && candles[i].l > candles[i - 2].h && isObUp(1, i)) {
      markers.push({
        id: `obfvg-bull-${i}`,
        index: i,
        price: bar.l,
        shape: "diamond",
        above: false,
        color: withAlpha(config.obfvgBullColor),
      });
    }

    if (config.plotHVB) {
      const average = volumeEma[i];
      if (Number.isFinite(average) && volumes[i] > config.hvbMultiplier * average) {
        if (isUp(i)) highVolumeBars.set(i, withAlpha(config.hvbBullColor));
        else if (isDown(i)) highVolumeBars.set(i, withAlpha(config.hvbBearColor));
      }
    }

    if (config.plotOB) controlBoxes("OB", bar, i);
    if (config.plotFVG || config.plotStructureBreakingFVG) controlBoxes("FVG", bar, i);
    if (config.plotRJB) controlBoxes("RJB", bar, i);
    if (config.plotBOS) controlBoxes("BoS", bar, i);
  }

  // Gaps are capped in total (newest kept); the other modules keep Pine's
  // per-direction cap.
  const gaps = [...live.FVG.bull, ...live.FVG.bear].sort((a, b) => a.left - b.left);
  const keptGaps =
    config.fvgMaxBoxes === null ? gaps : gaps.slice(Math.max(0, gaps.length - config.fvgMaxBoxes));

  const boxes = [
    ...live.OB.bull,
    ...live.OB.bear,
    ...keptGaps,
    ...live.RJB.bull,
    ...live.RJB.bear,
    ...live.BoS.bull,
    ...live.BoS.bear,
  ];

  return {
    boxes,
    markers,
    pivotHighs,
    pivotLows,
    highVolumeBars,
    counts: {
      OB: live.OB.bull.length + live.OB.bear.length,
      FVG: keptGaps.length,
      RJB: live.RJB.bull.length + live.RJB.bear.length,
      BoS: live.BoS.bull.length + live.BoS.bear.length,
    },
  };
}
