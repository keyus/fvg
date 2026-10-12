#!/usr/bin/env python3
"""
日线 FVG 扫描器 — 筛选币安现货交易对中日线级别未回踩的 FVG

条件:
  1. 日K线检测 FVG (Fair Value Gap)
  2. FVG 形成于最近 15 天内
  3. FVG 未被回调过，或回调未触及 FVG 底部/顶部
  4. 只扫描币安现货 USDT 交易对，且 24h 成交量 符合配置要求 规则
  5. 必须是做多 FVG (即日线看多FVG在下方做支撑) 因为是现货不做空
"""

import sys
import re
import json
import time
import argparse
from datetime import datetime, timedelta, timezone

import ccxt
import pandas as pd
import numpy as np

# ---------------------------------------------------------------------------
# 配置
# ---------------------------------------------------------------------------
BINANCE_RATE_LIMIT_MS = 200       # 每次 API 调用间隔 (ms)
MIN_USD_VOLUME = 3_000_000        # 最小 24h 成交量 (USDT)，过滤冷门币
TOP_VOLUME_COUNT = 200            # 只扫描成交量前 N 的交易对
FVG_MAX_AGE_DAYS = 15             # FVG 最大年龄
FVG_MIN_SIZE_PCT = 0.3            # FVG 最小尺寸 (%)，太小忽略
LOOKBACK_DAYS = 40                # 取多少天的日线 (确保覆盖检测)

CONFIG_PATH = "fvg_scanner_config.json"
TOKENS_PER_LINE = 30                   # watchlist 导出时每行的交易对数量

# 网络请求重试 / 分块
FAPI_MAX_SYMBOLS_PER_REQUEST = 100   # 单次 fetch_tickers 的最大交易对数 (避免 414 URL 过长)
RETRY_ATTEMPTS = 4                    # 网络错误重试次数
RETRY_BASE_DELAY = 2.0                # 重试基础间隔 (秒)，线性递增

# 可重试的 ccxt 异常 (网络抖动 / 限频 / URL 过长等)
RETRYABLE_ERRORS = (
    ccxt.NetworkError,
    ccxt.ExchangeNotAvailable,
    ccxt.RequestTimeout,
    ccxt.DDoSProtection,
    ccxt.RateLimitExceeded,
    ccxt.ExchangeError,
)


def call_with_retry(func, *args, attempts: int = RETRY_ATTEMPTS,
                    base_delay: float = RETRY_BASE_DELAY, label: str = "API"):
    """带指数退避重试地调用 ccxt 接口，避免偶发网络/限频错误导致脚本崩溃"""
    last_err = None
    for i in range(attempts):
        try:
            return func(*args)
        except RETRYABLE_ERRORS as e:
            last_err = e
            if i < attempts - 1:
                delay = base_delay * (i + 1)
                print(f"      警告: {label} 失败 ({type(e).__name__}: {str(e)[:80]})，"
                      f"{delay:.0f}s 后重试 ({i + 1}/{attempts - 1})...")
                time.sleep(delay)
    raise last_err


def fetch_tickers_chunked(exchange: ccxt.Exchange, symbols: list[str],
                          chunk_size: int = FAPI_MAX_SYMBOLS_PER_REQUEST) -> dict:
    """分块获取 ticker，避免一次请求过多交易对触发 Binance 414 (Request-URI Too Large)"""
    tickers: dict = {}
    for i in range(0, len(symbols), chunk_size):
        chunk = symbols[i:i + chunk_size]
        part = call_with_retry(exchange.fetch_tickers, chunk, label="fetch_tickers")
        tickers.update(part)
    return tickers


# ---------------------------------------------------------------------------
# FVG 检测
# ---------------------------------------------------------------------------
def detect_fvgs(df: pd.DataFrame, min_size_pct: float = 0.3) -> pd.DataFrame:
    """
    在日线 DataFrame 上检测 FVG，返回 FVG 列表 DataFrame

    参数:
      df: 包含 open/high/low/close/volume 的日线数据，index 为 datetime
      min_size_pct: FVG 缺口最小值 (价格百分比)

    返回:
      DataFrame, 每行一个 FVG:
        fvg_time, type, top, bottom, gap_pct
    """
    n = len(df)
    fvgs = []

    for i in range(3, n):
        # Bullish FVG: low[-1] > high[-3]  →  上涨失衡, 缺口在下方做支撑
        if df["low"].iloc[i - 1] > df["high"].iloc[i - 3]:
            fvg_top = df["low"].iloc[i - 1]      # 缺口上沿
            fvg_bot = df["high"].iloc[i - 3]     # 缺口下沿 (compare)
            gap_pct = (fvg_top - fvg_bot) / fvg_bot * 100
            if gap_pct >= min_size_pct:
                fvgs.append({
                    "fvg_time": df.index[i],           # FVG 被检测到的时间
                    "type": "bullish",
                    "top": fvg_top,
                    "bottom": fvg_bot,
                    "gap_pct": round(gap_pct, 3),
                })

        # Bearish FVG: high[-1] < low[-3]  →  下跌失衡, 缺口在上方做阻力
        if df["high"].iloc[i - 1] < df["low"].iloc[i - 3]:
            fvg_top = df["low"].iloc[i - 3]      # 缺口上沿 (compare)
            fvg_bot = df["high"].iloc[i - 1]     # 缺口下沿
            gap_pct = (fvg_top - fvg_bot) / fvg_bot * 100
            if gap_pct >= min_size_pct:
                fvgs.append({
                    "fvg_time": df.index[i],
                    "type": "bearish",
                    "top": fvg_top,
                    "bottom": fvg_bot,
                    "gap_pct": round(gap_pct, 3),
                })

    return pd.DataFrame(fvgs)


def check_fvg_freshness(df: pd.DataFrame, fvg_row: pd.Series) -> dict:
    """
    检查某个 FVG 的 "新鲜度"

    返回:
      {
        "status": "fresh"        — 完全未被回踩
                "partial"       — 回调已进入 FVG，但未触及关键边界
                "filled"        — FVG 已被完全填补
                "disrespected"  — FVG 已被穿透失效
        "retest_time":          — 首次回踩时间 (如有)
        "max_intrusion_pct":    — 最大侵入深度 (占FVG高度的百分比)
      }
    """
    fvg_time = fvg_row["fvg_time"]
    fvg_type = fvg_row["type"]
    top = fvg_row["top"]
    bottom = fvg_row["bottom"]
    gap_height = top - bottom

    if gap_height <= 0:
        return {"status": "filled", "retest_time": None, "max_intrusion_pct": 100}

    # 获取 FVG 形成之后的所有 K 线
    after = df[df.index > fvg_time]
    if len(after) == 0:
        return {"status": "fresh", "retest_time": None, "max_intrusion_pct": 0}

    if fvg_type == "bullish":
        # 做多 FVG: 缺口区间 [bottom, top], compare = bottom (下沿)
        # 回踩: 价格 low 进入区间 → low <= top
        # 填补: 价格 close 跌破 bottom
        # 穿透: 价格 body 跌破 bottom (实体穿透)

        # 检查是否有 bar 的 low 进入了 FVG
        entered = after["low"] <= top
        if not entered.any():
            return {"status": "fresh", "retest_time": None, "max_intrusion_pct": 0}

        first_retest_idx = entered[entered].index[0] if entered.any() else None
        first_retest = after.loc[first_retest_idx] if first_retest_idx is not None else None

        # 计算最大侵入深度 (price low 进入 FVG 多深)
        intrusion = (top - after["low"]).clip(lower=0)  # 侵入深度 = top - low
        max_intrusion = intrusion.max()
        max_intrusion_pct = (max_intrusion / gap_height) * 100 if gap_height > 0 else 0

        # 检查 close 是否跌破 bottom (完全填补)
        filled = after["close"] < bottom
        if filled.any():
            return {"status": "disrespected",
                    "retest_time": str(first_retest_idx),
                    "max_intrusion_pct": round(max_intrusion_pct, 1)}

        # 检查 body 是否跌破 bottom (实体穿透)
        body_lo = np.minimum(after["open"], after["close"])
        body_broke = body_lo < bottom
        if body_broke.any():
            return {"status": "disrespected",
                    "retest_time": str(first_retest_idx),
                    "max_intrusion_pct": round(max_intrusion_pct, 1)}

        # 已回踩但未跌破 → partial
        return {"status": "partial",
                "retest_time": str(first_retest_idx),
                "max_intrusion_pct": round(max_intrusion_pct, 1)}

    else:  # bearish
        # 做空 FVG: 缺口区间 [bottom, top], compare = top (上沿)
        # 回踩: 价格 high 进入区间 → high >= bottom
        # 填补: 价格 close 突破 top

        entered = after["high"] >= bottom
        if not entered.any():
            return {"status": "fresh", "retest_time": None, "max_intrusion_pct": 0}

        first_retest_idx = entered[entered].index[0]
        first_retest = after.loc[first_retest_idx] if first_retest_idx is not None else None

        intrusion = (after["high"] - bottom).clip(lower=0)
        max_intrusion = intrusion.max()
        max_intrusion_pct = (max_intrusion / gap_height) * 100 if gap_height > 0 else 0

        filled = after["close"] > top
        if filled.any():
            return {"status": "disrespected",
                    "retest_time": str(first_retest_idx),
                    "max_intrusion_pct": round(max_intrusion_pct, 1)}

        body_hi = np.maximum(after["open"], after["close"])
        body_broke = body_hi > top
        if body_broke.any():
            return {"status": "disrespected",
                    "retest_time": str(first_retest_idx),
                    "max_intrusion_pct": round(max_intrusion_pct, 1)}

        return {"status": "partial",
                "retest_time": str(first_retest_idx),
                "max_intrusion_pct": round(max_intrusion_pct, 1)}


# ---------------------------------------------------------------------------
# 黑名单加载
# ---------------------------------------------------------------------------
def load_blacklist_from_config(config_path: str = CONFIG_PATH) -> list[str]:
    """从 config.json 中读取 pair_blacklist"""
    try:
        with open(config_path, "r") as f:
            config = json.load(f)
        return config.get("exchange", {}).get("pair_blacklist", [])
    except (FileNotFoundError, json.JSONDecodeError, KeyError):
        print(f"警告: 无法读取 {config_path} 中的黑名单，使用空黑名单")
        return []


def load_whitelist_from_config(config_path: str = CONFIG_PATH) -> list[str]:
    """从 config.json 中读取 pair_whitelist"""
    try:
        with open(config_path, "r") as f:
            config = json.load(f)
        return config.get("exchange", {}).get("pair_whitelist", [])
    except (FileNotFoundError, json.JSONDecodeError, KeyError):
        print(f"警告: 无法读取 {config_path} 中的白名单，使用空白名单")
        return []


# ---------------------------------------------------------------------------
# 主扫描逻辑
# ---------------------------------------------------------------------------
def fetch_spot_usdt_pairs(exchange: ccxt.Exchange, min_volume: float, top_n: int,
                          blacklist: list[str]):
    """获取币安现货 USDT 交易对，按成交量排序，返回前 top_n"""
    print(f"[1/4] 获取币安现货 USDT 交易对...")
    markets = call_with_retry(exchange.load_markets, label="load_markets")
    blacklist_re = [re.compile(p) for p in blacklist] if blacklist else []
    usdt_pairs = [
        s for s, m in markets.items()
        if s.endswith("/USDT") and m.get("spot") and m.get("active")
        and not any(p.search(s) for p in blacklist_re)
    ]
    print(f"      共 {len(usdt_pairs)} 个 USDT 现货交易对 (已过滤 config.json 黑名单)")

    print(f"[2/4] 获取 24h 成交量，过滤低于 {min_volume:,.0f} USDT 的冷门币...")
    tickers = fetch_tickers_chunked(exchange, usdt_pairs)
    pair_volumes = []
    for symbol in usdt_pairs:
        t = tickers.get(symbol)
        if t and t.get("quoteVolume") is not None:
            vol = t["quoteVolume"]
            if vol >= min_volume:
                pair_volumes.append((symbol, vol))

    pair_volumes.sort(key=lambda x: x[1], reverse=True)
    top_pairs = pair_volumes[:top_n]
    print(f"      筛选后 {len(top_pairs)} 个交易对 (24h 成交量前 {top_n})")
    return [p[0] for p in top_pairs]


def scan_pair(exchange: ccxt.Exchange, symbol: str, lookback: int,
              max_age: int, min_pct: float) -> list[dict]:
    """扫描单个交易对，返回符合条件的 FVG 列表"""
    try:
        since = exchange.parse8601(
            (datetime.now(timezone.utc) - timedelta(days=lookback)).strftime("%Y-%m-%dT00:00:00Z")
        )
        ohlcv = exchange.fetch_ohlcv(symbol, "1d", since=since, limit=lookback + 10)
        if len(ohlcv) < 5:
            return []

        df = pd.DataFrame(ohlcv, columns=["timestamp", "open", "high", "low", "close", "volume"])
        df["timestamp"] = pd.to_datetime(df["timestamp"], unit="ms", utc=True)
        df.set_index("timestamp", inplace=True)

        # 去重 (同一天只保留一条)
        df = df[~df.index.duplicated(keep="last")]

        # 检测 FVGs
        fvgs = detect_fvgs(df, min_pct)
        if fvgs.empty:
            return []

        # 只保留最近 N 天内的 FVG
        cutoff = pd.Timestamp.now(tz="utc") - timedelta(days=max_age)
        recent = fvgs[fvgs["fvg_time"] >= cutoff]
        if recent.empty:
            return []

        # 检查新鲜度 (只看做多 FVG — 日线看多FVG在下方做支撑)
        results = []
        for _, row in recent.iterrows():
            if row["type"] != "bullish":
                continue  # 跳过看空FVG，只看做多机会
            freshness = check_fvg_freshness(df, row)
            if freshness["status"] in ("fresh", "partial"):
                current_price = float(df["close"].iloc[-1])
                # 低价币 (如 PEPE/SHIB) 保留完整精度，避免舍入为 0 导致除零 / 假的 0% 距离
                results.append({
                    "symbol": symbol,
                    "type": row["type"],
                    "fvg_time": str(row["fvg_time"].date()),
                    "top": float(row["top"]),
                    "bottom": float(row["bottom"]),
                    "gap_pct": row["gap_pct"],
                    "status": freshness["status"],
                    "retest_time": freshness.get("retest_time", ""),
                    "intrusion_pct": freshness.get("max_intrusion_pct", 0),
                    "current_price": current_price,
                    "price_to_fvg_pct": 0.0,  # 下面计算
                })
        return results
    except Exception as e:
        # 静默跳过单个交易对的错误
        return []






def fmt_price(value: float) -> str:
    """按价格量级自适应小数位，避免低价币 (PEPE/SHIB 等) 显示成 0.0000"""
    try:
        v = abs(float(value))
    except (TypeError, ValueError):
        return str(value)
    if v == 0:
        return "0"
    if v >= 1000:
        return f"{value:,.2f}"
    if v >= 1:
        return f"{value:.4f}"
    if v >= 0.01:
        return f"{value:.6f}"
    if v >= 0.0001:
        return f"{value:.8f}"
    return f"{value:.10f}"




# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(description="币安日线 FVG 扫描器")
    parser.add_argument("--min-volume", type=float, default=MIN_USD_VOLUME,
                        help=f"最小 24h 成交量 (USDT), 默认 {MIN_USD_VOLUME:,}")
    parser.add_argument("--top", type=int, default=TOP_VOLUME_COUNT,
                        help=f"扫描成交量前 N 名, 默认 {TOP_VOLUME_COUNT}")
    parser.add_argument("--max-age", type=int, default=FVG_MAX_AGE_DAYS,
                        help=f"FVG 最大年龄 (天), 默认 {FVG_MAX_AGE_DAYS}")
    parser.add_argument("--min-gap", type=float, default=FVG_MIN_SIZE_PCT,
                        help=f"FVG 最小缺口 (%%), 默认 {FVG_MIN_SIZE_PCT}")
    parser.add_argument("--proxy", type=str, default=None,
                        help="HTTP 代理, 如 http://127.0.0.1:7890")
    args = parser.parse_args()

    # 初始化交易所
    ccxt_kwargs = {"enableRateLimit": True}
    if args.proxy:
        ccxt_kwargs["proxies"] = {"http": args.proxy, "https": args.proxy}

    exchange = ccxt.binance(ccxt_kwargs)
    exchange.options["defaultType"] = "spot"

    # 加载黑名单
    blacklist = load_blacklist_from_config()
    print(f"      已加载 {len(blacklist)} 条黑名单规则")

    # 加载白名单
    whitelist = load_whitelist_from_config()
    print(f"      已加载 {len(whitelist)} 个白名单交易对")

    # 获取交易对
    pairs = fetch_spot_usdt_pairs(exchange, args.min_volume, args.top, blacklist)

    # 扫描
    print(f"[3/4] 扫描日线 FVG (每个 pair 间隔 {BINANCE_RATE_LIMIT_MS}ms)...")
    all_results = []
    total = len(pairs)
    for idx, symbol in enumerate(pairs):
        if (idx + 1) % 20 == 0 or idx == 0:
            print(f"      进度: {idx + 1}/{total} — {symbol} ...")
        res = scan_pair(exchange, symbol, LOOKBACK_DAYS, args.max_age, args.min_gap)
        all_results.extend(res)
        time.sleep(BINANCE_RATE_LIMIT_MS / 1000)

    # 计算当前价格到 FVG 的距离
    for r in all_results:
        cur = float(r["current_price"])
        # 防御: 现价无效 (0 / NaN) 时不做除法，避免除零 RuntimeWarning 与假距离
        if not np.isfinite(cur) or cur <= 0:
            r["price_to_fvg_pct"] = float("inf")
        elif r["type"] == "bullish":
            # FVG 在下方，计算价格到 FVG 上沿的距离
            r["price_to_fvg_pct"] = round((cur - r["top"]) / cur * 100, 2)
        else:
            # FVG 在上方，计算价格到 FVG 下沿的距离
            r["price_to_fvg_pct"] = round((r["bottom"] - cur) / cur * 100, 2)

    # 去重: 同一币种只保留距当前价格最近的 FVG (最 actionable)
    deduped = {}
    for r in all_results:
        sym = r["symbol"]
        if sym not in deduped or abs(r["price_to_fvg_pct"]) < abs(deduped[sym]["price_to_fvg_pct"]):
            deduped[sym] = r
    all_results = list(deduped.values())

   

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n已手动中断")
        sys.exit(130)
    except ccxt.BaseError as e:
        # 重试后仍失败的交易所/网络错误: 给出清晰提示而非整段 traceback
        print(f"\n错误: 交易所接口异常 ({type(e).__name__}: {e})，请检查网络/代理后重试")
        sys.exit(1)
