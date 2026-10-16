# Gamepasses

## 1. What it does

**Player-facing:** permanent passes work the moment they are bought (no rejoin), and are pitched in context ("step on this plate to collect everything — get the pass") with a cooldown. A pass that isn't on sale yet shows "<Title> isn't on sale yet!" instead of an error.

**Technical:** `GamepassService` checks every pass in `GamepassConfig.Passes` with `UserOwnsGamePassAsync` on join, flips ownership live on `PromptGamePassPurchaseFinished`, and mirrors it to the client as **Player attributes `Pass_<KEY>`** plus a `GamepassOwnership` remote (full map). Ownership is never saved (Roblox is the source of truth).

- Join tokens drop a stale load when the player left or rejoined during the async checks; a purchase landing mid-load is OR-merged, never downgraded.
- Checks that errored are retried when the client fires `RequestGamepasses` (rate limited to one per 2 s).
- `FORCE_OWNED_IN_STUDIO = true` makes every pass owned in Studio playtests only (`RunService:IsStudio()`).

## 2. Depends on

- `systems/core`: `Remotes`.
- `systems/ui/kit`: `Notice` (client, for `PassPrompt`).
- Optional: `monetization/paid-random-items` — `PassPrompt` won't offer passes listed in `PaidRandomItemsConfig.BLOCKED_PASSES` to restricted players.

## 3. Install

| File | Destination |
| --- | --- |
| `server/GamepassService.server.lua` | `src/server/` |
| `shared/GamepassConfig.lua` | `src/shared/` |
| `client/PassPrompt.lua` | `src/client/` |
| `tests/GamepassConfig.spec.lua` | `tests/` |

- **DataTemplate fields:** none.
- **Config:** `GamepassConfig.Passes` = ordered `{ key, id, price, title, description }` (menu order). `id = 0` = not on sale. `price` is display-only and must match the dashboard. Keys are what code checks (`HasPass(player, "DOUBLE_CURRENCY")`); the defaults are examples, rename freely (`OFFLINE_BOOSTER` is read by `offline-earnings`).
- **Ids:** create each pass (Creator Dashboard → Monetization → Passes, or Open Cloud) and paste its id.

> **The account that creates a pass owns it.** That includes passes created through an API key acting as you. The owner never sees the purchase prompt for their own passes, so **test buying with an alt account** (or `FORCE_OWNED_IN_STUDIO` for effects). Developer products can still be test-bought by the owner.

### `shared.GamepassAPI` (server)

| Function | Purpose |
| --- | --- |
| `HasPass(player, key) -> boolean` | |
| `GetOwnership(player) -> { [key] = boolean }` | A copy. |
| `IsLoaded(player)` / `WaitForOwnership(player, timeout = 10) -> boolean` | Wait before applying pass effects on join (e.g. offline earnings). |
| `Changed` (signal) | `(player, key)` on a live purchase; `(player, nil)` once ownership has loaded on join. |

### `PassPrompt` (client ModuleScript)

| Function | Purpose |
| --- | --- |
| `Owns(key)` | Reads the `Pass_<KEY>` attribute. |
| `OwnershipChanged(key)` | Attribute-changed signal for that pass. |
| `CanBuy(key)` | `false` for a policy-blocked pass (restricted player). |
| `Offer(key, cooldown?) -> boolean` | Prompts the purchase unless owned, blocked or within `cooldown` seconds of the last offer; id `0` shows the "isn't on sale yet" notice. |

A passes shop UI lists `GamepassConfig.Passes`, shows OWNED from `PassPrompt.Owns`, and buys through `PassPrompt.Offer(key)`.

## 4. Remotes

| Remote | Direction | Payload |
| --- | --- | --- |
| `GamepassOwnership` | Server → Client | `{ [key] = boolean }`, on join, after a live purchase, and on request |
| `RequestGamepasses` | Client → Server | none; re-sends the map after retrying errored checks (2 s cooldown) |

## 5. Verify in Studio (MCP)

1. Give one pass a real id. `start_stop_play`; `get_console_output` shows no `GamepassService` warnings.
2. Client datamodel `execute_luau`: read `LocalPlayer:GetAttribute("Pass_<KEY>")` for every key — all `false` (or all `true` with `FORCE_OWNED_IN_STUDIO`).
3. Client: `require(LocalPlayer.PlayerScripts.PassPrompt).Offer("<KEY with id 0>")` → returns `true` and the "isn't on sale yet!" notice appears (`screen_capture`).
4. Client: `Offer` a real-id pass → the Studio purchase prompt opens; complete it (free in Studio) → the attribute flips to `true` without rejoining, and a game effect gated on `HasPass` applies.
5. Client: fire `RequestGamepasses` 5 times in a row → only the first is answered within 2 s (capture `GamepassOwnership` payloads on an attribute and count them).

## 6. Origin

Dino Simulator `src/server/GamepassService.server.lua`, `src/client/PassPrompt.lua`, `src/shared/GamepassData.lua`. Changed: the global `Config.GAMEPASS_IDS` + `GamepassData` merged into one `GamepassConfig` list; ownership is mirrored as `Pass_<KEY>` attributes (PassPrompt reads those, no remote listener needed); the dino-specific `PlotService.RefreshHatchery` hook became the generic `Changed` signal; `RequestGamepasses` got a rate limit; titles with computed numbers (multipliers, PrismaRex odds) became plain strings the game fills in.
