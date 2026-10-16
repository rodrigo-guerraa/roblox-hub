# Saving and data lessons

## Persistence
- Use **ProfileStore** (MadStudioRoblox, session locking). Plain `GetAsync`/`SetAsync` lets two servers overwrite each other's save during fast server hops.
- Keep live data as one table per player (`profile.Data`) and mutate it through one service API; ProfileStore auto-saves it.
- **Studio saves to its own store** (`NAME .. "_Studio"`), so playtests with "Enable Studio Access to API Services" really save without touching live players. With API access off, ProfileStore falls back to an in-memory mock by itself. Suffix leaderboard/ordered stores the same way.
- Studio conveniences (starting-coin grants, force-owned passes, test runner) must be guarded by `RunService:IsStudio()` — check before every launch.

## Migrations (never wipe)
- **Never rename the DataStore to change the format** — a new name is a new empty store; everyone restarts.
- Store `dataVersion`. Run every loaded save through a pure `Migrate(data, target)`: `Steps[v]` upgrades v → v+1, on a deep copy, each step in `pcall`, replacing the live data only if every step succeeds. Then `Reconcile()` fills new template fields.
- Outcomes: current / migrated load; a save **newer** than the code (old server during a rolling update) or a missing/failed step → end the session, leave the save untouched, kick with "please rejoin".
- A spec should fail until every version from the baseline up has a step.

## Initial sync
- A queued RemoteEvent payload is delivered only to the **first** client listener. If several client scripts need the on-join push, each fires a `Request*` remote on startup to get its own copy (the server handler re-sends, never mutates).
- A loading screen should wait for the list of on-join events, re-request any it missed, and time out with a warning naming them.

## Reading live saves (Open Cloud)
- With a key that has `universe-datastores.objects:read`, `GET /cloud/v2/universes/{u}/data-stores/{store}/entries/{key}` returns a player's stored profile — useful to confirm what the server really saved during a live test.

## Leaderboards
- OrderedDataStore values must be integers; keep display metadata (name, rarest item) in a normal store; refresh on a timer and on the events that change rank.
