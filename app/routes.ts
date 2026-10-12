import { type RouteConfig, index, layout, route } from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),
  // Server side proxy for CoinMarketCap (keeps the API key off the client).
  route("api/cmc", "routes/api-cmc.ts"),
  layout("routes/trade-layout.tsx", [
    route("trade/:symbol", "routes/trade-chart.tsx"),
  ]),
] satisfies RouteConfig;
