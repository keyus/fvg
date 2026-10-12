import type { SVGProps } from "react";

const base = {
  fill: "none",
  stroke: "currentColor",
  strokeWidth: 1.6,
  strokeLinecap: "round" as const,
  strokeLinejoin: "round" as const,
};

export function ChevronDown(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 16 16" width={16} height={16} {...base} {...props}>
      <path d="M4 6.5 8 10.5l4-4" />
    </svg>
  );
}

export function PlusIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 20 20" width={20} height={20} {...base} {...props}>
      <path d="M10 4v12M4 10h12" />
    </svg>
  );
}

export function ColumnsIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 20 20" width={20} height={20} {...base} {...props}>
      <rect x="3" y="3.5" width="14" height="13" rx="1.5" />
      <path d="M8 3.5v13M12.5 3.5v13" />
    </svg>
  );
}

export function DotsIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 20 20" width={20} height={20} {...base} {...props}>
      <path d="M4.5 10h.01M10 10h.01M15.5 10h.01" strokeWidth={2.4} />
    </svg>
  );
}

export function ChevronUpSmall(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 16 16" width={14} height={14} {...base} {...props}>
      <path d="M4 9.5 8 5.5l4 4" />
    </svg>
  );
}

export function TargetIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 24 24" width={18} height={18} {...base} {...props}>
      <circle cx="12" cy="12" r="7.5" />
      <path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3" />
      <circle cx="12" cy="12" r="1.6" fill="currentColor" stroke="none" />
    </svg>
  );
}

export function PlayIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 16 16" width={12} height={12} fill="currentColor" {...props}>
      <path d="M5 3.5v9l7.5-4.5z" />
    </svg>
  );
}

/** 项目官网 */
export function GlobeIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 20 20" width={16} height={16} {...base} {...props}>
      <circle cx="10" cy="10" r="7.2" />
      <path d="M2.8 10h14.4M10 2.8c2 2 3 4.4 3 7.2s-1 5.2-3 7.2c-2-2-3-4.4-3-7.2s1-5.2 3-7.2z" />
    </svg>
  );
}

/** 项目简介 */
export function DocIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 20 20" width={16} height={16} {...base} {...props}>
      <path d="M5 2.8h6l4 4v10.4H5z" />
      <path d="M11 2.8v4h4M7.4 11h5.2M7.4 13.8h3.6" />
    </svg>
  );
}

export function LockIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 20 20" width={14} height={14} {...base} {...props}>
      <rect x="4.5" y="8.5" width="11" height="8" rx="1.5" />
      <path d="M7 8.5V6.2a3 3 0 0 1 6 0v2.3" />
    </svg>
  );
}

export function LinkIcon(props: SVGProps<SVGSVGElement>) {
  return (
    <svg viewBox="0 0 20 20" width={14} height={14} {...base} {...props}>
      <path d="M8.4 11.6a3.2 3.2 0 0 1 0-4.5l2-2a3.2 3.2 0 0 1 4.5 4.5l-1 1" />
      <path d="M11.6 8.4a3.2 3.2 0 0 1 0 4.5l-2 2a3.2 3.2 0 0 1-4.5-4.5l1-1" />
    </svg>
  );
}
