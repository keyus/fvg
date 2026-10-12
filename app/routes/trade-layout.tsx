import { useState } from "react";
import { Outlet, useMatch, useNavigation, useSearchParams } from "react-router";

import { PairConfigDialog } from "../components/pair-config-dialog";
import { Watchlist } from "../components/watchlist";
import { cn } from "../lib/cn";
import { DEFAULT_SYMBOL } from "../lib/market";
import { MarketProvider, useMarket } from "../lib/market-store";

const TIMEFRAMES = [
  { label: "1小时", value: "1h" },
  { label: "4小时", value: "4h" },
  { label: "天", value: "1d" },
] as const;

function TopBar({
  symbol,
  onConfigure,
}: {
  symbol: string;
  onConfigure: () => void;
}) {
  const { interval, setInterval, refresh, fetchList, progress, loadingSymbol } = useMarket();
  const busy = progress !== null;

  return (
    <header className="relative flex h-[52px] shrink-0 items-center gap-3 border-b border-slate-200 px-3">
      <button
        type="button"
        className="flex items-center gap-1.5 rounded-lg border border-slate-200 px-3 py-1.5 text-[15px] font-semibold text-slate-800 hover:bg-slate-50"
      >
        {symbol}
      </button>

      <div className="flex items-center text-[14px] text-slate-700">
        {TIMEFRAMES.map((frame) => (
          <button
            key={frame.value}
            type="button"
            onClick={() => setInterval(frame.value)}
            className={cn(
              "rounded px-2.5 py-1.5 hover:bg-slate-100",
              interval === frame.value && "bg-slate-100 font-medium text-slate-900",
            )}
          >
            {frame.label}
          </button>
        ))}
      </div>

      <div className="ml-auto flex items-center gap-2">
        {/* <button
          type="button"
          onClick={() => void refresh()}
          disabled={loadingSymbol}
          className="rounded-lg border border-slate-200 px-4 py-1.5 text-[14px] text-slate-800 hover:bg-slate-50 disabled:opacity-50"
        >
          {loadingSymbol ? "更新中…" : "更新图表"}
        </button> */}
        <button
          type="button"
          onClick={() => void fetchList()}
          disabled={busy}
          className="rounded-lg bg-slate-900 px-4 py-1.5 text-[14px] text-white hover:bg-slate-800 disabled:opacity-60"
        >
          获取列表
        </button>
        <button
          type="button"
          onClick={onConfigure}
          className="rounded-lg px-2 py-1.5 text-[14px] text-slate-700 hover:bg-slate-100"
        >
          配置交易对
        </button>
      </div>

      {progress && (
        <div className="absolute inset-x-0 bottom-0 flex items-center gap-2">
          <div className="h-[3px] flex-1 bg-slate-100">
            <div
              className="h-full bg-sky-500 transition-all duration-200"
              style={{ width: `${Math.round(progress.value * 100)}%` }}
            />
          </div>
          <span className="pr-3 text-[11px] tabular-nums text-slate-500">
            {progress.label} {Math.round(progress.value * 100)}%
          </span>
        </div>
      )}
    </header>
  );
}

function Toast() {
  const { message } = useMarket();
  if (!message) return null;
  return (
    <div className="pointer-events-none fixed top-16 left-1/2 z-40 -translate-x-1/2 rounded-lg bg-slate-900/90 px-3.5 py-2 text-[13px] text-white shadow-lg">
      {message}
    </div>
  );
}

function Shell() {
  const match = useMatch("/trade/:symbol");
  const symbol = match?.params.symbol?.toUpperCase() ?? DEFAULT_SYMBOL;
  const navigation = useNavigation();
  const busy = navigation.state !== "idle";
  const [search] = useSearchParams();
  const [configOpen, setConfigOpen] = useState(false);
  const market = useMarket();

  return (
    <div className="flex h-screen min-h-0 flex-col overflow-hidden bg-white text-slate-900">
      <TopBar symbol={symbol} onConfigure={() => setConfigOpen(true)} />
      <div className="flex min-h-0 flex-1">
        <main className="relative flex min-w-0 flex-1 flex-col">
          <Outlet />
          {busy && (
            <div className="pointer-events-none absolute inset-x-0 top-0 z-20 h-[2px] animate-pulse bg-sky-500/70" />
          )}
        </main>
        <Watchlist
          pairs={market.activeSnapshot?.pairs ?? []}
          snapshots={market.snapshots}
          activeId={market.activeId}
          search={`?${search.toString()}`}
          busy={market.progress !== null}
          onSelectSnapshot={market.selectSnapshot}
          onRemoveSnapshot={(id) => void market.removeSnapshot(id)}
          onClearSnapshots={() => void market.clearSnapshots()}
          onFetch={() => void market.fetchList()}
        />
      </div>
      {configOpen && (
        <PairConfigDialog
          config={market.config}
          pairs={market.snapshots.flatMap((snapshot) => snapshot.pairs)}
          onClose={() => setConfigOpen(false)}
        />
      )}
      <Toast />
    </div>
  );
}

export default function TradeLayout() {
  return (
    <MarketProvider>
      <Shell />
    </MarketProvider>
  );
}
