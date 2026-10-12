import { useEffect, useRef, useState } from "react";
import { NavLink } from "react-router";

import { cn } from "../lib/cn";
import { fmtDelta, fmtPct, fmtPriceCompact, priceDecimals } from "../lib/market";
import type { PairRow, Snapshot } from "../lib/market-store";
import {
  ChevronDown,
  ChevronUpSmall,
  ColumnsIcon,
  DotsIcon,
  PlusIcon,
} from "./icons";

const UP = "#089981";
const DOWN = "#f23645";

const GRID =
  "grid grid-cols-[minmax(96px,1.5fr)_minmax(0,1fr)_minmax(0,0.9fr)_minmax(0,0.85fr)] items-center gap-2";

function clockOf(timestamp: number) {
  const date = new Date(timestamp);
  return `${String(date.getMonth() + 1).padStart(2, "0")}-${String(date.getDate()).padStart(2, "0")} ${String(
    date.getHours(),
  ).padStart(2, "0")}:${String(date.getMinutes()).padStart(2, "0")}`;
}

function CoinDot({ glyph, color }: { glyph: string; color: string }) {
  return (
    <span
      className="grid size-[18px] shrink-0 place-items-center rounded-full text-[11px] leading-none font-bold text-white"
      style={{ backgroundColor: color }}
    >
      {glyph}
    </span>
  );
}

/** Daily gap badge for pairs that passed the FVG scan. */
function FvgBadge({ fvg }: { fvg: NonNullable<PairRow["fvg"]> }) {
  const label = fvg.type === "bullish" ? "FVG+" : "FVG-";
  const title = [
    `${fvg.type === "bullish" ? "看涨" : "看跌"}缺口 ${fvg.bottom.toPrecision(6)} – ${fvg.top.toPrecision(6)}`,
    `高度 ${fvg.gapPct}%`,
    `${fvg.ageDays} 天前形成`,
    fvg.status === "fresh" ? "未被回踩" : `已回踩 ${fvg.intrusionPct}%`,
    `距现价 ${fvg.distancePct.toFixed(2)}%`,
  ].join(" · ");

  return (
    <span
      title={title}
      className={cn(
        "shrink-0 rounded px-1 py-px text-[10px] leading-[14px] font-medium tabular-nums",
        fvg.type === "bullish" ? "bg-emerald-50 text-emerald-700" : "bg-rose-50 text-rose-600",
      )}
    >
      {label}
      <span className="ml-0.5 opacity-70">{fvg.ageDays}d</span>
    </span>
  );
}

function QuoteRow({ quote, search }: { quote: PairRow; search: string }) {
  const up = quote.changePct >= 0;
  const decimals = priceDecimals(quote.price);

  return (
    <NavLink
      to={{ pathname: `/trade/${quote.symbol}`, search }}
      className={({ isActive, isPending }) =>
        cn(
          GRID,
          "border-b border-slate-100 px-2.5 py-[7px] text-[13px] leading-tight",
          isActive ? "bg-slate-100/90" : "hover:bg-slate-50",
          isPending && "opacity-60",
        )
      }
    >
      <span className="flex min-w-0 items-center gap-1.5">
        <CoinDot glyph={quote.glyph} color={quote.color} />
        <span className="flex min-w-0 flex-col items-start">
          <span className="max-w-full truncate font-medium leading-tight text-slate-800">
            {quote.base}
          </span>
          {quote.fvg ? (
            <FvgBadge fvg={quote.fvg} />
          ) : (
            <span className="text-[10px] leading-tight text-slate-400">{quote.quote}</span>
          )}
        </span>
      </span>
      <span className="truncate text-right tabular-nums text-slate-800">
        {fmtPriceCompact(quote.price, decimals)}
      </span>
      <span className="truncate text-right tabular-nums" style={{ color: up ? UP : DOWN }}>
        {fmtDelta(quote.price * (quote.changePct / 100), decimals)}
      </span>
      <span className="truncate text-right tabular-nums" style={{ color: up ? UP : DOWN }}>
        {fmtPct(quote.changePct)}
      </span>
    </NavLink>
  );
}

/** Snapshot history: one entry per 获取列表 run, each removable. */
function SnapshotPicker({
  snapshots,
  activeId,
  onSelect,
  onRemove,
  onClear,
  onFetch,
  busy,
}: {
  snapshots: Snapshot[];
  activeId: number | null;
  onSelect: (id: number) => void;
  onRemove: (id: number) => void;
  onClear: () => void;
  onFetch: () => void;
  busy: boolean;
}) {
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement | null>(null);
  const active = snapshots.find((snapshot) => snapshot.id === activeId);

  useEffect(() => {
    if (!open) return;
    const onClick = (event: MouseEvent) => {
      if (!rootRef.current?.contains(event.target as Node)) setOpen(false);
    };
    window.addEventListener("mousedown", onClick);
    return () => window.removeEventListener("mousedown", onClick);
  }, [open]);

  return (
    <div ref={rootRef} className="relative">
      <button
        type="button"
        onClick={() => setOpen((value) => !value)}
        className="flex max-w-full items-center gap-1 rounded px-1.5 py-1 text-[15px] font-semibold text-slate-800 hover:bg-slate-100"
      >
        <span className="truncate">Watchlist</span>
        <span className="truncate text-[12px] font-normal text-slate-400">
          {active ? `${clockOf(active.createdAt)}（${active.pairs.length}）` : "暂无数据"}
        </span>
        <ChevronDown className="shrink-0 text-slate-500" />
      </button>

      {open && (
        <div className="absolute top-full left-0 z-30 mt-1 w-[268px] overflow-hidden rounded-lg border border-slate-200 bg-white shadow-lg">
          <div className="max-h-[280px] overflow-y-auto py-1">
            {snapshots.length === 0 && (
              <p className="px-3 py-3 text-[12px] text-slate-400">还没有列表，点右下角「获取列表」。</p>
            )}
            {snapshots.map((snapshot) => (
              <div
                key={snapshot.id}
                className={cn(
                  "group flex items-center gap-2 px-3 py-1.5 text-[12px]",
                  snapshot.id === activeId ? "bg-slate-50" : "hover:bg-slate-50",
                )}
              >
                <button
                  type="button"
                  className="flex min-w-0 flex-1 items-center gap-2 text-left"
                  onClick={() => {
                    if (snapshot.id !== undefined) onSelect(snapshot.id);
                    setOpen(false);
                  }}
                >
                  <span className="tabular-nums text-slate-700">{clockOf(snapshot.createdAt)}</span>
                  <span className="truncate text-slate-400">
                    {snapshot.pairs.length} 个 · {snapshot.config.minVolume / 10_000}万+ ·{" "}
                    {snapshot.config.minDays}天+
                  </span>
                </button>
                <button
                  type="button"
                  aria-label="删除这条列表"
                  className="shrink-0 rounded px-1 text-[14px] leading-none text-slate-300 opacity-0 transition group-hover:opacity-100 hover:text-rose-500"
                  onClick={() => {
                    if (snapshot.id !== undefined) onRemove(snapshot.id);
                  }}
                >
                  ×
                </button>
              </div>
            ))}
          </div>
          <div className="flex items-center gap-2 border-t border-slate-100 px-3 py-2 text-[12px]">
            <button
              type="button"
              disabled={snapshots.length === 0}
              className="rounded px-1.5 py-0.5 text-slate-500 hover:bg-slate-100 disabled:opacity-40"
              onClick={onClear}
            >
              清空全部
            </button>
            <button
              type="button"
              disabled={busy}
              className="ml-auto rounded bg-slate-900 px-2 py-1 text-white hover:bg-slate-800 disabled:opacity-50"
              onClick={() => {
                setOpen(false);
                onFetch();
              }}
            >
              获取列表
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export function Watchlist({
  pairs,
  snapshots,
  activeId,
  search = "",
  busy,
  onSelectSnapshot,
  onRemoveSnapshot,
  onClearSnapshots,
  onFetch,
}: {
  pairs: PairRow[];
  snapshots: Snapshot[];
  activeId: number | null;
  search?: string;
  busy: boolean;
  onSelectSnapshot: (id: number) => void;
  onRemoveSnapshot: (id: number) => void;
  onClearSnapshots: () => void;
  onFetch: () => void;
}) {
  return (
    <aside className="flex w-[290px] shrink-0 flex-col overflow-hidden border-l border-slate-200 bg-white lg:w-[320px] xl:w-[340px]">
      <div className="flex h-11 shrink-0 items-center gap-0.5 px-2.5">
        <SnapshotPicker
          snapshots={snapshots}
          activeId={activeId}
          onSelect={onSelectSnapshot}
          onRemove={onRemoveSnapshot}
          onClear={onClearSnapshots}
          onFetch={onFetch}
          busy={busy}
        />
        <div className="ml-auto flex items-center gap-0.5 text-slate-500">
          <button type="button" className="rounded p-1.5 hover:bg-slate-100" >
            <PlusIcon />
          </button>
        </div>
      </div>

      <div
        className={cn(
          GRID,
          "shrink-0 border-y border-slate-100 px-2.5 py-1.5 text-[13px] text-slate-500",
        )}
      >
        <span className="flex items-center gap-1">
          <ChevronUpSmall className="text-slate-400" />
          商品
        </span>
        <span className="text-right">最新价</span>
        <span className="text-right">涨跌</span>
        <span className="text-right">涨跌%</span>
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto">
        {pairs.map((pair) => (
          <QuoteRow key={pair.symbol} quote={pair} search={search} />
        ))}
        {pairs.length === 0 && (
          <p className="px-3 py-6 text-center text-[13px] leading-relaxed text-slate-400">
            还没有交易对
            <br />
            点右上角「获取列表」按配置拉取
          </p>
        )}
      </div>
    </aside>
  );
}
