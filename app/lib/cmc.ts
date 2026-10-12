/** CoinMarketCap data the chart shows next to the price. */

export type CmcInfo = {
  id: number;
  name: string;
  symbol: string;
  slug: string;
  rank: number | null;
  price: number | null;
  marketCap: number | null;
  fullyDiluted: number | null;
  volume24h: number | null;
  percentChange24h: number | null;
  dominance: number | null;
  circulating: number | null;
  total: number | null;
  max: number | null;
  /** CMC flag: supply is unbounded (no max supply). */
  infinite: boolean;
  updatedAt: string | null;
};

export type CmcResponse =
  | { ok: true; info: CmcInfo; project: CmcProject | null }
  | { ok: false; reason: "bad-symbol" | "no-key" | "not-found" | "network" | "error" };

export type CmcState =
  | { status: "idle" | "loading" | "error" | "missing" }
  | { status: "ready"; info: CmcInfo; project: CmcProject | null };

/** Everything the "项目简介" dialog and the website icon need. */
export type CmcProject = {
  id: number;
  name: string;
  symbol: string;
  slug: string;
  category: string | null;
  description: string | null;
  logo: string | null;
  website: string | null;
  twitter: string | null;
  whitepaper: string | null;
  explorer: string | null;
  dateAdded: string | null;
  tags: string[];
};

/** 12,345,678,901 -> `123.46亿`; 1,661,883,701,883 -> `1.66万亿`. */
export function formatCompactCn(value: number | null | undefined) {
  if (value === null || value === undefined || !Number.isFinite(value)) return "—";
  const abs = Math.abs(value);
  if (abs >= 1e12) return `${(value / 1e12).toFixed(2)}万亿`;
  if (abs >= 1e8) return `${(value / 1e8).toFixed(2)}亿`;
  if (abs >= 1e4) return `${(value / 1e4).toFixed(2)}万`;
  if (abs >= 1) return value.toLocaleString("en-US", { maximumFractionDigits: 2 });
  return value.toPrecision(4);
}
