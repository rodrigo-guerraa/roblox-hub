# core/data — player saves

## 1. What it does

**Player-facing:** progress saves and comes back on every join, survives server hops without being overwritten, and is never wiped by an update.

**Technical:**
- One [ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) session per player (session locking, auto-save, save on shutdown).
- The store is `DataConfig.STORE_NAME`. In Studio it gets `DataConfig.STUDIO_SUFFIX` (`"_Studio"`), so playtests with "Enable Studio Access to API Services" really save without touching live players. With API access off, ProfileStore falls back to an in-memory store by itself. Keys are `DataConfig.KEY_PREFIX .. UserId`.
- Every loaded save goes through `SaveMigrations.Migrate(data, DataConfig.DATA_VERSION)` **before** `Reconcile()`:

  | Status | What happens |
  | --- | --- |
  | `current` / `migrated` | The (migrated) save loads. Steps run on a deep copy that only replaces the save when every step succeeds. |
  | `reset` | The save has no `dataVersion` or is below `MIGRATION_BASELINE` (pre-launch builds). It starts fresh from `DataTemplate`. |
  | `newer` | The save comes from a newer build (an old server during a rolling update). The session ends with the save untouched, and the player is kicked with "A newer version of the game is out! Please rejoin". |
  | `missingStep` / `failed` | The session ends with the save untouched, and the player is kicked with "please rejoin". A `warn` is logged. |

- After migration, `Reconcile()` fills in any template fields the save is missing.
- `lastSeen` is stamped on first load (the template holds `0`, meaning "set on load") and on leave.
- If the session is taken by another server, the player is kicked with a rejoin message.

### API: `shared.DataServiceAPI` (server)

Wait for it with `repeat task.wait() until shared.DataServiceAPI`. It is published before any yield, with every method attached.

| Member | Returns | Notes |
| --- | --- | --- |
| `GetData(player)` | the live, auto-saved `profile.Data` table, or `nil` | `nil` while loading, after leave, or for a non-Player |
| `WaitForData(player)` | the table, or `nil` | Yields until loaded. Returns `nil` as soon as the player leaves or the load fails or is refused. |
| `PlayerLoaded` | signal `(player, data)` | Fires once per join, after migration and reconcile. Supports `:Connect(fn)` (the connection has `:Disconnect()` and `.Connected`), `:Once(fn)` and `:Wait()`. |
| `HasPurchase(player, purchaseId)` | `boolean` | Receipt dedupe kept in the save. |
| `RecordPurchase(player, purchaseId)` | `boolean` (`true` = recorded or already there) | Keeps the last `DataConfig.PURCHASE_HISTORY` (50) ids. |

- `PlayerLoaded` is a small signal object rather than a `BindableEvent`, because a `BindableEvent` would deep-copy the data table and handlers would mutate a copy. Its methods mirror `RBXScriptSignal`. Each handler runs in its own thread.
- A script that may start after some players already loaded should use `WaitForData` per player instead of `PlayerLoaded`:

  ```lua
  local function onPlayer(player)
  	local data = DataServiceAPI.WaitForData(player)
  	if not data then return end
  	data.myField = data.myField or 0
  end
  Players.PlayerAdded:Connect(onPlayer)
  for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayer, p) end
  ```

- Systems mutate their own fields on the returned table directly, and must tolerate a missing field.

## 2. Depends on

Nothing.

## 3. Install

| File | Destination |
| --- | --- |
| `server/ProfileStore.lua` | `src/server/ProfileStore.lua` (vendored, unmodified) |
| `server/ProfileStore.LICENSE` | `src/server/ProfileStore.LICENSE` (Apache-2.0 notice; Rojo ignores it) |
| `server/DataService.server.lua` | `src/server/DataService.server.lua` |
| `shared/DataConfig.lua` | `src/shared/DataConfig.lua` |
| `shared/DataTemplate.lua` | `src/shared/DataTemplate.lua` |
| `shared/SaveMigrations.lua` | `src/shared/SaveMigrations.lua` |
| `shared/DataMigrations.lua` | `src/shared/DataMigrations.lua` (game-owned) |
| `tests/SaveMigrations.spec.lua` | `tests/SaveMigrations.spec.lua` |

Then:
- **Lint:** add `exclude = ["src/server/ProfileStore.lua"]` to the game's `selene.toml` under `std`. The vendored file has 8 style warnings, and it stays verbatim.
- **Config:** edit `DataConfig.lua`. Set `STORE_NAME` once before launch, and **never rename it afterwards**, because a new name is a new, empty store. The template's `Config.DATA_VERSION` is not read by this system; `DataConfig.DATA_VERSION` is the authority.
- **Template:** edit `DataTemplate.lua`. Add every field each installed system's README lists. Keep `dataVersion = DataConfig.DATA_VERSION` and `lastSeen = 0`.

### Changing the save format after launch

1. Bump `DataConfig.DATA_VERSION` from `v` to `v + 1`.
2. Add `[v] = function(data) ... end` to `DataMigrations.lua`, which upgrades a version-`v` save in place.

`SaveMigrations.spec` fails until every version from `MIGRATION_BASELINE` up to `DATA_VERSION - 1` has a step. Fields that are only *added* need no step logic (`Reconcile` fills them), but the version bump still needs an empty step.

## Saved fields

These are in the shipped `DataTemplate`:

| Field | Default | Owner |
| --- | --- | --- |
| `dataVersion` | `DataConfig.DATA_VERSION` | data |
| `lastSeen` | `0` (stamped `os.time()` on load and on leave) | data |
| `purchaseIds` | `{}` | data (receipt dedupe) |
| `currency` | `0` | core/economy |
| `totalEarned` | `0` | core/economy |

## 4. Remotes

None.

## 5. Verify in Studio (MCP)

1. **Clean start.** `start_stop_play` to start, then `get_console_output`. Expect no errors and no `DataService:` warnings. ProfileStore may note the mock store when API access is off.
2. **Loaded data.** `execute_luau` (Server):
   - Read `ServerScriptService.DataService` existing and `Players:GetPlayers()[1]`.
   - Don't read `shared.DataServiceAPI` from the MCP: its `shared` is sandboxed. Observe effects instead: with core/economy installed, the player's `Currency` attribute is a number once data loads.
3. **Migration path (spec).** Set `ReplicatedStorage.Tests:SetAttribute("RunTests", true)` in Edit, Play, and read the TestEZ output with `get_console_output`. Expect `SaveMigrations` to report 0 failures.
4. **Persistence** (with Studio API access on):
   - Grant currency through a temporary server script, or through `EconomyService` with `STUDIO_START_BALANCE`.
   - Stop, Play again, and confirm the `Currency` attribute kept the value.
   - Studio uses the `_Studio` store, so live data is never touched.
5. **Refused save.** Temporarily set `DataConfig.DATA_VERSION` one lower than the saved version, then Play.
   - Expect a kick with "A newer version of the game is out!".
   - Restore the version, Play again, and confirm the save is intact.

## 6. Origin

Extracted from the reference game (a shipped Roblox simulator):
- `src/server/DataService.server.lua`. Kept: the ProfileStore session flow, the Studio store suffix, migrate-before-reconcile, the kick statuses, `lastSeen`, and the `GetData` / `WaitForData` gating. All game getters and setters (coins, species, eggs, plates, rebirths, ...) were removed, and so was the Studio coin grant, which moved to core/economy as `STUDIO_START_BALANCE`. Added: the `PlayerLoaded` signal, a failed-load flag so `WaitForData` returns `nil` immediately, and argument validation.
- `src/shared/SaveMigrations.lua`. The baseline and steps now come from the game-owned `DataConfig.MIGRATION_BASELINE` and `DataMigrations.lua`, plus a NaN-version guard.
- `tests/SaveMigrations.spec.lua`. Adapted to `DataConfig`, with template-version and nil/NaN cases added.
- `src/server/ProfileStore.lua`. Copied verbatim: [MadStudioRoblox/ProfileStore](https://github.com/MadStudioRoblox/ProfileStore) by loleris, Apache-2.0. The file has no license header, so the license text ships next to it as `ProfileStore.LICENSE`.
