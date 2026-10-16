# Receipts (developer products)

## 1. What it does

**Player-facing:** every developer product the game sells is granted exactly once, even if the server crashes mid-purchase. Ships ready-made "money packs" that pay an hour (or N hours) of the player's income, so they stay worth buying at every stage.

**Technical:** `ReceiptService` owns the game's **only** `MarketplaceService.ProcessReceipt`. Systems and game code register products with `shared.ReceiptAPI.Register(productId, handler, kind)`; the service dispatches each receipt to its handler.

- **Dedupe by `PurchaseId` in the player's save** (`shared.DataServiceAPI.HasPurchase` / `RecordPurchase`, kept by core). A known id returns `PurchaseGranted` without granting again. The id is recorded **only after** the handler returns `true`.
- `NotProcessedYet` (Roblox retries later, the player is not charged twice) when: the product isn't registered, the player isn't in this server, their data doesn't load, the blocked check refuses it, the same `PurchaseId` is already being processed, or the handler returns anything but `true` / errors.
- Optional **blocked check** (`SetBlockedCheck(fn)`), used by `paid-random-items` to refuse Robux→currency products for restricted players.
- Every `kind = "currency"` entry in `ReceiptConfig.PRODUCTS` with a non-zero id is registered automatically: it pays `CurrencyPacks.Payout(def, EconomyAPI.GetIncome(player))` through `EconomyAPI.Grant(player, amount, "currency_pack")`.

## 2. Depends on

- `systems/core`: `shared.DataServiceAPI` (`WaitForData`, `GetData`, `HasPurchase`, `RecordPurchase`) and, for currency packs, `shared.EconomyAPI` (`Grant`, `GetIncome`).

## 3. Install

| File | Destination |
| --- | --- |
| `server/ReceiptService.server.lua` | `src/server/` |
| `shared/ReceiptConfig.lua` | `src/shared/` |
| `shared/CurrencyPacks.lua` | `src/shared/` |
| `tests/CurrencyPacks.spec.lua` | `tests/` |

- **DataTemplate fields:** none of its own (the purchase-id list belongs to core).
- **Config:** edit `ReceiptConfig.PRODUCTS`. Each currency pack is `{ key, kind = "currency", id, price, title, seconds, min }` (income-scaled: `max(min, income × seconds)`) or `{ ..., amount = N }` (flat). `price` is display-only and must match the dashboard. Remove the packs if the game sells no currency.
- **Ids:** create each product in the Creator Dashboard (Monetization → Developer Products, or the Open Cloud API) and paste its id. Keep prices ≥ 2 R$.
- **Make sure nothing else sets `ProcessReceipt`.** A second assignment silently replaces this one.

### Registering a product from another system or the game

```lua
local Receipts = shared.ReceiptAPI -- wait for it with a bounded loop if your script may start first
Receipts.Register(MyConfig.SKIP_PRODUCT_ID, function(player, receiptInfo)
	return MyService.GrantSkip(player) -- true only if something was actually granted
end, "skip")
```

Return `false` when there is nothing to grant (empty pool, already maxed): the purchase stays unprocessed instead of charging for nothing.

### `shared.ReceiptAPI`

| Function | Purpose |
| --- | --- |
| `Register(productId, handler, kind?) -> boolean` | `handler(player, receiptInfo) -> boolean`. Ignores id `0`. A second registration of the same id warns and replaces. |
| `Unregister(productId)` | |
| `IsRegistered(productId)` / `GetKind(productId)` | |
| `SetBlockedCheck(fn)` | `fn(player, productId, kind) -> boolean`; `true` refuses the receipt. An erroring check counts as blocked. |
| `IsBlocked(player, productId)` | |
| `Prompt(player, productId) -> boolean` | Server-side prompt that refuses unregistered or blocked products. |
| `HandleReceipt(receiptInfo)` | The `ProcessReceipt` body, exposed for testing. |

Client shop UIs read `CurrencyPacks.List()` and show the real amount: `CurrencyPacks.Payout(def, player:GetAttribute("IncomePerSecond"))` ("+$2.1M instantly", not "1 hour of income"). If `paid-random-items` is installed, check `PaidRandomItems.IsProductBlocked(player, def.id, def.kind)` before prompting and show `PaidRandomItems.MESSAGE` instead.

## 4. Remotes

None. Purchases are prompted with `MarketplaceService:PromptProductPurchase` (client) or `ReceiptAPI.Prompt` (server).

## 5. Verify in Studio (MCP)

Studio prompts are free test purchases, but fake receipts are faster and cover the refusals. `shared` read from MCP `execute_luau` is sandboxed, so the test runs in a **temporary Script**:

1. Write `src/server/TempReceiptTest.server.lua` (give a test pack a real or dummy id, e.g. `id = 1`, for the session):

   ```lua
   local Players = game:GetService("Players")
   repeat task.wait() until shared.ReceiptAPI and shared.EconomyAPI
   local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
   shared.DataServiceAPI.WaitForData(player)
   local function receipt(productId, purchaseId)
   	return { PlayerId = player.UserId, ProductId = productId, PurchaseId = purchaseId, CurrencySpent = 0, PlaceIdWherePurchased = game.PlaceId }
   end
   local before = shared.EconomyAPI.GetBalance(player)
   print("grant", shared.ReceiptAPI.HandleReceipt(receipt(1, "test-a")), shared.EconomyAPI.GetBalance(player) - before)
   print("repeat", shared.ReceiptAPI.HandleReceipt(receipt(1, "test-a")), shared.EconomyAPI.GetBalance(player) - before)
   print("unknown", shared.ReceiptAPI.HandleReceipt(receipt(999, "test-b")))
   print("no player", shared.ReceiptAPI.HandleReceipt({ PlayerId = -1, ProductId = 1, PurchaseId = "test-c" }))
   ```
2. `start_stop_play`, then `get_console_output`. Expect: `grant PurchaseGranted <payout>`, `repeat PurchaseGranted <same payout>` (granted once), `unknown NotProcessedYet`, `no player NotProcessedYet`. Check the payout equals `CurrencyPacks.Payout(def, income)` for the income shown in the `IncomePerSecond` attribute.
3. With `paid-random-items` installed, set the player's `PaidRandomRestricted` attribute to `true` from the Server datamodel and run a new `PurchaseId`: expect `NotProcessedYet` and no balance change.
4. Stop Play and delete the temp Script (and the dummy id).

## 6. Origin

Extracted from the reference game's `src/server/MonetizationService.server.lua` (single `ProcessReceipt`, `HandleReceipt` exposed for tests, save-backed dedupe) and the care packages (`EconomyMath.CarePackagePayout`, `Config.CARE_PACKAGE_*`). Changed: the hard-coded `GetProductKind` if-chain became a registry (`Register`), the paid-random-items check became a pluggable hook, care packages became config-driven `kind = "currency"` packs with a `min` floor or flat `amount`, and an in-flight guard was added per `PurchaseId`. Game-specific products (clone, hatch now, free hatch, collect ×N) stay in the game and register themselves.
