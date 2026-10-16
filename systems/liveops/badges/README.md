# liveops/badges — save-driven badge awarding

## 1. What it does

**Player-facing:** players get Roblox badges for milestones the game defines (welcome, first purchase, a currency milestone in the shipped examples). Anyone who already qualifies gets a badge as soon as its id goes live, because badges are judged from the save, not from events.

**Technical:**
- The game owns `BadgeDefinitions.lua`:
  - `All` is a list of `{ key, name, description, earned(state) }`.
  - `StateFromProfile(data, context)` turns the save into the numbers the badges check. `context.balance` is `EconomyAPI.GetBalance(player)`; add more context in the service if the game needs live values.
- `BadgeConfig.IDS` maps each key to a badge id. `0` = not created yet, and the badge is skipped.
- `BadgeAwardService` judges each player on join and every `CHECK_INTERVAL` (5 s). For each badge that is earned, live and not yet in `badgesAwarded`:
  - It calls `BadgeService:AwardBadgeAsync`. If that errors or returns false, it asks `UserHasBadgeAsync`; owning the badge already counts as awarded.
  - A badge is recorded in the saved `badgesAwarded[KEY] = true` once awarded or owned.
  - A failure is retried after `RETRY_SECONDS` (60 s), not every check.
  - A badge definition that errors is caught and `warn`ed, and the player is checked again next round.
- `BadgeEngine` (pure, with spec): `Earned`, `Pending` (earned, live id, not yet awarded), `Validate` (definitions vs ids: missing ids, strays, duplicates, missing functions), `ByKey`.
- `shared.BadgeAPI` (published before any yield):
  - `Check(player)` judges now. Call it right after a big moment so the badge pops without waiting for the loop.
  - `HasAwarded(player, key)` → boolean.

## 2. Depends on

- `systems/core`: data (`shared.DataServiceAPI`, the `purchaseIds` receipt field used by the example `FIRST_PURCHASE`), economy (`GetBalance`, for the example `MILLIONAIRE`).
- No UI. Roblox shows its own "badge awarded" toast.

## 3. Install

| File | Destination |
| --- | --- |
| `server/BadgeAwardService.server.lua` | `src/server/` |
| `shared/BadgeConfig.lua` | `src/shared/` |
| `shared/BadgeDefinitions.lua` | `src/shared/` (game-owned; replace the examples) |
| `shared/BadgeEngine.lua` | `src/shared/` |
| `tests/BadgeEngine.spec.lua` | `tests/` |

**DataTemplate:** add `badgesAwarded = {}`.

**Config (`BadgeConfig.lua`):**

| Key | Default | Meaning |
| --- | --- | --- |
| `IDS` | `{ WELCOME = 0, FIRST_PURCHASE = 0, MILLIONAIRE = 0 }` | One entry per definition key (the spec fails on missing or stray keys) |
| `CHECK_INTERVAL` | `5` | Seconds between checks |
| `RETRY_SECONDS` | `60` | Back-off after a failed award |

**Ids to create:** for each badge, create it on the Creator Dashboard (Experience → Engagement → Badges), using `name` and `description` from the definitions plus a 512×512 image. Paste each id into `IDS`.

**Writing definitions:** keep `earned` pure and cheap; it runs every 5 s per player. Read only from `state`, and put every derived number in `StateFromProfile`. Make it tolerate missing fields (`data.x or 0`), because an old save won't have new fields. For a "do X once" badge that the save can't express, have your system store a counter or flag in the save and read it here.

## 4. Remotes

None.

## 5. Verify in Studio (MCP)

Badges can be awarded in Studio only for badges of the place's own universe. Use a test badge.

1. `start_stop_play`, then `get_console_output`: no errors and no `[Badges] judging failed`.
2. **Skipped while 0:** with every id `0`, nothing is awarded. Check through a temporary server script, because MCP `shared` is sandboxed: it reads `shared.DataServiceAPI.GetData(p).badgesAwarded` and writes `HttpService:JSONEncode(...)` to a player attribute. Expect `{}`.
3. **Award:** put a real test badge id in `IDS.WELCOME` and Play. Within 5 s the attribute shows `WELCOME = true`, and the output has no warnings. On a second Play it stays recorded and no new award call is made. To confirm, add a `print` to a temporary copy, never to the real service.
4. **Already owned:** remove `WELCOME` from the save (the temp script sets `badgesAwarded.WELCOME = nil`). The next check records it again via `UserHasBadgeAsync`.
5. **Bad id:** set `IDS.WELCOME` to an id from another universe. It isn't recorded, and the retry waits 60 s instead of spamming every 5 s (watch the console or count calls in the temp copy).
6. **Specs:** `BadgeEngine.spec` passes. Its "line up with BadgeConfig.IDS" case fails if a definition and an id entry drift apart.

## 6. Origin

Extracted from the reference game's `src/shared/BadgeData.lua`, `src/server/BadgeAwardService.server.lua` and `tests/BadgeData.spec.lua`.
- The reference game's badges and `StateFromProfile` (hatches, rebirths, mutations, dex, park level) were replaced by a game-owned `BadgeDefinitions.lua` with three core-only examples.
- The judging logic moved into the pure `BadgeEngine` (`Pending` also skips ids that are `0`; `Validate` is new).
- `BadgeService.AwardBadge` (deprecated) became `AwardBadgeAsync`.
- Judging is `pcall`ed, so a broken definition can't wedge a player's check flag.
- `shared.BadgeAPI` (`Check`, `HasAwarded`) is new.
- `Config.BADGE_IDS` became `BadgeConfig.IDS`.
