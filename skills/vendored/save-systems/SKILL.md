---
name: save-systems
description: Engine-agnostic save-system design (what to persist, schema versioning, a migration chain, defensive loading, backups), adapted for Roblox DataStores with ProfileStore session locking. Use when designing or changing a Roblox player profile, adding, renaming or removing saved fields, bumping dataVersion, writing or testing migrations, deciding what to store vs recompute, handling saves from a newer server during a rolling update, or debugging lost or corrupted player data. It does not replace the roblox-lessons data.md facts, which win on any conflict.
---

# Save systems

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins. Read roblox-lessons `references/data.md` first.

A save is a serialized snapshot of authoritative state that outlives the code that wrote it. The hard parts are choosing *what* to save, never losing it to a bad write, and loading *old* saves after you ship an update.

## On Roblox

- **No files: DataStores, through ProfileStore.** Session locking stops two servers overwriting each other during fast server hops. ProfileStore auto-saves, saves on leave and on shutdown, and does the atomic read-modify-write for you. Don't hand-roll `GetAsync`/`SetAsync`.
- **One table per player** (`profile.Data`), mutated only by the server through one service API. The client never writes saves; it only displays what the server sends.
- **Never rename the DataStore to change the format.** A new name is a new, empty store, and everyone loses their progress. Migrate instead.
- **Studio uses its own store** (`NAME .. "_Studio"`), so playtests never touch live players. Guard Studio conveniences with `RunService:IsStudio()`.
- **Format limits:** values must be JSON-encodable.
  - No Instances, `Vector3`, `CFrame` or `Color3`: store numbers and strings.
  - No tables mixing array and string keys, and no sparse arrays.
  - No NaN or infinity.
  - There is a per-key size limit of about 4 MB.
- **Backups:** DataStores keep previous versions of a key for a limited time (`ListVersionsAsync`, `GetVersionAsync`), which is your rollback path. The Open Cloud API can read a live entry to confirm what was really saved.

## Workflow

1. **Decide the authoritative state.** Save data (ids, counts, levels, flags), never Instances or object references. Rebuild the world from data on load.
2. **Stamp `dataVersion`** in the template from day one.
3. **Load pipeline:**
   - Run `Migrate(data, DATA_VERSION)` on a deep copy. `Steps[v]` upgrades v to v+1; run each in `pcall`.
   - Replace the live data only if every step succeeds.
   - Then `Reconcile()` to fill new template fields.
   - Then validate (ids still exist in content, numbers sane).
4. **Outcomes:**
   - `current` or `migrated`: load normally.
   - `newer` (an old server during a rolling update), `missingStep` or `failed`: leave the save untouched, end the session and kick with "please rejoin".
   - Reset only pre-launch dev saves below a declared baseline, never live ones.
5. **Bump `DATA_VERSION` together with `Steps[old]`.** A spec should fail until every version from the baseline up has a step. Keep old steps forever.
6. **Store, don't derive.** Save choices and progress, and recompute derived values (income totals, multipliers) on load, so a formula change in a patch can't desync saves.
7. **Verify:**
   - Spec the migration chain against fixture saves from each shipped version.
   - Playtest with Studio API access on: save, rejoin, and confirm the state matches.

```lua
local function Migrate(data, target, steps)
	local v = data.dataVersion or 0
	if v > target then return "newer", data end
	if v == target then return "current", data end
	if v < BASELINE then return "reset", nil end
	local copy = deepCopy(data)
	while v < target do
		local step = steps[v]
		if not step then return "missingStep", data end
		if not pcall(step, copy) then return "failed", data end
		v += 1
		copy.dataVersion = v
	end
	return "migrated", copy
end
```

## Pitfalls

- Renaming the store, or wiping on a version mismatch.
- Loading a newer save with older code, which silently drops unknown fields on the next write.
- Migrations that mutate the live table and fail halfway.
- Saving Roblox datatypes or Instances, which are dropped or rejected on write.
- Mixed or sparse tables. Key by `tostring(id)`.
- Content removed in a patch (an item id) that crashes the load. Drop or substitute it during validation.
- Trusting the client with any saved value.
- Studio playtests writing to the live store.

## References

- `references/versioning-and-migration.md`: the version field, the migration chain and its rules, backups and rollback, format constraints, a load-time validation checklist, and store vs recompute.

Related: `roblox-lessons` (`data.md`, `monetization.md` for purchase-receipt dedupe stored in the save).

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `SOURCE.md`.
