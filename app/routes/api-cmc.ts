import { readFileSync } from "node:fs";
import path from "node:path";

import { data } from "react-router";

import type { CmcInfo, CmcProject, CmcResponse } from "../lib/cmc";
import type { Route } from "./+types/api-cmc";

/**
 * Server side CoinMarketCap proxy.
 *
 * CMC Pro is a server API: it does not send CORS headers and the key must never
 * reach the browser, so the page calls this resource route instead.
 * The key is read from the environment, falling back to the project's `.env.key`
 * (Vite only auto-loads `.env*`, not that filename).
 */

const CACHE_TTL_MS = 5 * 60_000;
const cache = new Map<string, { at: number; payload: CmcResponse }>();
const quoteCache = new Map<string, { at: number; info: CmcInfo }>();
const projectCache = new Map<string, { at: number; project: CmcProject | null }>();

function readApiKey() {
  const fromEnv =
    process.env.COINMARKETCAP_API_KEY ?? process.env.CMC_API_KEY ?? process.env.coinmarketcapApiKey;
  if (fromEnv && fromEnv.trim()) return fromEnv.trim();
  try {
    const text = readFileSync(path.join(process.cwd(), ".env.key"), "utf8");
    const match = text.match(
      /^\s*(?:coinmarketcapApiKey|COINMARKETCAP_API_KEY|CMC_API_KEY)\s*=\s*(.+?)\s*$/m,
    );
    return match ? match[1].replace(/^["']|["']$/g, "") : null;
  } catch {
    return null;
  }
}

type CmcQuote = {
  id: number;
  name: string;
  symbol: string;
  slug?: string;
  cmc_rank?: number;
  circulating_supply?: number;
  total_supply?: number;
  max_supply?: number;
  infinite_supply?: boolean;
  quote?: Record<string, Record<string, number | null>>;
};

function pickBest(entries: CmcQuote[]) {
  return [...entries].sort(
    (a, b) => (b.quote?.USD?.market_cap ?? 0) - (a.quote?.USD?.market_cap ?? 0),
  )[0];
}

function normalize(payload: unknown, symbol: string): CmcInfo | null {
  const body = payload as {
    data?: Record<string, CmcQuote | CmcQuote[]>;
    status?: { timestamp?: string };
  };
  const entry = body?.data?.[symbol];
  if (!entry) return null;
  const row = Array.isArray(entry) ? pickBest(entry) : entry;
  if (!row) return null;
  const usd = row.quote?.USD ?? {};
  return {
    id: row.id,
    name: row.name,
    symbol: row.symbol,
    slug: row.slug ?? row.symbol.toLowerCase(),
    rank: row.cmc_rank ?? null,
    price: usd.price ?? null,
    marketCap: usd.market_cap ?? null,
    fullyDiluted: usd.fully_diluted_market_cap ?? null,
    volume24h: usd.volume_24h ?? null,
    percentChange24h: usd.percent_change_24h ?? null,
    dominance: usd.market_cap_dominance ?? null,
    circulating: row.circulating_supply ?? null,
    total: row.total_supply ?? null,
    max: row.max_supply ?? null,
    infinite: row.infinite_supply === true,
    updatedAt: body?.status?.timestamp ?? null,
  };
}

type CmcInfoRow = {
  id: number;
  name: string;
  symbol: string;
  slug?: string;
  category?: string;
  description?: string;
  logo?: string;
  date_added?: string;
  twitter_username?: string;
  "tag-names"?: string[];
  urls?: Record<string, string[] | undefined>;
};

function normalizeProject(payload: unknown, symbol: string): CmcProject | null {
  const body = payload as { data?: Record<string, CmcInfoRow | CmcInfoRow[]> };
  const entry = body?.data?.[symbol];
  if (!entry) return null;
  const row = Array.isArray(entry) ? entry[0] : entry;
  if (!row) return null;
  const first = (key: string) => row.urls?.[key]?.[0] ?? null;
  return {
    id: row.id,
    name: row.name,
    symbol: row.symbol,
    slug: row.slug ?? row.symbol.toLowerCase(),
    category: row.category ?? null,
    description: row.description ?? null,
    logo: row.logo ?? null,
    website: first("website"),
    twitter: first("twitter") ?? (row.twitter_username ? `https://x.com/${row.twitter_username}` : null),
    whitepaper: first("technical_doc"),
    explorer: first("explorer"),
    dateAdded: row.date_added ?? null,
    tags: row["tag-names"] ?? [],
  };
}

async function cmcGet(pathAndQuery: string, key: string) {
  const response = await fetch(`https://pro-api.coinmarketcap.com${pathAndQuery}`, {
    headers: { "X-CMC_PRO_API_KEY": key, Accept: "application/json" },
  });
  return response;
}

export async function loader({ request }: Route.LoaderArgs): Promise<CmcResponse> {
  const symbol = (new URL(request.url).searchParams.get("symbol") ?? "").trim().toUpperCase();
  // CoinMarketCap has single letter tickers (W, U, S, G…), so one character is valid.
  if (!/^[A-Z0-9]{1,15}$/.test(symbol)) {
    throw data<CmcResponse>({ ok: false, reason: "bad-symbol" }, { status: 400 });
  }

  const cached = cache.get(symbol);
  if (cached && Date.now() - cached.at < CACHE_TTL_MS) return cached.payload;

  const key = readApiKey();
  if (!key) return { ok: false, reason: "no-key" };

  try {
    // Quotes and project info are two CMC endpoints; both are cached separately.
    const quoteFresh = quoteCache.get(symbol);
    const projectFresh = projectCache.get(symbol);
    const now = Date.now();

    let info =
      quoteFresh && now - quoteFresh.at < CACHE_TTL_MS ? quoteFresh.info : null;
    if (!info) {
      const response = await cmcGet(
        `/v2/cryptocurrency/quotes/latest?symbol=${encodeURIComponent(symbol)}&convert=USD`,
        key,
      );
      if (!response.ok) {
        const payload: CmcResponse = {
          ok: false,
          reason: response.status === 404 ? "not-found" : "error",
        };
        if (response.status >= 400 && response.status < 500 && response.status !== 429) {
          cache.set(symbol, { at: now, payload });
        }
        return payload;
      }
      info = normalize(await response.json(), symbol);
      if (!info) {
        const payload: CmcResponse = { ok: false, reason: "not-found" };
        cache.set(symbol, { at: Date.now(), payload });
        return payload;
      }
      quoteCache.set(symbol, { at: now, info });
    }

    let project =
      projectFresh && now - projectFresh.at < CACHE_TTL_MS ? projectFresh.project : undefined;
    if (project === undefined) {
      try {
        const response = await cmcGet(
          `/v1/cryptocurrency/info?symbol=${encodeURIComponent(symbol)}`,
          key,
        );
        project = response.ok ? normalizeProject(await response.json(), symbol) : null;
      } catch {
        project = null;
      }
      projectCache.set(symbol, { at: Date.now(), project });
    }

    const payload: CmcResponse = { ok: true, info, project: project ?? null };
    cache.set(symbol, { at: Date.now(), payload });
    return payload;
  } catch (error) {
    console.error("coinmarketcap request failed", error);
    return { ok: false, reason: "network" };
  }
}
