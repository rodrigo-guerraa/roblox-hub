# Source

| | |
| --- | --- |
| Upstream | https://github.com/gamedev-skills/awesome-gamedev-agent-skills |
| Path | `skills/disciplines/save-systems/` |
| Pinned commit | `0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd` |
| License | Apache-2.0. `LICENSE` and `NOTICE` are copied verbatim from the upstream repo root. |
| Vendored | 2026-10-16 |

## Files taken

- `SKILL.md` → `SKILL.md` (modified)
- `references/versioning-and-migration.md` → `references/versioning-and-migration.md` (modified)
- `LICENSE`, `NOTICE` (from the repo root, unmodified)

Nothing else was taken. Upstream has no `scripts/` or `agents/` files for this skill; no code from upstream is executed.

## Modification notice (Apache-2.0 §4(b))

**These files were modified.** `SKILL.md` and `references/versioning-and-migration.md` are substantially rewritten, and each one carries a "Modified; see SOURCE.md" footer. The engine-agnostic design substance is kept; the changes are listed below.

## Changes we made

- Frontmatter: `name` kept as the folder name; `description` rewritten (under 900 chars) to say it is engine-agnostic guidance and when to use it in a Roblox game.
- Added the line "Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins." near the top of every file, and an "On Roblox" section to SKILL.md.
- Refocused on versioning and migration, aligned with roblox-lessons data.md: ProfileStore session locking, one server-owned table per player, never rename the DataStore, a separate Studio store, a Migrate pipeline on a deep copy with pcall per step then Reconcile, the current/migrated/newer/missingStep/failed outcomes with kick-and-leave-untouched, and a spec that requires a step for every version.
- Removed the file-system material (save slots, autosave cooldowns, temp-file + rename code, user:// paths, locale float notes) and all GDScript/Python samples. Kept a one-line non-Roblox note on temp+rename+.bak. Added a Luau Migrate sketch.
- Upstream migrate() ran steps in place and defaulted a missing version to 1. Ours runs on a deep copy, treats a missing version as 0, and refuses newer saves without writing them back.
- Added Roblox format constraints (JSON-encodable only, no Instances/Roblox datatypes, no mixed or sparse tables, no NaN/inf, about 4 MB per key), DataStore version history for rollback, the Open Cloud live-entry read, a pre-launch BASELINE reset rule, and 'never store gamepass ownership'.
- Removed references to the roblox-datastores, godot-resources and unity-scriptableobjects skills (not vendored).
- Removed the router and engine-detection wording, the "When not to use" lists, and every link to upstream skills we did not vendor. Related links now point only to the vendored skills and `roblox-lessons`.
- Trimmed SKILL.md to 5 KB or less; the detail lives in references/.
