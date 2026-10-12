import { useEffect, useMemo, useRef, useState } from "react";

import type {
  CandlestickData,
  IChartApi,
  ISeriesApi,
  ISeriesPrimitive,
  IPrimitivePaneRenderer,
  IPrimitivePaneView,
  MouseEventParams,
  SeriesAttachedParameter,
  SeriesType,
  Time,
  UTCTimestamp,
} from "lightweight-charts";

import {
  fmtFullStamp,
  fmtPrice,
  priceDecimals,
  TZ_OFFSET,
  type Candle,
  type MarketData,
} from "../lib/market";
import {
  DEFAULT_INDICATOR_CONFIG,
  runSuperOrderBlock,
  type BorderStyle,
  type IndicatorConfig,
  type IndicatorResult,
  type MarkerShape,
} from "../lib/super-order-block";

const UP = "#26a69a";
const DOWN = "#ef5350";
const GRID = "#e4e7ee";
const GRID_SOFT = "#eef1f6";
const AXIS_BORDER = "#e0e3eb";
const AXIS_TEXT = "#131722";
const BADGE = "#131722";
const CROSSHAIR = "#787b86";

/**
 * Input values of the TradingView chart this page mirrors 1:1 (the reference
 * screenshot shows green / red fair value gaps instead of the file's
 * `color.new(color.black, 90)` default).
 *
 * Everything not listed here keeps the Pine file's own default, and every
 * module whose `plot*` switch is `false` renders nothing at all.
 */
export const USER_INDICATOR_INPUTS: Partial<IndicatorConfig> = {
  fvgBullColor: { color: "#69E382", transparency: 86 },
  fvgBearColor: { color: "#DF484C", transparency: 86 },
  fvgBullLabelColor: "#69E382",
  fvgBearLabelColor: "#DF484C",
  /** Only the pivots and the fair value gaps are wanted on the chart. */
  plotOBFVG: false,
};

/** Pivot levels are marked with a fixed-length horizontal line starting at the pivot bar. */
export const PIVOT_LINE_PX = 20;

/** Bars shown when the chart opens, and the empty margin kept to their right. */
export const INITIAL_VISIBLE_BARS = 240;
export const RIGHT_OFFSET_BARS = 20;

/**
 * Lightweight Charts places times on a UTC scale, so shift entries by the chart
 * timezone offset to make the axis read as local wall clock.
 */
const toChartTime = (ms: number) => (Math.floor(ms / 1000) + TZ_OFFSET / 1000) as UTCTimestamp;

type BoxShape = {
  id: string;
  leftTime: number;
  /** `null` while the box is still open: use `rightBarsAhead` instead. */
  rightTime: number | null;
  /**
   * Bars past the newest candle an open box still has to run, so a gap keeps
   * its full length even though the candles there have not printed yet.
   */
  rightBarsAhead: number;
  /** Shifts the left edge by a fraction of a bar (FVG boxes start after the middle candle). */
  leftBarOffset: number;
  top: number;
  bottom: number;
  fill: string;
  border: string;
  borderStyle: BorderStyle;
  label: string;
  labelColor: string;
  labelSize: number;
  /** Fair value gaps right-align their text vertically centred, other modules keep Pine's bottom-right. */
  labelAlign: "right" | "bottomRight";
};

type ShapeMarker = {
  id: string;
  time: number;
  price: number;
  shape: MarkerShape;
  above: boolean;
  color: string;
};

/** One pivot level, drawn as a fixed-length horizontal line. */
type PivotMark = { time: number; price: number; color: string };

const DASH: Record<BorderStyle, number[]> = {
  solid: [],
  dashed: [6, 4],
  dotted: [1, 3],
};

/**
 * Lightweight Charts has no box or shape drawing API, so the indicator output is
 * painted on the pane canvas: boxes in the `bottom` layer (candles stay on top)
 * and shape markers in the `top` layer.
 */
class IndicatorPrimitive implements ISeriesPrimitive<Time> {
  private _chart: IChartApi | null = null;
  private _series: ISeriesApi<SeriesType, Time> | null = null;
  private _requestUpdate: (() => void) | null = null;
  private _boxes: BoxShape[] = [];
  private _markers: ShapeMarker[] = [];
  private _pivots: PivotMark[] = [];
  private _lastBarTime: number | null = null;

  setShapes(
    boxes: BoxShape[],
    markers: ShapeMarker[],
    pivots: PivotMark[],
    lastBarTime: number | null,
  ) {
    this._boxes = boxes;
    this._markers = markers;
    this._pivots = pivots;
    this._lastBarTime = lastBarTime;
    this._requestUpdate?.();
  }

  attached({ chart, series, requestUpdate }: SeriesAttachedParameter<Time, SeriesType>) {
    this._chart = chart as IChartApi;
    this._series = series;
    this._requestUpdate = requestUpdate;
  }

  detached() {
    this._chart = null;
    this._series = null;
    this._requestUpdate = null;
  }

  updateAllViews() {}

  paneViews(): readonly IPrimitivePaneView[] {
    return [this._boxView, this._pivotView, this._markerView];
  }

  /** Horizontal bounds of a box, clamped to the pane when the box is still open. */
  private _span(box: BoxShape, paneWidth: number, barWidth: number) {
    const timeScale = this._chart!.timeScale();
    const visible = timeScale.getVisibleRange();
    const visibleFrom = visible ? Number(visible.from) : null;
    const visibleTo = visible ? Number(visible.to) : null;

    let x1: number | null = timeScale.timeToCoordinate(box.leftTime as UTCTimestamp);
    if (x1 === null) {
      if (visibleFrom === null || box.leftTime >= visibleFrom) return null;
      x1 = 0;
    }
    x1 += box.leftBarOffset * barWidth;

    let x2 = paneWidth;
    if (box.rightTime !== null) {
      const right = timeScale.timeToCoordinate(box.rightTime as UTCTimestamp);
      if (right === null) {
        if (visibleTo === null || box.rightTime <= visibleTo) return null;
        x2 = paneWidth;
      } else {
        x2 = Math.min(right, paneWidth);
      }
    } else {
      // Still-open box: run it out to its full length, into the empty area on
      // the right where the candles have not printed yet.
      const last = this._lastBarTime === null
        ? null
        : timeScale.timeToCoordinate(this._lastBarTime as UTCTimestamp);
      if (last !== null) x2 = last + Math.max(1, box.rightBarsAhead) * barWidth;
    }

    const width = x2 - x1;
    return width > 1 ? { x1, x2, width } : null;
  }

  private _boxView: IPrimitivePaneView = {
    zOrder: () => "bottom",
    renderer: (): IPrimitivePaneRenderer => ({
      draw: (target) => {
        const series = this._series;
        if (!series || !this._chart || this._boxes.length === 0) return;

        target.useMediaCoordinateSpace(({ context: ctx, mediaSize }) => {
          const barWidth = this._chart!.timeScale().options().barSpacing;
          for (const box of this._boxes) {
            const span = this._span(box, mediaSize.width, barWidth);
            if (!span) continue;
            const yTop = series.priceToCoordinate(box.top);
            const yBottom = series.priceToCoordinate(box.bottom);
            if (yTop === null || yBottom === null) continue;

            const top = Math.min(yTop, yBottom);
            const height = Math.max(1, Math.abs(yBottom - yTop));

            ctx.fillStyle = box.fill;
            ctx.fillRect(span.x1, top, span.width, height);
            ctx.save();
            ctx.setLineDash(DASH[box.borderStyle]);
            ctx.strokeStyle = box.border;
            ctx.lineWidth = 1;
            ctx.strokeRect(span.x1 + 0.5, top + 0.5, span.width - 1, height - 1);
            ctx.restore();

            // Labels stay readable on thin gaps too: the text overflows the box
            // instead of being hidden, which is how the reference chart draws it.
            if (box.label) {
              ctx.font = `${box.labelSize}px Inter, system-ui, sans-serif`;
              ctx.fillStyle = box.labelColor;
              if (box.labelAlign === "right") {
                // Right end of the box, vertically centred; kept on screen when
                // the box itself runs past the right edge of the pane.
                ctx.textAlign = "right";
                ctx.textBaseline = "middle";
                ctx.fillText(
                  box.label,
                  Math.min(span.x2 - 4, mediaSize.width - 4),
                  top + height / 2,
                );
              } else {
                ctx.textAlign = "right";
                ctx.textBaseline = "bottom";
                ctx.fillText(box.label, span.x2 - 2, top + height - 2);
              }
            }
          }
        });
      },
    }),
  };

  private _pivotView: IPrimitivePaneView = {
    zOrder: () => "normal",
    renderer: (): IPrimitivePaneRenderer => ({
      draw: (target) => {
        const series = this._series;
        if (!series || !this._chart || this._pivots.length === 0) return;
        const timeScale = this._chart.timeScale();

        target.useMediaCoordinateSpace(({ context: ctx, mediaSize }) => {
          ctx.lineWidth = 1;
          for (const pivot of this._pivots) {
            const x = timeScale.timeToCoordinate(pivot.time as UTCTimestamp);
            if (x === null) continue;
            const y = series.priceToCoordinate(pivot.price);
            if (y === null) continue;
            ctx.strokeStyle = pivot.color;
            ctx.beginPath();
            ctx.moveTo(x, y);
            ctx.lineTo(Math.min(x + PIVOT_LINE_PX, mediaSize.width), y);
            ctx.stroke();
          }
        });
      },
    }),
  };

  private _markerView: IPrimitivePaneView = {
    zOrder: () => "top",
    renderer: (): IPrimitivePaneRenderer => ({
      draw: (target) => {
        const series = this._series;
        if (!series || !this._chart || this._markers.length === 0) return;

        target.useMediaCoordinateSpace(({ context: ctx }) => {
          for (const marker of this._markers) {
            const x = this._chart!.timeScale().timeToCoordinate(marker.time as UTCTimestamp);
            const y = series.priceToCoordinate(marker.price);
            if (x === null || y === null) continue;
            const cy = marker.above ? y - 10 : y + 10;
            const r = 4.5;

            ctx.fillStyle = marker.color;
            ctx.strokeStyle = marker.color;
            ctx.lineWidth = 1.4;
            ctx.beginPath();
            if (marker.shape === "diamond") {
              ctx.moveTo(x, cy - r);
              ctx.lineTo(x + r, cy);
              ctx.lineTo(x, cy + r);
              ctx.lineTo(x - r, cy);
              ctx.closePath();
              ctx.fill();
            } else if (marker.shape === "triangleUp") {
              ctx.moveTo(x, cy - r);
              ctx.lineTo(x + r, cy + r);
              ctx.lineTo(x - r, cy + r);
              ctx.closePath();
              ctx.fill();
            } else if (marker.shape === "triangleDown") {
              ctx.moveTo(x, cy + r);
              ctx.lineTo(x + r, cy - r);
              ctx.lineTo(x - r, cy - r);
              ctx.closePath();
              ctx.fill();
            } else {
              ctx.moveTo(x - r, cy - r);
              ctx.lineTo(x + r, cy + r);
              ctx.moveTo(x + r, cy - r);
              ctx.lineTo(x - r, cy + r);
              ctx.stroke();
            }
          }
        });
      },
    }),
  };
}

type ChartApi = {
  chart: IChartApi;
  series: ISeriesApi<"Candlestick", Time>;
  primitive: IndicatorPrimitive;
};

function pivotMarks(
  market: MarketData,
  levels: IndicatorResult["pivotHighs"],
  color: string,
): PivotMark[] {
  return levels.map((level) => ({
    time: Number(toChartTime(market.candles[level.index].t)),
    price: level.price,
    color,
  }));
}

function buildShapes(market: MarketData, indicator: IndicatorResult, config: IndicatorConfig) {
  const bars = market.candles.length;
  const boxes: BoxShape[] = indicator.boxes.map((box) => {
    const open = box.right >= bars;
    // A gap that is still growing is drawn to its full length, even though the
    // candles it would reach have not printed yet.
    const target =
      box.kind === "FVG" && config.fvgLengthBars !== null
        ? box.left + config.fvgLengthBars
        : bars;
    return {
      id: box.id,
      leftTime: Number(toChartTime(market.candles[Math.max(0, box.left)].t)),
      rightTime: open ? null : Number(toChartTime(market.candles[box.right].t)),
      rightBarsAhead: open ? Math.max(1, target - (bars - 1)) : 0,
      leftBarOffset: box.kind === "FVG" ? 0.5 : 0,
      top: box.top,
      bottom: box.bottom,
      fill: box.fill,
      border: box.border,
      borderStyle: box.borderStyle,
      label: box.label,
      labelColor: box.labelColor,
      labelSize: box.labelSize,
      labelAlign: box.kind === "FVG" ? "right" : "bottomRight",
    };
  });

  const markers: ShapeMarker[] = indicator.markers.map((marker) => ({
    id: marker.id,
    time: Number(toChartTime(market.candles[marker.index].t)),
    price: marker.price,
    shape: marker.shape,
    above: marker.above,
    color: marker.color,
  }));

  return { boxes, markers };
}

function applyMarket(api: ChartApi, market: MarketData, indicator: IndicatorResult, config: IndicatorConfig) {
  const decimals = priceDecimals(market.spec.price);
  const minMove = Number((10 ** -decimals).toFixed(decimals));

  const bars: CandlestickData<Time>[] = market.candles.map((candle, index) => {
    const row: CandlestickData<Time> = {
      time: toChartTime(candle.t),
      open: candle.o,
      high: candle.h,
      low: candle.l,
      close: candle.c,
    };
    const volumeColor = indicator.highVolumeBars.get(index);
    if (volumeColor) {
      row.color = volumeColor;
      row.borderColor = volumeColor;
      row.wickColor = volumeColor;
    }
    return row;
  });

  api.series.applyOptions({ priceFormat: { type: "price", precision: decimals, minMove } });
  api.series.setData(bars);
  applyIndicatorShapes(api, market, indicator, config);

  api.chart.applyOptions({
    localization: { priceFormatter: (price: number) => fmtPrice(price, decimals) },
  });
  // Open on the newest bars, with the empty margin the trailing gaps run into.
  const total = market.candles.length;
  const visible = Math.min(total, INITIAL_VISIBLE_BARS);
  api.chart.timeScale().setVisibleLogicalRange({
    from: total - visible,
    to: total - 1 + RIGHT_OFFSET_BARS,
  });
}

/** Boxes, pivots and price format: everything that follows the candle data. */
function applyIndicatorShapes(
  api: ChartApi,
  market: MarketData,
  indicator: IndicatorResult,
  config: IndicatorConfig,
) {
  const { boxes, markers } = buildShapes(market, indicator, config);
  api.primitive.setShapes(
    boxes,
    markers,
    config.plotPVT
      ? [
          ...pivotMarks(market, indicator.pivotHighs, rgba(config.pvtTopColor)),
          ...pivotMarks(market, indicator.pivotLows, rgba(config.pvtBottomColor)),
        ]
      : [],
    Number(toChartTime(market.candles[market.candles.length - 1].t)),
  );
}

/** Bars the chart already draws, used to work out what a poll has to touch. */
function firstStaleIndex(previous: Candle[], next: Candle[]) {
  if (previous.length === 0) return 0;
  const previousLast = previous[previous.length - 1];
  const start = next.findIndex((candle) => candle.t === previousLast.t);
  // The tail moved out of view (symbol switch, gap in the data): redraw.
  if (start < 0) return 0;
  for (let i = 0; i < start; i += 1) {
    const before = previous[i];
    const after = next[i];
    if (!before || before.t !== after.t || before.c !== after.c) return 0;
  }
  return start;
}

/**
 * Applies a poll: only the bars from `from` on are pushed to the series, so the
 * forming candle is replaced in place instead of the whole history reloading.
 */
function applyTail(api: ChartApi, market: MarketData, from: number, config: IndicatorConfig) {
  const indicator = runSuperOrderBlock(market.candles, config);
  for (let i = from; i < market.candles.length; i += 1) {
    const candle = market.candles[i];
    const row: CandlestickData<Time> = {
      time: toChartTime(candle.t),
      open: candle.o,
      high: candle.h,
      low: candle.l,
      close: candle.c,
    };
    const volumeColor = indicator.highVolumeBars.get(i);
    if (volumeColor) {
      row.color = volumeColor;
      row.borderColor = volumeColor;
      row.wickColor = volumeColor;
    }
    api.series.update(row);
  }
  applyIndicatorShapes(api, market, indicator, config);
}

function rgba({ color, transparency }: { color: string; transparency: number }) {
  const alpha = Math.max(0, Math.min(1, (100 - transparency) / 100));
  const raw = color.replace("#", "");
  const hex = raw.length === 3 ? raw.split("").map((c) => c + c).join("") : raw;
  const value = Number.parseInt(hex, 16);
  return `rgba(${(value >> 16) & 255}, ${(value >> 8) & 255}, ${value & 255}, ${alpha})`;
}

export function CandleChart({
  data,
  interval,
  config,
  onCrosshairChange,
}: {
  data: MarketData;
  /** Chart period, part of the identity of the series the chart draws. */
  interval: string;
  config?: Partial<IndicatorConfig>;
  onCrosshairChange?: (candle: Candle | null) => void;
}) {
  const hostRef = useRef<HTMLDivElement | null>(null);
  const apiRef = useRef<ChartApi | null>(null);
  /** What the canvas currently shows, so a poll can be applied as a patch. */
  const renderedRef = useRef<{
    key: string;
    configKey: string;
    candles: Candle[];
  } | null>(null);
  const dataRef = useRef(data);
  const indicatorRef = useRef<IndicatorResult | null>(null);
  const configRef = useRef<IndicatorConfig>(DEFAULT_INDICATOR_CONFIG);
  /** Read by the crosshair time formatter, which is created once per chart. */
  const intervalRef = useRef(interval);
  intervalRef.current = interval;
  const candlesByTime = useRef(new Map<number, Candle>());
  const lastHovered = useRef<number | null>(null);
  const crosshairRef = useRef(onCrosshairChange);
  const [failed, setFailed] = useState(false);

  const indicatorConfig = useMemo<IndicatorConfig>(
    () => ({ ...DEFAULT_INDICATOR_CONFIG, ...USER_INDICATOR_INPUTS, ...config }),
    [config],
  );
  const indicator = useMemo(
    () => runSuperOrderBlock(data.candles, indicatorConfig),
    [data.candles, indicatorConfig],
  );
  const configKey = JSON.stringify(indicatorConfig);

  dataRef.current = data;
  indicatorRef.current = indicator;
  configRef.current = indicatorConfig;
  crosshairRef.current = onCrosshairChange;

  useEffect(() => {
    const host = hostRef.current;
    if (!host) return;

    let disposed = false;
    let api: ChartApi | null = null;

    const handleCrosshair = (param: MouseEventParams<Time>) => {
      const key = param.time === undefined ? null : Number(param.time);
      if (key === lastHovered.current) return;
      lastHovered.current = key;
      crosshairRef.current?.(key === null ? null : (candlesByTime.current.get(key) ?? null));
    };

    void (async () => {
      try {
        const lwc = await import("lightweight-charts");
        if (disposed) return;

        const chart = lwc.createChart(host, {
          autoSize: true,
          layout: {
            background: { color: "#ffffff" },
            textColor: AXIS_TEXT,
            fontSize: 12,
            fontFamily: "Inter, system-ui, sans-serif",
            attributionLogo: true,
          },
          grid: {
            vertLines: { color: GRID_SOFT, style: lwc.LineStyle.Dotted },
            horzLines: { color: GRID, style: lwc.LineStyle.Dashed },
          },
          crosshair: {
            mode: lwc.CrosshairMode.Normal,
            vertLine: {
              color: CROSSHAIR,
              width: 1,
              style: lwc.LineStyle.LargeDashed,
              labelBackgroundColor: BADGE,
            },
            horzLine: {
              color: CROSSHAIR,
              width: 1,
              style: lwc.LineStyle.LargeDashed,
              labelBackgroundColor: BADGE,
            },
          },
          rightPriceScale: {
            borderColor: AXIS_BORDER,
            scaleMargins: { top: 0.04, bottom: 0.06 },
            entireTextOnly: true,
          },
          localization: {
            // The built-in label mixes in CJK month names ("14 9月 '26"), whose
            // canvas width measurement does not match the drawn text, leaving the
            // crosshair badge too wide with the text stuck to its left edge.
            timeFormatter: (time: Time) => {
              // `周五 2026-10-02`, or with the clock on intraday charts.
              const real = (Number(time) - TZ_OFFSET / 1000) * 1000;
              return fmtFullStamp(real, intervalRef.current !== "1d");
            },
          },
          timeScale: {
            timeVisible: true,
            secondsVisible: false,
            borderColor: AXIS_BORDER,
            // Room on the right for gaps that still have bars left to run.
            rightOffset: RIGHT_OFFSET_BARS,
            barSpacing: 6,
            minBarSpacing: 1,
            lockVisibleTimeRangeOnResize: true,
          },
        });

        const series = chart.addSeries(lwc.CandlestickSeries, {
          upColor: UP,
          downColor: DOWN,
          borderVisible: false,
          wickUpColor: UP,
          wickDownColor: DOWN,
          priceLineVisible: true,
          priceLineStyle: lwc.LineStyle.Dashed,
          lastValueVisible: true,
        });

        const primitive = new IndicatorPrimitive();
        series.attachPrimitive(primitive);

        api = { chart, series, primitive };
        apiRef.current = api;
        applyMarket(api, dataRef.current, indicatorRef.current!, configRef.current);
        lastHovered.current = null;
        crosshairRef.current?.(null);
        chart.subscribeCrosshairMove(handleCrosshair);
      } catch (error) {
        if (!disposed) {
          console.error("lightweight-charts failed to start", error);
          setFailed(true);
        }
      }
    })();

    return () => {
      disposed = true;
      if (api) {
        api.chart.unsubscribeCrosshairMove(handleCrosshair);
        api.chart.remove();
      }
      apiRef.current = null;
    };
  }, []);

  // Switching symbol reuses the same chart; a poll only patches the tail, so the
  // view (zoom, scroll, crosshair) is never reset while the price ticks.
  useEffect(() => {
    candlesByTime.current = new Map(
      data.candles.map((candle) => [Number(toChartTime(candle.t)), candle]),
    );
    lastHovered.current = null;
    crosshairRef.current?.(null);
    const api = apiRef.current;
    if (!api) return;

    const key = `${data.spec.symbol}@${interval}`;
    const previous = renderedRef.current;
    const isSameSeries =
      previous?.key === key &&
      previous.configKey === configKey &&
      data.candles.length >= previous.candles.length;
    const from = isSameSeries ? firstStaleIndex(previous!.candles, data.candles) : 0;

    if (from === 0) {
      applyMarket(api, data, indicator, indicatorConfig);
    } else {
      applyTail(api, data, from, indicatorConfig);
    }
    renderedRef.current = { key, configKey, candles: data.candles };
  }, [data, indicator, indicatorConfig, interval, configKey]);

  return (
    <div className="relative h-full w-full overflow-hidden bg-white">
      <div ref={hostRef} className="h-full w-full" />
      {failed && (
        <div className="absolute inset-0 grid place-items-center text-[13px] text-slate-400">
          图表初始化失败
        </div>
      )}
    </div>
  );
}
