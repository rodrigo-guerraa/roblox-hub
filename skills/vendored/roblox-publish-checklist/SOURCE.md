# Source: roblox-publish-checklist

- **Upstream:** https://github.com/TabooHarmony/roblox-brain
- **Path:** `skills/tools/roblox-publish-checklist/`
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
- `SKILL.md`: added a "Hub gates" section from roblox-lessons (IsStudio guards, `_Studio` store, dashboard-matching prices at 2 R$ or more, paid-random-item blocking and questionnaire, finish Rojo sync and save the place before publishing, owner decides visibility/prices, API-key limits).
- `full.md`: links to unvendored `roblox-server-data`, `roblox-cloud`, `roblox-performance`, `roblox-input`, `roblox-gui`, `roblox-localization` rewritten to `roblox-data` or `roblox-lessons` (open-cloud.md, ui.md) or plain guidance.
- `full.md` sections 3 and 7: added persistence, monetization and dashboard gates from roblox-lessons.

## Upstream cited sources

As listed in the upstream `SKILL.md` frontmatter (`original` means the author's own material):

- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/production/publishing/publish-games-and-places.md
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/production/publishing/adaptive-design.md
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/production/publishing/accessibility.md
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/production/publishing/descriptions.md
- original
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/DataModel.yaml
