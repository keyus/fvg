import { redirect } from "react-router";

import { DEFAULT_SYMBOL } from "../lib/market";

export function loader() {
  return redirect(`/trade/${DEFAULT_SYMBOL}`);
}
