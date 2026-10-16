---
name: roblox-data
description: "Roblox player-save persistence: DataStore, ProfileStore, session locks, schemas, migrations, retries, shutdown, version history, RTBF deletion templates and DataStore limits. Use when writing, changing, debugging or auditing save code: data lost, rolled back, duplicated or not saving; adding a field to the save; changing currency or inventory storage; reviewing a save layer."
---

# Roblox data persistence

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

## When to use

Player saves, migrations, retries, shutdowns, session ownership. Leaderboard stores: see `roblox-lessons` `references/data.md` (Leaderboards). Open Cloud data-store access: `roblox-lessons` `references/open-cloud.md`.

## Our defaults (from `roblox-lessons` data.md)

- **Use ProfileStore** (MadStudioRoblox, session locking). The raw-DataStore patterns in `references/full.md` explain the mechanics and apply to non-profile stores; do not hand-roll a second lock around ProfileStore.
- **Studio saves to its own store:** `NAME .. "_Studio"` when `RunService:IsStudio()`; suffix leaderboard/ordered stores the same way. With Studio API access off, ProfileStore falls back to its in-memory mock by itself.
- **Never rename the DataStore to change the save format** (a new name is a new, empty store). Store `dataVersion` and migrate step by step: pure `Migrate(data, target)`, `Steps[v]` upgrades v to v+1 on a deep copy, each step in `pcall`, live data replaced only if every step succeeds, then `Reconcile()`. A save newer than the code, or a missing/failed step: end the session, leave the save untouched, kick with "please rejoin".
- Studio conveniences (starting grants, force-owned passes, test runners) are guarded by `RunService:IsStudio()`.

## Quick reference

- Serializable template plus a version field; deep-copy templates so nested defaults are never shared; migrate, then reconcile missing fields.
- `UpdateAsync` for read-modify-write on non-profile stores; bounded retries with backoff; a failed read is not an empty profile.
- ProfileStore: `StartSessionAsync` can return `nil` (never treat as new data); a custom `Cancel` callback disables the built-in timeout, so add your own deadline; `OnSessionEnd` kicks; `EndSession` on leave; no `Steal` in normal joins.
- `PlayerRemoving` alone is not enough; `BindToClose` finishes pending work.
- Store only primitives/arrays/dictionaries. Reject NaN/inf numbers and strings failing `utf8.len`; one bad value fails the whole write.
- RTBF: keep the user ID as a static substring in keys (`player_<UserId>`) so deletion templates can match.
- `GetAsync` serves a 4-second local cache; verify writes with `DataStoreGetOptions.UseCache = false`.
- Poll `GetRequestBudgetForRequestType` for live headroom instead of guessing quotas.
- `Player.User` is the documented identity for new code; `UserId` remains valid. Never mix the two in one key scheme.
- Ack a grant only after it is durably persisted; an unknown outcome is retried with the same idempotent operation, never re-granted.

> Details, code and limits: [references/full.md](references/full.md)
