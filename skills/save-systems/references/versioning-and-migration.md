# Save versioning, migration and robustness

Saves outlive the code that wrote them. A player who saved last month expects to load after every update. Plan for schema evolution from the first release. Where this conflicts with `roblox-lessons` (`references/data.md`), `roblox-lessons` wins.

## The version field is non-negotiable

Stamp every save with a single monotonic integer (`dataVersion`). On load:

1. Read `dataVersion`.
2. If it is **newer** than the running code, refuse. On Roblox this happens during rolling updates, when an old server meets a save written by a new one. Leave the save exactly as stored, end the session and kick with a rejoin message. Never guess at unknown fields, and never write the save back (that would drop them).
3. If it is **older**, run the migrations in sequence until it matches.
4. Reconcile the template defaults, validate, then use it.

## The migration chain

Write each migration as a step `v → v+1` and apply them in order: `Steps[1]` upgrades 1 to 2, `Steps[2]` upgrades 2 to 3, and so on. Any version reaches current through small, testable steps, never one giant "convert anything to latest" function.

Rules:

- **Run on a deep copy, each step in `pcall`.** Replace the live data only if every step succeeded. A half-migrated save must never be written.
- **Additive changes:** with ProfileStore, `Reconcile()` fills new template fields with their defaults. The version bump still gets a step, even an empty one, so the chain stays complete and the spec stays green.
- **Renames and restructures:** move or transform the data in the step. Game code never reads both the old and the new name.
- **Removed fields:** drop them in the step, so later steps and `Reconcile` see a clean shape.
- **Keep old steps forever.** Deleting `Steps[1]` strands every version-1 save, and steps are cheap to keep.
- **Test the chain:** keep fixture saves from each shipped version in a spec (TestEZ or similar), and assert they migrate and validate after every change. Add a spec that fails if any version from the baseline to `DATA_VERSION - 1` lacks a step.
- **Pre-launch baseline:** saves older than a declared `BASELINE` (dev builds before launch) may be reset. After launch, the baseline never moves forward past real player saves.

## Backups and rollback

- ProfileStore and `UpdateAsync` make each write atomic, so a crash leaves either the old or the new save, never half of one.
- DataStores keep previous versions of each key for a limited time (`ListVersionsAsync` and `GetVersionAsync`). That is the rollback path when a bad release corrupts saves: find the last good version and restore it with a one-off server tool.
- With a key that has `universe-datastores.objects:read`, the Open Cloud API can read a live entry to confirm what the server really saved.
- Outside Roblox, for local files, the same idea is: write to a temp file, then rename over the target, and keep a `.bak` of the previous save.

## Format constraints (Roblox DataStores)

| Rule | Why |
| --- | --- |
| JSON-encodable values only: tables, strings, numbers, booleans | Instances and Roblox datatypes (`Vector3`, `CFrame`, `Color3`) can't be stored. Save their components as numbers. |
| A table is either a proper array or string-keyed | Mixed tables and sparse arrays lose entries or fail to save |
| No NaN or infinity | They don't survive JSON |
| Stay well under about 4 MB per key | Large saves are slow and hit the limit; cap histories (for example, keep the last 50 purchase ids) |
| Valid UTF-8 strings | Invalid strings fail to encode |

Keep the in-memory shape (`profile.Data`) as the canonical schema. Migrations operate on that shape, not on serialized bytes.

## Load-time validation checklist

- Required keys are present and the types are correct.
- Numbers are within sane ranges: no negative coins, levels at least 1, indices in bounds.
- Ids still exist in the current content (a species or item removed in a patch): drop or substitute them, don't crash.
- References resolve (a quest id points to a known quest).
- On any failure, log it and keep the stored save untouched. Ending the session with a clear message is better than playing on a broken state that will then be saved.

## What to store vs recompute

- **Store** authoritative, non-derivable state: discoveries, levels, inventory, flags, the progression counters, timestamps (`lastSeen`), and purchase receipt ids.
- **Recompute** derived data on load: income per second, multipliers, totals, unlock lists that follow from a tier. Saving derived data invites desync when a formula changes in a patch, and bloats the save.
- **Never store** gamepass ownership as truth. Query it live; the platform is the source of truth.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `../SOURCE.md`.
