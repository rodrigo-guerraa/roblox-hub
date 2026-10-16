# Paid random items (policy + odds disclosure)

## 1. What it does

Roblox treats a random reward as a **paid random item** when it can be bought with Robux, directly or indirectly. If your currency can be bought with Robux (money packs, offline doubling, "collect ×N"), **every roll paid with that currency is a paid random item**, as are Robux shortcuts into a roll (e.g. "open this egg free for R$5") and passes that change the odds or add pass-only outcomes. Then the policy requires:

1. **Disclose the odds before purchase.** Every possible outcome with its exact chance, summing to 100% (mark "rounded" if you round), shown before the player pays (coins or Robux). Compute them with the same code the server rolls with. Odds-changing passes state their effect in numbers ("adds X: 0.42% per roll").
2. **Block restricted players.** Some regions (`PolicyService:GetPolicyInfoForPlayerAsync(player).ArePaidRandomItemsRestricted`) can't buy paid random items. For them: no Robux→currency products and no Robux→roll shortcuts (UI shows a notice, the server refuses the receipt), no odds-changing passes, and pass-only outcomes are left out of their rolls. Their currency is then earned only, so their rolls are no longer paid random items.
3. **Answer "yes" to paid random items** in the Maturity & Compliance questionnaire (Creator Dashboard).

**Technical:**

- `RandomItemPolicyService` looks the policy up on join (3 tries, backing off) and writes the server-only `PaidRandomRestricted` Player attribute. A lookup that keeps failing writes `true`. It then hooks `PaidRandomItems.IsProductBlocked` into `shared.ReceiptAPI.SetBlockedCheck`, so blocked receipts return `NotProcessedYet`.
- `PaidRandomItems` (shared): `IsRestricted` treats **unknown as restricted** (attribute not set yet = blocked).
- `OddsDisclosure` (shared, pure): exact per-item odds from group weights and item pools, plus a `Roll` that uses the same pools, so the shown odds are the real odds.

## 2. Depends on

- `monetization/receipts` (the blocked-check hook; without it a warning is printed and receipts aren't blocked).
- Optional: `monetization/gamepasses` (`PassPrompt` reads `BLOCKED_PASSES`), `monetization/offline-earnings` (hides the doubling button).

## 3. Install

| File | Destination |
| --- | --- |
| `server/RandomItemPolicyService.server.lua` | `src/server/` |
| `shared/PaidRandomItems.lua` | `src/shared/` |
| `shared/PaidRandomItemsConfig.lua` | `src/shared/` |
| `shared/OddsDisclosure.lua` | `src/shared/` |
| `tests/OddsDisclosure.spec.lua`, `tests/PaidRandomItems.spec.lua` | `tests/` |

- **DataTemplate fields:** none (the policy is looked up every session).
- **Config (`PaidRandomItemsConfig`):** `BLOCKED_PRODUCT_KINDS` (ReceiptAPI `kind`s; defaults `currency` and `offline_double`), `BLOCKED_PRODUCT_IDS` (`{ [id] = true }` for products registered without a kind), `BLOCKED_PASSES` (`{ [GamepassConfig key] = true }`), `MESSAGE`, `LOOKUP_ATTEMPTS`. Add every Robux→currency or Robux→roll product the game sells.
- If the game has **no random rolls** at all, you don't need this system.

### `PaidRandomItems`

| Function | Purpose |
| --- | --- |
| `ATTRIBUTE`, `MESSAGE` | `"PaidRandomRestricted"`, the notice text |
| `IsRestricted(player)` | `true` unless the attribute is exactly `false` |
| `IsProductBlocked(player, productId, kind)` | the ReceiptAPI blocked check; use it on the client before prompting |
| `IsProductKindBlocked(productId, kind)` | the config part only (hide a whole shop section) |
| `IsPassBlocked(player, key)` / `PassAffectsRolls(player, key)` | don't sell the pass / leave its outcomes out of this player's roll |

### `OddsDisclosure`

```lua
local groups = { -- ordered; items are any tables with a `name`, `passKey` marks pass-only items
	{ key = "Common", items = { { name = "Cat" }, { name = "Dog" } } },
	{ key = "Secret", items = { { name = "Dragon" }, { name = "Phoenix", passKey = "VIP" } } },
}
local weights = { Common = 95, Secret = 5 } -- apply event boosts before passing them in
local function canRoll(item) return item.passKey == nil or (hasPass(item.passKey) and PaidRandomItems.PassAffectsRolls(player, item.passKey)) end

OddsDisclosure.Items(groups, weights, canRoll)       -- { { item, group, percent } } sorted by chance, sums to 100
OddsDisclosure.Roll(groups, weights, canRoll, rng)   -- server roll over the same pools -> item, groupKey
OddsDisclosure.Format(percent)                       -- "0.42%" / "12.3%"
OddsDisclosure.PassItemChance(groups, weights, "VIP") -- the chance the pass adds, for its description
```

Without `allow`, items with a `passKey` are excluded and all others roll. Groups whose weight is positive but whose pool is empty are left out of the total, so the list always sums to 100. Show the top few on the buy card with a "See all odds" list, and the same list wherever the roll is bought.

## 4. Remotes

None. The attribute replicates the policy to the client.

## 5. Verify in Studio (MCP)

1. `start_stop_play`; Client `execute_luau`: `LocalPlayer:GetAttribute("PaidRandomRestricted")` is a boolean (Studio normally reports `false`). `get_console_output` has no `RandomItemPolicyService` warning.
2. Server `execute_luau`: set the player's `PaidRandomRestricted` to `true`. In the game's shop the money packs / doubling button show `MESSAGE` or hide; a fake receipt for a blocked product (see the receipts README temp Script) returns `NotProcessedYet` and grants nothing; a non-blocked product still grants.
3. Set it to `nil`: still blocked (unknown = restricted). Set `false`: allowed again.
4. Run the specs (`Tests.RunTests = true`, Play): `OddsDisclosure` and `PaidRandomItems` pass. Compare the game's odds card numbers with `OddsDisclosure.Items` for the same weights.

## 6. Origin

Dino Simulator `src/server/RandomItemPolicyService.server.lua`, `src/shared/PaidRandomItems.lua`, `src/shared/HatchOdds.lua` (+ `tests/HatchOdds.spec.lua`). Changed: the hard-coded blocked product kinds/passes moved to `PaidRandomItemsConfig` (plus a by-id list); the receipt check became a hook into `ReceiptAPI` instead of an inline line in `MonetizationService`; `HatchOdds` (tied to `BurrowData`/`DinoData`/Lucky Hatch) became `OddsDisclosure` over caller-supplied groups and weights, gained `Roll` (dino rolled with `RarityUtil` separately), excludes empty weighted groups from the total, and `PassItemChance` sums every item behind the pass.
