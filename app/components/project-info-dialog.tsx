import { useEffect } from "react";

import { cn } from "../lib/cn";
import type { CmcProject } from "../lib/cmc";
import { LinkIcon } from "./icons";

/** Modal with the CoinMarketCap project profile of the pair on screen. */
export function ProjectInfoDialog({
  project,
  onClose,
}: {
  project: CmcProject;
  onClose: () => void;
}) {
  useEffect(() => {
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape") onClose();
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [onClose]);

  const links = [
    { label: "官网", href: project.website },
    { label: "白皮书", href: project.whitepaper },
    { label: "区块浏览器", href: project.explorer },
    { label: "推特", href: project.twitter },
  ].filter((link) => link.href);

  return (
    <div className="fixed inset-0 z-50 flex items-start justify-center bg-slate-900/25 p-6 pt-[10vh]">
      <div className="absolute inset-0" onClick={onClose} aria-hidden />
      <div className="relative flex max-h-[72vh] w-[560px] max-w-full flex-col overflow-hidden rounded-xl border border-slate-200 bg-white shadow-xl">
        <div className="flex items-center gap-3 border-b border-slate-100 px-5 py-4">
          {project.logo ? (
            <img
              src={project.logo}
              alt={project.symbol}
              width={32}
              height={32}
              className="size-8 shrink-0 rounded-full"
            />
          ) : (
            <span className="grid size-8 shrink-0 place-items-center rounded-full bg-slate-100 text-[12px] font-bold text-slate-500">
              {project.symbol.slice(0, 2)}
            </span>
          )}
          <div className="min-w-0">
            <h2 className="truncate text-[15px] font-semibold text-slate-900">
              {project.name}
              <span className="ml-1.5 text-[12px] font-normal text-slate-400">
                {project.symbol}
              </span>
            </h2>
            <p className="truncate text-[12px] text-slate-400">
              {[project.category, project.dateAdded?.slice(0, 10)].filter(Boolean).join(" · ")}
            </p>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="ml-auto rounded px-1.5 text-[18px] leading-none text-slate-400 hover:bg-slate-100 hover:text-slate-600"
            aria-label="关闭"
          >
            ×
          </button>
        </div>

        <div className="min-h-0 flex-1 overflow-y-auto px-5 py-4">
          {project.tags.length > 0 && (
            <div className="mb-3 flex flex-wrap gap-1.5">
              {project.tags.slice(0, 10).map((tag) => (
                <span
                  key={tag}
                  className="rounded bg-slate-100 px-1.5 py-0.5 text-[11px] text-slate-500"
                >
                  {tag}
                </span>
              ))}
            </div>
          )}
          <p className="text-[13px] leading-relaxed whitespace-pre-line text-slate-700">
            {project.description?.replace(/<[^>]+>/g, "") ?? "暂无简介"}
          </p>
        </div>

        {links.length > 0 && (
          <div className="flex flex-wrap items-center gap-2 border-t border-slate-100 px-5 py-3">
            {links.map((link) => (
              <a
                key={link.label}
                href={link.href ?? "#"}
                target="_blank"
                rel="noopener noreferrer"
                className={cn(
                  "flex items-center gap-1 rounded-lg border border-slate-200 px-2.5 py-1",
                  "text-[12px] text-slate-700 hover:bg-slate-50",
                )}
              >
                <LinkIcon className="text-slate-400" />
                {link.label}
              </a>
            ))}
            <span className="ml-auto text-[11px] text-slate-300">数据来源 CoinMarketCap</span>
          </div>
        )}
      </div>
    </div>
  );
}
