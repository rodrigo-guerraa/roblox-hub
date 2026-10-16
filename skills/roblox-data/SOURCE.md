# Source: roblox-data

- **Upstream:** https://github.com/TabooHarmony/roblox-brain
- **Path:** `skills/core/roblox-data/`
- **Pinned commit:** `ceee4aaa5004502e2a51d78b3c33bba44d84742b` (2026-10-14)
- **License:** MIT, Copyright (c) 2026 TabooHarmony (verbatim in `LICENSE`)
- **Vendored:** 2026-10-16
- **Upstream last_reviewed:** 2026-10-14

## Files taken

- `SKILL.md` (rewritten, see below)
- `references/full.md` (edited, see below)
- `LICENSE` (repository root `LICENSE`, verbatim)

Nothing was installed or executed from the upstream repository; files were read as data and copied by hand.

## Changes we made

- `SKILL.md` rewritten as a compact entry point (under 4 KB); frontmatter reduced to `name` + `description` (upstream `description` and `when_to_use` merged; `last_reviewed` and `sources` moved into this file).
- Added "Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins." near the top of `SKILL.md` and a matching hub note at the top of `references/full.md`.
- Links to upstream skills we did not vendor are rewritten to hub skills that exist (`roblox-lessons` reference files or the other six vendored skills) or removed.
- Added an "Our defaults" block: ProfileStore is the default for player profiles; Studio saves use a `_Studio` store suffix; never rename a store to change the save format; migrations run as a pure `Migrate` on a deep copy with per-step `pcall`, and newer/failed saves kick and stay untouched.
- `full.md` section 3: upstream example store name `PlayerData_v3` replaced by the stable `STORE_NAME`, with a correction explaining why a versioned store name is dangerous.
- `full.md` section 6: correction that the inline in-place `migrate` must become a deep-copy, all-or-nothing migration for profile loads (roblox-lessons data.md).
- `full.md` section 8: retitled from "ProfileStore integration (optional)" and annotated as our default, with the Studio store suffix and migrate-before-Reconcile order.
- Removed references to `roblox-server-data`, `roblox-cloud` (section 8.6) and `roblox-analytics`; the Open Cloud pointer now goes to `roblox-lessons` open-cloud.md.
- Removed the community link to "DataPredict" (ML revenue-optimization toolkit; off-topic and promotional).

## Upstream cited sources

As listed in the upstream `SKILL.md` frontmatter (`original` means the author's own material):

- https://create.roblox.com/docs/reference/engine/classes/DataModel
- https://create.roblox.com/docs/cloud-services/data-stores
- https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores
- https://create.roblox.com/docs/cloud-services/memory-stores
- https://create.roblox.com/docs/cloud-services/data-stores/data-stores-manager
- https://create.roblox.com/docs/cloud-services/data-stores/right-to-be-forgotten
- https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits
- https://create.roblox.com/docs/cloud-services/data-stores/versioning-listing-and-caching
- https://create.roblox.com/docs/reference/engine/classes/DataStoreService
- https://raw.githubusercontent.com/MadStudioRoblox/ProfileStore/main/README.md
- https://madstudioroblox.github.io/ProfileStore/api/
- https://devforum.roblox.com/t/profilestore/3190543
- original
