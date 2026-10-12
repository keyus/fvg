/**
 * Dexie / IndexedDB storage. Everything the app caches lives here, browser side
 * only: the watchlist history, the klines per pair+interval, and small settings.
 */

import Dexie, { type Table } from "dexie";

import type { Candle } from "./market";
import type { Snapshot } from "./market-store";

export type KlineRow = {
  symbol: string;
  interval: string;
  updatedAt: number;
  candles: Candle[];
};

export type SettingRow = { key: string; value: string };

export class FvgDatabase extends Dexie {
  snapshots!: Table<Snapshot, number>;
  klines!: Table<KlineRow, [string, string]>;
  settings!: Table<SettingRow, string>;

  constructor() {
    super("fvg-scanner");
    this.version(1).stores({
      // `++id` auto increments; `createdAt` keeps "newest snapshot" cheap.
      snapshots: "++id, createdAt",
      klines: "[symbol+interval], updatedAt",
      settings: "key",
    });
  }
}

export const db = new FvgDatabase();
