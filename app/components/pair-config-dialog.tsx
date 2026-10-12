import { useEffect, useMemo, useState } from "react";

import { cn } from "../lib/cn";
import { useMarket, type PairRow } from "../lib/market-store";
import { LockIcon } from "./icons";
import {
  DATA_SOURCE,
  FORCED_BLACKLIST,
  DAYS_STEPS,
  DEFAULT_PAIR_CONFIG,
  FVG_AGE_STEPS,
  FVG_GAP_STEPS,
  FVG_LOOKBACK_STEPS,
  FVG_MAX_BOX_STEPS,
  VOLUME_STEPS,
  filterPairs,
  formatDaysLabel,
  formatVolumeLabel,
  isDefaultPairConfig,
  isValidPattern,
  type PairConfig,
} from "../lib/pair-config";

function OptionRow<T extends string | number>({
  label,
  hint,
  options,
  value,
  render,
  onSelect,
}: {
  label: string;
  hint?: string;
  options: readonly T[];
  value: T;
  render: (option: T) => string;
  onSelect: (option: T) => void;
}) {
  return (
    <div>
      <div className="mb-2 flex items-baseline gap-2">
        <span className="text-[13px] font-medium text-slate-800">{label}</span>
        {hint && <span className="text-[11px] text-slate-400">{hint}</span>}
      </div>
      <div className="flex flex-wrap gap-1.5">
        {options.map((option) => (
          <button
            key={String(option)}
            type="button"
            onClick={() => onSelect(option)}
            className={cn(
              "rounded-md border px-2.5 py-1 text-[12px] tabular-nums transition",
              option === value
                ? "border-slate-900 bg-slate-900 text-white"
                : "border-slate-200 text-slate-600 hover:border-slate-300 hover:bg-slate-50",
            )}
          >
            {render(option)}
          </button>
        ))}
      </div>
    </div>
  );
}

function SymbolListField({
  label,
  hint,
  tone,
  locked = [],
  symbols,
  suggestions,
  onChange,
}: {
  label: string;
  hint: string;
  tone: "danger" | "positive";
  /** Built-in entries: always applied, shown but not removable. */
  locked?: readonly string[];
  symbols: string[];
  onChange: (next: string[]) => void;
  suggestions: string[];
}) {
  const [draft, setDraft] = useState("");
  const listId = tone === "danger" ? "pair-config-black" : "pair-config-white";

  const [invalid, setInvalid] = useState<string | null>(null);

  const commit = (raw: string) => {
    const items = raw
      .split(/[\s,，]+/)
      .map((item) => item.trim())
      .filter((item) => item.length > 0);
    if (items.length === 0) return;
    const next = [...symbols];
    let rejected: string | null = null;
    for (const item of items) {
      if (!isValidPattern(item)) {
        rejected = item;
        continue;
      }
      if (!next.includes(item)) next.push(item);
    }
    setInvalid(rejected);
    onChange(next);
    setDraft("");
  };

  return (
    <div>
      <div className="mb-2 flex items-baseline gap-2">
        <span className="text-[13px] font-medium text-slate-800">{label}</span>
        <span className="text-[11px] text-slate-400">{hint}</span>
        {invalid && (
          <span className="text-[11px] text-amber-600">「{invalid}」不是合法正则，已忽略</span>
        )}
      </div>
      <div className="flex min-h-[38px] flex-wrap items-center gap-1.5 rounded-md border border-slate-200 px-2 py-1.5">
        {locked.map((item) => (
          <span
            key={`locked-${item}`}
            title="内置强制排除，不可移除"
            className="flex items-center gap-1 rounded border border-slate-200 bg-slate-100 px-1.5 py-0.5 text-[12px] text-slate-500 tabular-nums"
          >
            <LockIcon width={11} height={11} className="text-slate-400" />
            {item}
          </span>
        ))}
        {symbols.map((item) => (
          <span
            key={item}
            className={cn(
              "flex items-center gap-1 rounded px-1.5 py-0.5 text-[12px] tabular-nums",
              !isValidPattern(item)
                ? "bg-amber-50 text-amber-700"
                : tone === "danger"
                  ? "bg-rose-50 text-rose-600"
                  : "bg-emerald-50 text-emerald-700",
            )}
            title={
              isValidPattern(item)
                ? `匹配 BASE/USDT、符号或币种名，例如 ${item}`
                : "正则表达式无效，这条不会生效"
            }
          >
            {item}
            <button
              type="button"
              aria-label={`移除 ${item}`}
              className="text-[13px] leading-none opacity-60 hover:opacity-100"
              onClick={() => onChange(symbols.filter((symbol) => symbol !== item))}
            >
              ×
            </button>
          </span>
        ))}
        <input
          value={draft}
          list={listId}
          placeholder={symbols.length ? "继续添加，回车确认" : "输入交易对或正则，回车确认"}
          className="min-w-[150px] flex-1 bg-transparent text-[13px] outline-none placeholder:text-slate-300"
          onChange={(event) => setDraft(event.target.value)}
          onKeyDown={(event) => {
            if (event.key === "Enter" || event.key === ",") {
              event.preventDefault();
              commit(draft);
            } else if (event.key === "Backspace" && draft === "" && symbols.length > 0) {
              onChange(symbols.slice(0, -1));
            }
          }}
        />
      </div>
      <datalist id={listId}>
        {suggestions.map((symbol) => (
          <option key={symbol} value={symbol} />
        ))}
      </datalist>
    </div>
  );
}

export function PairConfigDialog({
  config,
  pairs,
  onClose,
}: {
  config: PairConfig;
  pairs: PairRow[];
  onClose: () => void;
}) {
  const { savePairConfig } = useMarket();
  const [draft, setDraft] = useState<PairConfig>(config);

  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [onClose]);

  // Preview against the pairs already fetched from Binance, so the count is real.
  const known = useMemo(() => {
    const unique = new Map(pairs.map((pair) => [pair.symbol, pair]));
    return [...unique.values()];
  }, [pairs]);
  const matched = useMemo(() => filterPairs(known, draft), [known, draft]);
  const suggestions = useMemo(() => known.map((pair) => pair.symbol), [known]);
  const defaultConfig = isDefaultPairConfig(draft);

  const apply = (next: PairConfig) => {
    void savePairConfig(next);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center bg-slate-900/25 p-6 pt-[8vh]">
      <div
        className="absolute inset-0"
        onClick={onClose}
        aria-hidden
      />
      <div className="relative flex w-[820px] max-w-full flex-col overflow-hidden rounded-xl border border-slate-200 bg-white shadow-xl">
        <div className="flex items-center justify-between border-b border-slate-100 px-5 py-3.5">
          <h2 className="text-[15px] font-semibold text-slate-900">配置交易对</h2>
          <button
            type="button"
            onClick={onClose}
            className="rounded px-1.5 text-[18px] leading-none text-slate-400 hover:bg-slate-100 hover:text-slate-600"
            aria-label="关闭"
          >
            ×
          </button>
        </div>

        <div className="flex max-h-[68vh] flex-col gap-5 overflow-y-auto px-5 py-4">
          <div className="flex items-center justify-between rounded-md bg-slate-50 px-3 py-2">
            <div className="flex items-baseline gap-2">
              <span className="text-[13px] font-medium text-slate-800">数据来源</span>
              <span className="text-[11px] text-slate-400">当前仅支持一家</span>
            </div>
            <span className="rounded border border-slate-200 bg-white px-2.5 py-1 text-[12px] font-medium text-slate-700">
              {DATA_SOURCE}
            </span>
          </div>

          <OptionRow
            label="成交量"
            hint="24 小时成交额下限（USDT）"
            options={VOLUME_STEPS}
            value={draft.minVolume}
            render={formatVolumeLabel}
            onSelect={(minVolume) => setDraft((prev) => ({ ...prev, minVolume }))}
          />

          <OptionRow
            label="交易时间"
            hint="上线天数下限"
            options={DAYS_STEPS}
            value={draft.minDays}
            render={formatDaysLabel}
            onSelect={(minDays) => setDraft((prev) => ({ ...prev, minDays }))}
          />

          <div className="rounded-lg border border-slate-100 bg-slate-50/60 px-3 py-3">
            <div className="mb-3 flex items-center justify-between">
              <div className="flex items-baseline gap-2">
                <span className="text-[13px] font-medium text-slate-800">FVG 检测</span>
                <span className="text-[11px] text-slate-400">
                  筛选完成后扫日线缺口，只留符合条件的
                </span>
              </div>
              <button
                type="button"
                onClick={() =>
                  setDraft((prev) => ({ ...prev, fvg: { ...prev.fvg, enabled: !prev.fvg.enabled } }))
                }
                className={cn(
                  "rounded-md border px-2.5 py-1 text-[12px] transition",
                  draft.fvg.enabled
                    ? "border-slate-900 bg-slate-900 text-white"
                    : "border-slate-200 bg-white text-slate-500 hover:bg-slate-50",
                )}
              >
                {draft.fvg.enabled ? "已启用" : "已关闭"}
              </button>
            </div>
            <div className={cn("flex flex-col gap-3", !draft.fvg.enabled && "pointer-events-none opacity-40")}>
              <OptionRow
                label="回看K线"
                hint="拉多少天日线去检测"
                options={FVG_LOOKBACK_STEPS}
                value={draft.fvg.lookbackDays}
                render={(days) => `${days}天`}
                onSelect={(lookbackDays) =>
                  setDraft((prev) => ({ ...prev, fvg: { ...prev.fvg, lookbackDays } }))
                }
              />
              <OptionRow
                label="缺口年龄"
                hint="只保留最近多少天内形成的缺口"
                options={FVG_AGE_STEPS}
                value={draft.fvg.maxAgeDays}
                render={(days) => `${days}天内`}
                onSelect={(maxAgeDays) =>
                  setDraft((prev) => ({ ...prev, fvg: { ...prev.fvg, maxAgeDays } }))
                }
              />
              <OptionRow
                label="最小缺口"
                hint="缺口高度占价格的比例"
                options={FVG_GAP_STEPS}
                value={draft.fvg.minGapPct}
                render={(pct) => `${pct}%`}
                onSelect={(minGapPct) =>
                  setDraft((prev) => ({ ...prev, fvg: { ...prev.fvg, minGapPct } }))
                }
              />
              <OptionRow
                label="方向"
                hint="现货只做多，可选只看涨"
                options={[1, 0]}
                value={draft.fvg.bullishOnly ? 1 : 0}
                render={(value) => (value === 1 ? "仅看涨" : "全部")}
                onSelect={(value) =>
                  setDraft((prev) => ({ ...prev, fvg: { ...prev.fvg, bullishOnly: value === 1 } }))
                }
              />
              <OptionRow
                label="最大显示"
                hint="图表上最多画多少个 FVG 箱体，超出只留最新的"
                options={FVG_MAX_BOX_STEPS}
                value={draft.fvg.maxBoxes ?? 20}
                render={(count) => `${count} 个`}
                onSelect={(maxBoxes) =>
                  setDraft((prev) => ({ ...prev, fvg: { ...prev.fvg, maxBoxes } }))
                }
              />
            </div>
          </div>

          <SymbolListField
            label="黑名单"
            hint="支持正则，如 RLUSD/.* ；带锁的是内置强制排除"
            tone="danger"
            locked={FORCED_BLACKLIST}
            symbols={draft.blacklist}
            suggestions={suggestions}
            onChange={(blacklist) => setDraft((prev) => ({ ...prev, blacklist }))}
          />

          <SymbolListField
            label="白名单"
            hint="支持正则，如 BTC/.* ；填了就只显示这些"
            tone="positive"
            symbols={draft.whitelist}
            suggestions={suggestions}
            onChange={(whitelist) => setDraft((prev) => ({ ...prev, whitelist }))}
          />

          <div className="rounded-md border border-slate-100 bg-slate-50/60 px-3 py-2 text-[12px] text-slate-500">
            已获取 {known.length} 个交易对，按当前条件匹配到{" "}
            <span className="font-semibold text-slate-800 tabular-nums">{matched.length}</span>{" "}
            个交易对
            {matched.length > 0 && (
              <span className="ml-1 text-slate-400">
                （{matched.slice(0, 4).map((pair) => pair.base).join("、")}
                {matched.length > 4 ? " 等" : ""}）
              </span>
            )}
          </div>
        </div>

        <div className="flex items-center gap-2 border-t border-slate-100 px-5 py-3.5">
          <button
            type="button"
            disabled={defaultConfig && isDefaultPairConfig(config)}
            className="rounded-lg px-3 py-1.5 text-[13px] text-slate-500 hover:bg-slate-100 disabled:opacity-40 disabled:hover:bg-transparent"
            onClick={() => setDraft(DEFAULT_PAIR_CONFIG)}
          >
            恢复默认
          </button>
          <div className="ml-auto flex items-center gap-2">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg border border-slate-200 px-4 py-1.5 text-[13px] text-slate-700 hover:bg-slate-50"
            >
              取消
            </button>
            <button
              type="button"
              onClick={() => apply(draft)}
              className="rounded-lg bg-slate-900 px-4 py-1.5 text-[13px] text-white hover:bg-slate-800"
            >
              保存并应用
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
