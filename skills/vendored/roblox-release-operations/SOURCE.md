# Source

- Upstream: https://github.com/AshExplained/roblox-skills (folder `roblox-release-operations/`)
- Pinned commit: `a3a7b940f0899d4a69c1a7df625996bdfc917388`
- License: MIT, Copyright (c) 2026 AshExplained (`LICENSE`, copied verbatim)
- Date vendored: 2026-10-16
- Files taken: `roblox-release-operations/SKILL.md` (upstream has no references for this skill) and the repo-root `LICENSE`

## Changes we made

- Frontmatter: description rewritten.
- Added the `roblox-lessons` precedence line.
- Stated our model: code in git, synced by Rojo; Studio-made art in the place file; publishing from Studio ships; the human decides publishing and pushes commits.
- Pre-release gate expanded: specs/lint, committed + Rojo-synced + place saved, fresh-Play MCP smoke test, save migration check, receipt dedupe, `IsStudio()` guards, real ids and matching display prices, paid-random-item odds/policy, phone UI, human-only tests.
- Rollback rewritten for our setup: step-by-step migrations, old servers leaving newer saves untouched during rolling updates, revert-commit + sync + republish or place version history, Open Cloud read key held by the human for live save inspection.
- Added a live-issue response line (reproduce in Studio, fix in the repo, never hot-edit the Studio copy).
- Removed references to skills we do not vendor (analytics-instrumentation, community-ops) and the "Next" section.
