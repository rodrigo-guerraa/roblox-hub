# Source

- Upstream: https://github.com/AshExplained/roblox-skills (folder `roblox-debugging-bugfix/`)
- Pinned commit: `a3a7b940f0899d4a69c1a7df625996bdfc917388`
- License: MIT, Copyright (c) 2026 AshExplained (`LICENSE`, copied verbatim)
- Date vendored: 2026-10-16
- Files taken: `roblox-debugging-bugfix/SKILL.md` (upstream has no references for this skill) and the repo-root `LICENSE`
- Upstream credit: the phase structure and much of the wording (build a feedback loop first, reproduce, 3-5 ranked falsifiable hypotheses shown to the user, instrument with `[DEBUG-a4f2]`-style tagged logs, the 50%-flake remark, "if no correct seam exists, that itself is the finding") closely follows the `diagnosing-bugs` skill (earlier named `diagnose`) in https://github.com/mattpocock/skills (MIT, Matt Pocock). The AshExplained repo does not credit it.

## Changes we made

- Frontmatter: description rewritten for our Rojo + git + Studio MCP workflow.
- Added the `roblox-lessons` precedence line.
- Repro loop rebuilt on the Studio built-in MCP tools (`start_stop_play`, `get_console_output`, `execute_luau` in Edit/Server/Client, `character_navigation`, `user_mouse_input`, `screen_capture`).
- Corrective notes from `roblox-lessons`: `execute_luau`'s `shared` is a plugin sandbox (use a temporary Script for live server APIs); plugin `require` caches (Clone first); per-call connections die; capture payloads as LocalPlayer attributes.
- Tagged-log method kept, but diagnostic prints go only in temporary scripts (`TempVerify`), never production scripts; cleanup is a repo grep for the prefix plus deleting the temp scripts.
- Fixes go in repo files with a wait for Rojo sync, replacing upstream's in-Studio `multi_edit`/`script_grep`/`script_read` flow.
- Durable checks: TestEZ specs for pure shared modules or a documented MCP step.
- Added Roblox bug classes from our games (initial-sync payload consumed by the first listener, publish-before-yield on `shared`, unsynced Rojo).
- Removed references to skills we do not vendor (playtest-qa, mobile-playtest, code-maintenance-refactor, luau-architecture, game-development-lifecycle) and the "Next" section.
- Added: the human owner pushes commits.

- Matt Pocock's MIT license for that original work is included as `LICENSE.mattpocock-skills`.
