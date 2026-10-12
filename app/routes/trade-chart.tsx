import { useEffect, useState } from "react";
import { useParams } from "react-router";

import { CandleChart } from "../components/candle-chart";
import { ChevronDown, DocIcon, GlobeIcon, TargetIcon } from "../components/icons";
import { ProjectInfoDialog } from "../components/project-info-dialog";
import { cn } from "../lib/cn";
import { formatCompactCn, type CmcInfo, type CmcProject } from "../lib/cmc";
import { fmtPct, fmtPrice, fmtSigned, priceDecimals, type Candle } from "../lib/market";
import { useMarket } from "../lib/market-store";
import type { Route } from "./+types/trade-chart";

const INTERVAL_LABEL: Record<string, string> = { "1h": "1小时", "4h": "4小时", "1d": "天" };

export function meta({ params }: Route.MetaArgs) {
  const symbol = params.symbol?.toUpperCase() ?? "";
  return [{ title: symbol ? `${symbol} 图表` : "图表" }];
}

function Stat({ label, value }: { label: string; value: string }) {
  return (
    <span className="whitespace-nowrap">
      <span>{label}=</span>
      <span>{value}</span>
    </span>
  );
}

/** Supply figures come from CoinMarketCap, so they may be missing for a pair it does not list. */
function supplyText(value: number | null | undefined) {
  return value === null || value === undefined ? "—" : formatCompactCn(value);
}

function maxSupplyText(info: CmcInfo | undefined) {
  if (!info) return "—";
  if (info.max !== null && info.max !== undefined) return formatCompactCn(info.max);
  return info.infinite ? "∞" : "—";
}

/** Mark price of the newest kline plus the pair's market data. */
function MarkWidget({
  last,
  tick,
  info,
  project,
  extremes,
  onOpenProject,
}: {
  last: Candle;
  tick: number;
  info?: CmcInfo;
  project?: CmcProject | null;
  extremes: { ath: number; atl: number } | null;
  onOpenProject: () => void;
}) {
  const decimals = priceDecimals(last.c);
  const mark = last.c - tick / 2;
  const diff = mark - last.o;
  const pct = last.o === 0 ? 0 : (diff / last.o) * 100;
  // 涨绿跌红: both readouts follow the mark price against the candle's open.
  const tone = diff >= 0 ? "text-[#089981]" : "text-[#ef5350]";

  return (
    <div className="absolute top-2 left-2 z-10 flex items-start gap-1.5">
      <div className="rounded px-3 py-1 text-center">
        <div className="text-[11px] leading-tight text-[#969E9C]">价格</div>
        <div className={cn("tabular-nums text-[15px] leading-tight font-semibold", tone)}>
          {fmtPrice(mark, decimals)}
        </div>
      </div>
      <div className="rounded px-3 py-1 text-center">
        <div className="text-[11px] leading-tight text-[#969E9C]">涨跌幅</div>
        <div className={cn("tabular-nums text-[15px] leading-tight font-semibold", tone)}>
          {fmtSigned(diff, decimals)} ({fmtPct(pct)})
        </div>
      </div>
      <div className="px-3 py-1 text-center flex-auto">
        <div className="text-[11px] leading-tight text-[#969E9C]">24小时成交量</div>
        <div className="tabular-nums text-[15px] leading-tight font-semibold text-[#333]">
          {last.v.toFixed(2)}
        </div>
      </div>
      <div className="rounded px-3 py-1 text-left">
        <div className="text-[12px] leading-tight text-[#666]">
          <span>总发行量:{supplyText(info?.total)}</span>
          <span className="ml-3">流通量:{supplyText(info?.circulating)}</span>
          <span className="ml-3">最大供给量:{maxSupplyText(info)}</span>
        </div>
        <div className="mt-0.5 text-[12px] leading-tight text-[#666]">
          <span>当前市值:${formatCompactCn(info?.marketCap)}</span>
          <span className="ml-3">
            历史最高:{extremes ? fmtPrice(extremes.ath, decimals) : "…"}
          </span>
          <span className="ml-3">历史最低:{extremes ? fmtPrice(extremes.atl, decimals) : "…"}</span>
        </div>
      </div>
    </div>
  );
}

function EmptyState({ text, hint }: { text: string; hint: string }) {
  return (
    <div className="grid h-full place-items-center bg-white">
      <div className="text-center">
        <p className="text-[15px] text-slate-700">{text}</p>
        <p className="mt-1 text-[13px] text-slate-400">{hint}</p>
      </div>
    </div>
  );
}

export default function TradeChart() {
  const params = useParams();
  const symbol = params.symbol?.toUpperCase() ?? "";
  const { market, loadSymbol, interval, loadingSymbol, notify, config, cmc, extremes } =
    useMarket();
  const [hoveredTime, setHoveredTime] = useState<number | null>(null);
  const [projectOpen, setProjectOpen] = useState(false);

  useEffect(() => {
    // The interval is passed explicitly: a stale closure here used to refetch the
    // previous interval and paint 1h candles under a 4h label.
    if (symbol) void loadSymbol(symbol, interval);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [symbol, interval]);

  useEffect(() => {
    setHoveredTime(null);
  }, [market?.spec.symbol]);

  if (!market || market.spec.symbol !== symbol) {
    return (
      <EmptyState
        text={loadingSymbol ? "正在从 Binance 拉取 K 线…" : "请选择一个商品"}
        hint="点击右侧列表里的交易对，最多拉取 1000 根 K 线"
      />
    );
  }

  const { spec } = market;
  const decimals = priceDecimals(spec.price);
  const hovered = hoveredTime === null ? undefined : market.candles.find((c) => c.t === hoveredTime);
  const cursor = hovered ?? market.last;
  const down = cursor.c < cursor.o;
  const valueColor = down ? "text-[#ef5350]" : "text-[#089981]";

  return (
    <div className="flex h-full min-h-0 flex-col">
      <div className="flex h-11 shrink-0 items-center gap-2 px-3 text-[13px]">
        <span
          className="grid size-[18px] shrink-0 place-items-center rounded-full text-[11px] leading-none font-bold text-white"
          style={{ backgroundColor: spec.color }}
        >
          {spec.glyph}
        </span>
        <span className="font-semibold whitespace-nowrap text-slate-800">
          {spec.name} / {spec.quote}
        </span>
        <span className="text-slate-300">·</span>
        <span className="text-slate-500">{INTERVAL_LABEL[interval] ?? interval}</span>
        <span className="text-slate-300">·</span>
        <span className="text-slate-600">{spec.exchange}</span>
        <span className="ml-1 size-[7px] shrink-0 rounded-full bg-[#089981]" />
        <span className={cn("flex items-center gap-1.5 tabular-nums", valueColor)}>
          <Stat label="开" value={fmtPrice(cursor.o, decimals)} />
          <Stat label="高" value={fmtPrice(cursor.h, decimals)} />
          <Stat label="低" value={fmtPrice(cursor.l, decimals)} />
          <Stat label="收" value={fmtPrice(cursor.c, decimals)} />
          <span className="ml-1">
            {fmtSigned(cursor.c - cursor.o, decimals)} (
            {fmtPct(((cursor.c - cursor.o) / cursor.o) * 100)})
          </span>
        </span>

        {cmc.status === "ready" && cmc.project?.description && (
          <button
            type="button"
            onClick={() => setProjectOpen(true)}
            title="项目简介"
            className="ml-auto flex items-center gap-1 rounded px-2 py-1 text-[13px] text-slate-600 hover:bg-slate-100"
          >
            <DocIcon width={15} height={15} className="text-slate-400" />
            项目简介
          </button>
        )}
      </div>

      <div className="relative min-h-0 flex-1 border-t border-slate-100">
        <CandleChart
          data={market}
          interval={interval}
          config={{ fvgMaxBoxes: config.fvg.maxBoxes }}
          onCrosshairChange={(candle: Candle | null) => setHoveredTime(candle?.t ?? null)}
        />
        <MarkWidget
          last={market.last}
          tick={market.tick}
          info={cmc.status === "ready" ? cmc.info : undefined}
          project={cmc.status === "ready" ? cmc.project : null}
          extremes={extremes}
          onOpenProject={() => setProjectOpen(true)}
        />
        <button
          type="button"
          className="absolute right-2 bottom-9 z-10 rounded p-1.5 text-slate-300 hover:bg-slate-100 hover:text-slate-500"
          aria-label="图表设置"
        >
          <TargetIcon />
        </button>
      </div>
      {projectOpen && cmc.status === "ready" && cmc.project && (
        <ProjectInfoDialog project={cmc.project} onClose={() => setProjectOpen(false)} />
      )}
    </div>
  );
}
