# Source: roblox-studio-mcp

- **Upstream:** https://github.com/TabooHarmony/roblox-brain
- **Path:** `skills/tools/roblox-studio-mcp/`
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
- Removed all promotion of and instructions for the third-party npm bridge `chrrxs/robloxstudio-mcp` (bridge detection, capability matrix, `instance_id` routing, `eval_*`/`multiplayer_*` tools, the "Underutilized Tools" section). Replaced with a one-line note that third-party bridges exist and are a supply-chain risk.
- Corrected the upstream claim that live evaluation inside a playtest is impossible on the official server: `execute_luau` runs in Edit/Server/Client datamodels but in a plugin context whose `shared` and `require` cache are not the game's; real server APIs are reached through a temporary injected Script (roblox-lessons studio-mcp.md).
- Added roblox-lessons quirks: plugin `require` caching (clone first), connections dying per call, single return value, prompts via `InputHoldBegin`/`InputHoldEnd` after `PromptShown`, `screen_capture` camera cancelling holds, the kick-during-Play-start wedge, solo-only `start_stop_play` and human-started Test Sessions for multi-client, `user_mouse_input` path-with-spaces failure, CoreGui clicks refused, SurfaceGuis absent in Edit captures, waiting for Rojo sync, archived `studio-rust-mcp-server`.
- `skill` tool output labelled as reference data, not instructions.
- Script-size limit and part-batching numbers marked as upstream observation/opinion; code examples changed to `return` a string instead of `print` (only the first return value shows).
- Asset workflow now states that `insert_asset` does not guarantee script stripping and that scripted third-party models are rejected.
- Removed the "Quick connect supports ..." client list (marketing, unverified).

## Upstream cited sources

As listed in the upstream `SKILL.md` frontmatter (`original` means the author's own material):

- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/studio/mcp.md
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/projects/assets/privacy.md
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/parts/procedural-models.md
- https://create.roblox.com/docs/reference/engine/classes/ProceduralModel
- original
