# liveops/codes — promo codes

## 1. What it does

**Player-facing:** a "Codes" HUD tile opens the CODES window. The player types a code (any case, spaces ignored) and presses REDEEM or Enter. A valid code pays a reward once per player, with coins flying to the counter. The status line explains failures: unknown, expired, already used, or "slow down". When `liveops/group-rewards` is installed and enabled, the window also shows the "Join our group!" card under the code box.

**Technical:**
- Rewards are `seconds` of the player's income (`EconomyAPI.GetIncome`), never below `min`. A code stays worth having at any stage of a big-number game.
- `CodeData` (pure) normalises input (uppercase, no whitespace, max `MAX_LENGTH`), looks a code up (`active = false` retires it; optional `expires` is an `os.time()`), and computes the reward.
- The server takes one attempt per player per `ATTEMPT_COOLDOWN` (2 s), so codes can't be brute-forced. A faster attempt gets a "slow down" reply.
- Each code pays once per save (`redeemedCodes[CODE] = true`). The reward goes through `EconomyAPI.Grant(player, reward, "code")`, which also syncs the `Currency` attribute.
- `CodesUI` looks for the sibling client module `GroupRewards` (waiting up to 5 s). If it exists and is enabled, the window grows and mounts `GroupRewards.mountCard`. If not, the window stays code-only. Nothing in codes requires the group system.

## 2. Depends on

- `systems/core`: remotes (`Remotes.event`), data (`shared.DataServiceAPI`), economy (`shared.EconomyAPI`), format (`NumberFormat`).
- `systems/ui/kit`: `UIStyle`, `Effects`, `SoundFX` (client); `UIManager`, `Icons` (`Icons.Codes`) in ReplicatedStorage.
- Optional: `liveops/group-rewards` (group card in the window).

## 3. Install

| File | Destination |
| --- | --- |
| `server/CodeService.server.lua` | `src/server/` |
| `client/CodesUI.client.lua` | `src/client/` |
| `shared/CodesConfig.lua` | `src/shared/` |
| `shared/CodeData.lua` | `src/shared/` |
| `tests/CodeData.spec.lua` | `tests/` |

**DataTemplate:** add `redeemedCodes = {}`.

**Config (`CodesConfig.lua`):**

| Key | Default | Meaning |
| --- | --- | --- |
| `CODES` | two examples | `CODE = { seconds, min, description, expires?, active? }`. Keys must be uppercase with no spaces (the spec checks this). |
| `MAX_LENGTH` | `30` | Longest code a player can type |
| `ATTEMPT_COOLDOWN` | `2` | Seconds between attempts per player |
| `WINDOW_KEY` | `"Codes"` | `UIManager` name, so other UI can `UIManager.open("Codes")` |
| `HUD_ORDER` | `10` | Tile order in the menu dock |
| `HINT` | "Find codes in our Roblox group!" | Status line before the first attempt |
| `REMOTE_REDEEM` / `REMOTE_RESULT` | `"RedeemCode"` / `"CodeResult"` | Remote names |

No ids to create. Post codes in the group or on the game page, and retire them with `active = false` (keep the entry so the "already used" history stays meaningful).

## 4. Remotes

| Remote | Direction | Payload |
| --- | --- | --- |
| `RedeemCode` | client → server | `text: string`. Non-strings and strings over 200 chars are ignored; data must be loaded. |
| `CodeResult` | server → client | `{ ok, message, reward? }`. Always sent for a rate-checked attempt. |

## 5. Verify in Studio (MCP)

1. `start_stop_play`, then `get_console_output`: no errors, no `Remotes:` warnings.
2. **UI:** `execute_luau` (Client): `PlayerGui.CodesUI.Overlay.Panel.Body.CodeSection` exists, and `PlayerGui.HudDock` has a `CodesSlot`.
3. **Valid code:** in the Client, connect `CodeResult.OnClientEvent` to store the JSON-encoded payload as an attribute on `LocalPlayer`. Fire `RedeemCode` with `" re lease "`, then read the attribute back: `ok = true` and `reward >= 500`. On the Server, the player's `Currency` attribute rose by `reward`.
4. **Once only:** wait 2 s, fire `"RELEASE"` again: `ok = false`, "already used". `Currency` is unchanged.
5. **Rate limit:** fire twice within 2 s: the second reply says "Slow down".
6. **Forged input:** fire `42`, `nil`, `{}` and `string.rep("A", 500)`: no reply, no error in the output, `Currency` unchanged.
7. **Unknown / expired:** fire `"NOPE"` (reply "doesn't exist"). Add `OLD = { seconds = 1, min = 1, expires = 0 }` to the config, Play, fire `"old"`: reply "expired".
8. **Persistence:** with API access on, rejoin and fire `"RELEASE"`: still "already used".
9. **Specs:** set the `RunTests` attribute on `ReplicatedStorage.Tests` and Play. `CodeData.spec` passes.

## 6. Origin

Dino Simulator `src/shared/CodeData.lua`, `src/server/CodeService.server.lua`, `src/client/CodesUI.client.lua` and `tests/CodeData.spec.lua`.
- The code table moved to `CodesConfig.CODES`; `Reward` takes the game's income instead of dino's `PlateServiceAPI.GetActiveCPS`.
- Coins go through `EconomyAPI.Grant` instead of `DataService.AddCoins` plus an `UpdateCoins` fire.
- Remotes come from `Remotes.event` instead of `Config.EVENT_*`.
- The group card, the `GroupPad` touch wiring and the group remotes moved out to `liveops/group-rewards`; the window mounts that card only when the system is present.
- The spec gained checks that listed codes are normalised and that fractional income floors.
