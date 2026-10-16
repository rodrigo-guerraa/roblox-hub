# Offline earnings

## 1. What it does

**Player-facing:** coming back after a while shows a WELCOME BACK! popup with what they earned while away (a share of their income, up to a cap). COLLECT pays it out with flying coins. COLLECT 2X (R$) doubles the pending amount, then DOUBLE AGAIN at the next, higher price, up to ×32. Players without the Offline Booster pass see what it would do for them ("earn 2x while you're away!").

**Technical:** on join, `OfflineEarningsService` reads `lastSeen` (kept by core), computes `OfflineMath.Earnings(income, secondsAway, rate, cap)` with `EconomyAPI.GetIncome`, adds it to the saved `offlinePool` and pushes it to the client. `CollectOffline` grants the pool via `EconomyAPI.Grant(player, pool, "offline")` and resets the pool and the ladder.

- `rate` = `RATE` (0.5), or `BOOSTED_RATE` (1) with the `BOOSTER_PASS_KEY` gamepass (waits for gamepass ownership on join).
- `cap` = `CAP_SECONDS` (8 h) of income at that rate, × an optional game multiplier (`SetCapMultiplier`, e.g. a rebirth upgrade).
- Absences shorter than `MIN_AWAY_SECONDS` (60 s) earn nothing (quick rejoins don't pop up).
- **Doubling ladder:** `DOUBLE_PRODUCTS` are registered with `ReceiptAPI` (kind `offline_double`). Any step's product grants **one** double (a stale double-click still pays fairly); an empty pool or a finished ladder returns `false`, so the receipt stays `NotProcessedYet` instead of charging for nothing. Leaving doesn't reset the ladder; collecting does. A flat-price repeatable "double" would be infinitely stackable, hence the ladder.
- Earnings are computed once per join; the pool persists across sessions until collected.

## 2. Depends on

- `systems/core`: `Remotes`, `shared.DataServiceAPI`, `shared.EconomyAPI` (`GetIncome`, `Grant`), `NumberFormat`, and `lastSeen` in the save.
- `systems/ui/kit`: `UIStyle`, `Effects`, `Notice`, `Icons`.
- `monetization/receipts` (to sell the doubles; without it the doubles aren't sold and a warning is printed).
- Optional: `monetization/gamepasses` (booster pass + `PassPrompt` offer), `monetization/paid-random-items` (hides/blocks doubling for restricted players).

## 3. Install

| File | Destination |
| --- | --- |
| `server/OfflineEarningsService.server.lua` | `src/server/` |
| `client/OfflinePopup.client.lua` | `src/client/` |
| `shared/OfflineConfig.lua` | `src/shared/` |
| `shared/OfflineMath.lua` | `src/shared/` |
| `tests/OfflineMath.spec.lua` | `tests/` |

- **DataTemplate fields:** `offlinePool = 0`, `offlineDoubles = 0` (times the current pool was doubled; reset to 0 when collected). Reads core's `lastSeen` (unix seconds of the last leave). **Core must not overwrite `lastSeen` with the join time before this service reads it** (setting it on leave, or 0 → now for brand-new saves, is fine).
- **Config (`OfflineConfig`):** `RATE`, `BOOSTED_RATE`, `BOOSTER_PASS_KEY` (`""` = no booster; otherwise add that key to `GamepassConfig.Passes`), `CAP_SECONDS`, `MIN_AWAY_SECONDS`, `DOUBLE_PRODUCTS` (`{ id, price }` ladder; `price` display-only), `TITLE`, `LEAD`.
- **Ids:** create one developer product per ladder step (default R$ 9/19/39/79/159). A step with id `0` is never offered.
- If paid random items apply to the game, keep `offline_double` in `PaidRandomItemsConfig.BLOCKED_PRODUCT_KINDS` (it turns Robux into currency).

### `shared.OfflineEarningsAPI` (server)

| Function | Purpose |
| --- | --- |
| `GetPool(player)` / `GetDoubles(player)` | |
| `Collect(player) -> number` | Grants and clears the pool (what the remote calls). |
| `GrantDouble(player) -> boolean` | The receipt handler. |
| `SetCapMultiplier(fn)` | `fn(player) -> number` multiplies the cap (default 1). |

## 4. Remotes

| Remote | Direction | Payload |
| --- | --- | --- |
| `OfflineEarnings` | Server → Client | `{ amount, capped, doubles, maxDoubles, collected? }`; `amount = 0` closes the popup, `collected` is the amount just paid |
| `CollectOffline` | Client → Server | none; ignored without loaded data or an empty pool |
| `RequestOffline` | Client → Server | none; re-sends a non-empty pool (1 s cooldown). The popup fires it on startup in case it missed the join push. |

## 5. Verify in Studio (MCP)

1. Make Studio saves persist (API access on). Play once, stop, then edit the Studio save's `lastSeen` to `os.time() - 7200` (or wait 2+ minutes between plays) and give the player some income.
2. `start_stop_play`; Client `execute_luau`: capture `OfflineEarnings` payloads on a `LocalPlayer` attribute; the popup `PlayerGui.OfflinePopupGui.OfflinePopup` exists; `screen_capture` it. `amount` = `floor(income × seconds × 0.5)` (≤ 8 h cap).
3. Client: fire `CollectOffline` → `Currency` attribute rises by `amount`, payload `{ amount = 0, collected = amount }`, popup closes. Fire it again → nothing changes.
4. Doubling with fake receipts (receipts README temp Script, `ProductId` = step 1 id, new `PurchaseId` each time): pool doubles, `doubles` increments, the button reads DOUBLE AGAIN with the next price; after 5 doubles a 6th returns `NotProcessedYet`; with an empty pool `NotProcessedYet`.
5. Booster: with `FORCE_OWNED_IN_STUDIO` the rate is 1.0 and the booster button is hidden; without it the purple button opens `PassPrompt.Offer`.
6. Restricted: set `PaidRandomRestricted = true` (Server) → the double button disappears and a double receipt returns `NotProcessedYet`.

## 6. Origin

Dino Simulator: the offline block of `src/server/PlateService.server.lua` (join computation, `CollectOffline`), `grantOfflineDouble` in `MonetizationService.server.lua`, `EconomyMath.OfflineEarnings`, the offline helpers in `DataService.server.lua`, and the welcome-back popup in `src/client/MonetizationUI.client.lua`. Changed: CPS → `EconomyAPI.GetIncome`; the `offlineCap` rebirth upgrade became `SetCapMultiplier`; data helpers became direct field access on the profile; the `nil` payload became `{ amount = 0, collected }`; added `MIN_AWAY_SECONDS`, `RequestOffline`, a collect-button debounce, and the product registration through `ReceiptAPI`; the popup lives in its own ScreenGui instead of the shop window's.
