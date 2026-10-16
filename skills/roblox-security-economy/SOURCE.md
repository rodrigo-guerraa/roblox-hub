# Source

- Upstream: https://github.com/AshExplained/roblox-skills (folder `roblox-security-economy/`)
- Pinned commit: `a3a7b940f0899d4a69c1a7df625996bdfc917388`
- License: MIT, Copyright (c) 2026 AshExplained (`LICENSE`, copied verbatim)
- Date vendored: 2026-10-16
- Files taken: `roblox-security-economy/SKILL.md` (upstream has no references for this skill) and the repo-root `LICENSE`

## Changes we made

- Frontmatter: description rewritten.
- Added the `roblox-lessons` precedence line.
- Server-authority rules extended with full remote validation (type, valid key, ownership, affordability, range/cooldown, silent reject) and income-scaled rewards with caps/ladders on repeatable multipliers.
- Saves section corrected per `roblox-lessons`: ProfileStore session locking, step-by-step `dataVersion` migrations that leave newer saves untouched, never renaming the DataStore, Studio-suffixed store and `IsStudio()` guards (replaced upstream's generic "queue or debounce saves").
- Receipts made specific: one handler, `PurchaseId` dedupe in the player's own save, `NotProcessedYet` when unsure; added paid-random-items disclosure and `PolicyService` gating.
- Review workflow moved from in-Studio `script_grep`/`multi_edit` to the git repo + Rojo sync, and verification to the Studio MCP with valid and forged payloads and fake-receipt tests through a temporary Script (plugin `shared` sandbox note).
- Removed references to skills we do not vendor (playtest-qa, datastore-persistence) and the "Next" section.
