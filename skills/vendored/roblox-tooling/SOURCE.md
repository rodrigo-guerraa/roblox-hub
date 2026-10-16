# Source: roblox-tooling

- **Upstream:** https://github.com/TabooHarmony/roblox-brain
- **Path:** `skills/tools/roblox-tooling/`
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
- TestEZ stated as archived but fine where used, and jest-lua named as Roblox's successor (SKILL.md and full.md section 1c).
- Rokit stated as the current tool manager, Aftman archived; added a `rokit.toml` note to section 4.
- Direct GitHub installs: added the hub rule to pin to a commit, keep the license, review the code, and never run third-party installers.
- Replaced the long "Field-reported tool and resource stack" section (AI thumbnail services, paid asset sites, a third-party web proxy, a contact-scraping tool, analytics dashboards) with a short trimmed section keeping two practitioner tips, plus a correction to its Open Cloud claim (keys cannot upload thumbnails or make a game public; prices and publishing are the owner's call).
- Marked roblox-ts adoption statistics as an upstream snapshot we did not re-verify; removed the reference to the unvendored architecture skill.

## Upstream cited sources

As listed in the upstream `SKILL.md` frontmatter (`original` means the author's own material):

- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/ScriptEditorService.yaml
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/ChangeHistoryService.yaml
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/InstanceFileSyncService.yaml
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/scripting/sync.md
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Players.yaml
- https://rojo.space/docs/
- https://wally.run/
- https://kampfkarren.github.io/selene/
- https://raw.githubusercontent.com/JohnnyMorganz/StyLua/master/README.md
- https://lune-org.github.io/docs/
- https://raw.githubusercontent.com/LPGhatguy/aftman/main/README.md
- https://raw.githubusercontent.com/rojo-rbx/rokit/main/README.md
- https://raw.githubusercontent.com/rojo-rbx/rojo/v7.7.1/src/cli/syncback.rs
- https://raw.githubusercontent.com/pesde-pkg/pesde/main/docs/src/content/docs/reference/manifest.mdx
- https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/README.md
- https://raw.githubusercontent.com/lest-luau/lest/main/docs/backends.md
- https://raw.githubusercontent.com/lest-luau/lest/main/docs/continuous-integration.md
- https://raw.githubusercontent.com/UpliftGames/wally/main/src/resolution.rs
- https://create.roblox.com/docs/llms.txt
- https://devforum.roblox.com/t/evolving-luau-oss-community-contributions-more/4566806
- original
