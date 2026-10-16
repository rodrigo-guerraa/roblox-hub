# liveops/group-rewards — join-our-group reward and member bonus

## 1. What it does

**Player-facing:**
- A "Join our group!" card: **JOIN** opens Roblox's in-game join prompt. Once the player is a member, the button turns into **CLAIM**, which pays a one-time reward ("Claim $1.2M now, plus a bonus every 10 min!"). After that it reads **CLAIMED**.
- Members get a bonus every `INCOME_INTERVAL` while online.
- Optional world pads: stepping on any part tagged `GroupPad` does the same as the button (8 s cooldown).
- The card appears inside the Codes window (when `liveops/codes` is installed), in a small standalone "OUR GROUP" window the game can open with `UIManager.open("Group")`, and optionally on a HUD tile.

**Technical:**
- `GROUP_ID = 0` turns everything off. The server still creates its two remotes, then returns. The client module reports `enabled() == false`, so the codes card, the window and the pads stay out.
- **Periodic bonus:** for players `IsInGroup` at join, or after a successful claim. It pays `IncomePayout(income)` = `INCOME_SECONDS` of income (at least `INCOME_MIN`) every `INCOME_INTERVAL`, through `EconomyAPI.Grant(..., "group")`. A per-player token stops the loop on leave.
- **Join reward:** paid once per save (`groupJoinClaimed`, mirrored to the `GroupRewardClaimed` Player attribute). Each claim is checked against the live group list (`GroupService:GetGroupsAsync`), because `IsInGroup` is cached from join; if that call fails, it falls back to `IsInGroup`. There is a 3 s cooldown per player. It pays `JoinPayout(income)` = `JOIN_SECONDS` of income (at least `JOIN_MIN`) and replies with `GroupRewardResult`.
- **Client module** `GroupRewards.lua` is a singleton: membership state, `joinOrClaim(fromGui?)`, a `Changed` signal, and `mountCard(parent, props)`, which embeds a self-updating card anywhere. Result effects (coins, float text) start at the GUI that triggered the claim, or at the screen centre for a pad.
- `GroupRewardMath` (pure, with spec): `JoinPayout`, `IncomePayout`, `InGroupList`.

## 2. Depends on

- `systems/core`: remotes, data, economy (`GetIncome`, `Grant`, the `IncomePerSecond` attribute), format.
- `systems/ui/kit`: `UIStyle`, `Effects`, `SoundFX`, `Notice`; `UIManager`, `Icons` (`Icons.Friends`).

## 3. Install

| File | Destination |
| --- | --- |
| `server/GroupRewardService.server.lua` | `src/server/` |
| `client/GroupRewards.lua` | `src/client/` (ModuleScript; `CodesUI` finds it by this name) |
| `client/GroupRewardsUI.client.lua` | `src/client/` |
| `shared/GroupRewardsConfig.lua` | `src/shared/` |
| `shared/GroupRewardMath.lua` | `src/shared/` |
| `tests/GroupRewardMath.spec.lua` | `tests/` |

**DataTemplate:** add `groupJoinClaimed = false`.

**Config (`GroupRewardsConfig.lua`):**

| Key | Default | Meaning |
| --- | --- | --- |
| `GROUP_ID` | `0` | Your group's id. `0` = off. |
| `INCOME_INTERVAL` / `INCOME_SECONDS` / `INCOME_MIN` | `600` / `60` / `1000` | The member bonus: 60 s of income every 10 min is about +10% income |
| `JOIN_SECONDS` / `JOIN_MIN` | `300` / `5000` | The one-time join reward |
| `CLAIM_COOLDOWN` | `3` | Seconds between claim attempts |
| `PAD_TAG` / `PAD_COOLDOWN` | `"GroupPad"` / `8` | CollectionService tag for world pads, and the touch cooldown |
| `WINDOW_KEY` | `"Group"` | `UIManager` name of the standalone window |
| `HUD_TILE` / `HUD_ORDER` | `false` / `12` | Add a "Group" HUD tile that opens the window |
| `CLAIMED_ATTRIBUTE` | `"GroupRewardClaimed"` | Player attribute mirrored from the save |
| `REMOTE_CLAIM` / `REMOTE_RESULT` | `"ClaimGroupReward"` / `"GroupRewardResult"` | Remote names |

**World pad (optional):** tag any `BasePart` `GroupPad` (Studio Tag Editor, or `CollectionService:AddTag(part, "GroupPad")` in your map builder). Pads added later are wired too. Put a sign next to it; the system doesn't build one.

**Opening the card from game UI:** `UIManager.open("Group")`, or embed it:
`require(script.Parent.GroupRewards).mountCard(frame, { position = ..., size = ... })`.

## 4. Remotes

| Remote | Direction | Payload |
| --- | --- | --- |
| `ClaimGroupReward` | client → server | none. Ignored while data loads or within the cooldown. |
| `GroupRewardResult` | server → client | `{ ok, message, reward? }` ("You already claimed this!", "Join the group first!", "Thanks for joining!") |

## 5. Verify in Studio (MCP)

Set `GROUP_ID` to a group the test account is in (and a second run with one it isn't in).

1. `start_stop_play`, then `get_console_output`: no errors.
2. **Attribute:** `execute_luau` (Server): `player:GetAttribute("GroupRewardClaimed") == false` on a fresh save.
3. **UI:** (Client) `PlayerGui.GroupRewardsUI` exists. With codes installed, `PlayerGui.CodesUI...Body.GroupCard` exists and its `GroupButton.Label.Text` is `CLAIM` for a member, `JOIN` otherwise.
4. **Claim:** capture `GroupRewardResult` into a `LocalPlayer` attribute, then fire `ClaimGroupReward`. For a member: `ok = true`, `reward = JoinPayout(IncomePerSecond)`, `Currency` rose by it, the attribute flips to `true` and the button reads `CLAIMED`. For a non-member: "Join the group first!", no payout.
5. **Repeat / spam:** fire twice within 3 s: the second is silently ignored. After 3 s it replies "already claimed", with no payout.
6. **Bonus:** set `INCOME_INTERVAL = 10` and Play as a member. `Currency` rises by `IncomePayout` every ~10 s. Set it back afterwards.
7. **Pad:** create a temporary part tagged `GroupPad` (Edit or Server), walk onto it with `character_navigation`. For an unclaimed member a claim fires (result captured as in step 4). Delete the part afterwards.
8. **Off switch:** `GROUP_ID = 0`. No `GroupRewardsUI`, no card in the Codes window, no errors.
9. **Specs:** `GroupRewardMath.spec` passes.
10. **Not testable in Studio:** `PromptJoinAsync` (the join prompt) needs a live client in a published game. Test JOIN there, by joining from the prompt and then pressing CLAIM.

## 6. Origin

Extracted from the reference game's `src/server/GroupRewardService.server.lua`, the group card and `GroupPad` touch logic in `src/client/CodesUI.client.lua`, and `EconomyMath.GroupJoinPayout`.
- The plot-specific pad lookup (`Workspace.Plots.PlotN.GroupPad`) became the CollectionService tag `GroupPad`.
- The card became an embeddable `mountCard`, plus a standalone window and an optional HUD tile. The Codes window embeds it only when this module exists.
- The join-or-claim state moved into a shared client module, with a claim timeout so a dropped reply can't lock the button.
- `GroupJoinPayout` and the inline bonus formula became `GroupRewardMath`, with the group-list check made pure and tested.
- Income comes from `EconomyAPI` and the `IncomePerSecond` attribute; payment goes through `EconomyAPI.Grant`.
- "Bonus coins every 10 min" is now generic text computed from `INCOME_INTERVAL`.
- `GROUP_ID = 0` disables the system.
