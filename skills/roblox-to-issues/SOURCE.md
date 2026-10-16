# Source

- Upstream: https://github.com/AshExplained/roblox-skills (folder `roblox-to-issues/`)
- Pinned commit: `a3a7b940f0899d4a69c1a7df625996bdfc917388`
- License: MIT, Copyright (c) 2026 AshExplained (`LICENSE`, copied verbatim)
- Date vendored: 2026-10-16
- Files taken: `roblox-to-issues/SKILL.md` (upstream has no references for this skill) and the repo-root `LICENSE`
- Upstream credit: the process (vertical tracer-bullet slices, AFK/HITL types, "Quiz the user", publish blockers first, "Do NOT close or modify" the parent) closely follows the `to-issues` skill (now `to-tickets`) in https://github.com/mattpocock/skills (MIT, Matt Pocock). The AshExplained repo does not credit it.

## Changes we made

- Frontmatter: description rewritten; "done" defined as verified in Studio via MCP.
- Added the `roblox-lessons` precedence line.
- Removed the dependency on `setup-roblox-skills`, `CLAUDE.md` / `docs/agents/` tracker config, the `needs-triage` label and the `ROADMAP.md` checkbox convention; slices go to the project's existing tracker (GitHub issues via `gh` after user approval, or its existing plan file), else ask.
- Vertical tracer-bullet slicing, slice rules and AFK/HITL kept; HITL extended to prices, publishing, Robux spend and human-only tests.
- The acceptance block is now a "Done when (verified in Studio via MCP)" checklist: Rojo-synced fresh Play with a clean console, state observed via `execute_luau`, valid/forged remote payloads, on-join syncs, `screen_capture` checks, temp scripts removed, untestable items handed to the human.
- UI-design gating reworded to stand alone (no `roblox-game-ux` artifact).
- Removed references to skills we do not vendor (triage, studio-workflow, game-ux, luau-architecture, combat-systems, ui-implementation, datastore-persistence, playtest-qa, game-development-lifecycle) and the "Next" section.
- Added: the human pushes commits.

- Matt Pocock's MIT license for that original work is included as `LICENSE.mattpocock-skills`.
