---
name: 项目描述
description: 构建数据图表网页，从bianace 获取特定的交易对周期数据，通过引开源TradingView Lightweight Charts 进行网页渲染
license: MIT
---

# 数据图表分析

https://tradingview.github.io/lightweight-charts/docs/series-types#candlestick

- lightweight-charts 开源组件. 使用 pine-script/SuperOrderBlock.pine. 这个指标就行渲染

## traddingview高级插件

https://www.tradingview.com/widget-docs/widgets/charts/advanced-chart/

```html
<!-- TradingView Widget BEGIN -->
<div class="tradingview-widget-container" style="height:100%;width:100%">
  <div
    class="tradingview-widget-container__widget"
    style="height:calc(100% - 32px);width:100%"
  ></div>
  <div class="tradingview-widget-copyright">
    <a
      href="https://www.tradingview.com/symbols/NASDAQ-AAPL/"
      rel="noopener nofollow"
      target="_blank"
      ><span class="blue-text">AAPL stock chart</span></a
    ><span class="trademark">&nbsp;by TradingView</span>
  </div>
  <script
    type="text/javascript"
    src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js"
    async
  >
      {
      "allow_symbol_change": true,
      "calendar": false,
      "details": false,
      "hide_side_toolbar": true,
      "hide_top_toolbar": false,
      "hide_legend": false,
      "hide_volume": false,
      "hotlist": false,
      "interval": "D",
      "locale": "en",
      "save_image": true,
      "style": "1",
      "symbol": "NASDAQ:AAPL",
      "theme": "light",
      "timezone": "Etc/UTC",
      "backgroundColor": "#ffffff",
      "gridColor": "rgba(46, 46, 46, 0.2)",
      "watchlist": [],
      "withdateranges": false,
      "compareSymbols": [],
      "support_host": "https://www.tradingview.com",
      "studies": [],
      "autosize": true
    }
  </script>
</div>
<!-- TradingView Widget END -->
```

```tsx
// TradingViewWidget.jsx
import React, { useEffect, useRef, memo } from "react";

function TradingViewWidget() {
  const container = useRef();

  useEffect(() => {
    const script = document.createElement("script");
    script.src = "https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js";
    script.type = "text/javascript";
    script.async = true;
    script.innerHTML = `
        {
          "allow_symbol_change": true,
          "calendar": false,
          "details": false,
          "hide_side_toolbar": true,
          "hide_top_toolbar": false,
          "hide_legend": false,
          "hide_volume": false,
          "hotlist": false,
          "interval": "D",
          "locale": "en",
          "save_image": true,
          "style": "1",
          "symbol": "NASDAQ:AAPL",
          "theme": "light",
          "timezone": "Etc/UTC",
          "backgroundColor": "#ffffff",
          "gridColor": "rgba(46, 46, 46, 0.2)",
          "watchlist": [],
          "withdateranges": false,
          "compareSymbols": [],
          "support_host": "https://www.tradingview.com",
          "studies": [],
          "autosize": true
        }`;
    container.current.appendChild(script);
  }, []);

  return (
    <div
      className="tradingview-widget-container"
      ref={container}
      style={{ height: "100%", width: "100%" }}
    >
      <div
        className="tradingview-widget-container__widget"
        style={{ height: "calc(100% - 32px)", width: "100%" }}
      ></div>
      <div className="tradingview-widget-copyright">
        <a
          href="https://www.tradingview.com/symbols/NASDAQ-AAPL/"
          rel="noopener nofollow"
          target="_blank"
        >
          <span className="blue-text">AAPL stock chart</span>
        </a>
        <span className="trademark">&nbsp;by TradingView</span>
      </div>
    </div>
  );
}

export default memo(TradingViewWidget);
```

### traddingview OpenSource Pine script 脚本目录

- `项目根目录 /pine-script/`

#### bianance api 官方文档.

- api1-api4 会提供更好的性能
  `https://developers.binance.com/en/docs/products/spot/rest-api#`

#### 数据存储 dexie

- 所有数据，使用indexdb 浏览器本地储存
- 获取列表功能，根据配置交易对规则 对bianance现货交易对筛选
  |> a. 使用indexdb 本地储存
  |> b. 筛选完成后，拉取日k数据,开始复用fvg指标检测 参考 项目根目录 /fvg_scanner.py. 脚本规则.
  |> c. 每次获取，watchList会按时间新增一个下拉列表项,下拉列表可以删除单独b的项，可以清空所有列表项数据，并同步indexdb表
  |> d. 获取完成显示最新列表. 需要显示获取进度条.
- 点击列表商品，从binance拉取对应交易对，对应周期的k线. 最多1000根
- 更新图表按钮，手动更新当前显示商品，如当前左侧未显示商品,提示请选择一个商品
- 左侧显示的商品，每7秒自动拉取一次当前显示的商品，当前显示周期的k线数据,如未显示不拉取.并更新mark标记价,更新表
- 拉取规则：不需要每次都重新加载前几百根历史数据，只需要请求最新的 2~5 根 K 线（通过调整 limit=5），然后用 JS 替换图表中最后一根正在跳动的 K 线，这样能极大节省带宽和渲染开销。

#### coinmarket key doc

`https://coinmarketcap.com/api/documentation/pro-api-reference/endpoint-overview/`

```js
//请求商品名市值.
const baseUrl = `https://pro-api.coinmarketcap.com/v3/cryptocurrency/`;
//发起请求
//doc https://coinmarketcap.com/api/documentation/pro-api-reference/cryptocurrency/?lang=js
fetch("https://pro-api.coinmarketcap.com/v3/cryptocurrency/quotes/latest", {
  headers: {
    "X-CMC_PRO_API_KEY": "<api-key>",
  },
});

//请求项目信息
const url2 = `https://pro-api.coinmarketcap.com/v1/cryptocurrency/info?symbol=${symbol}`;
```
