# Source

- Upstream: https://github.com/AshExplained/roblox-skills (folder `roblox-creator-store-security-audit/`)
- Pinned commit: `a3a7b940f0899d4a69c1a7df625996bdfc917388`
- License: MIT, Copyright (c) 2026 AshExplained (`LICENSE`, copied verbatim)
- Date vendored: 2026-10-16
- Files taken: `roblox-creator-store-security-audit/SKILL.md` (upstream has no references for this skill) and the repo-root `LICENSE`

## Changes we made

- Frontmatter: description rewritten around our rule.
- Added the `roblox-lessons` precedence line.
- Replaced upstream's "disable or remove imported scripts / keep visual content" approach with our rule: any Script, LocalScript or ModuleScript (even disabled) in an imported third-party model means reject; do not strip and keep.
- Quarantine is a folder in `ServerStorage`, inserted in Edit; the scan is an `execute_luau` walk of `GetDescendants()` for `LuaSourceContainer` (plus remotes, prompts, tools, GUIs).
- Upstream's suspicious-pattern list and red flags kept as the line-by-line review aid for human-approved exceptions only (added `LoadAsset` and long encoded strings).
- Verdicts reduced to Accept / Reject / Approved exception.
- Added Rojo `$ignoreUnknownInstances` + save-the-place note for place-file art.
- Removed `set_active_studio` (not in the built-in MCP tool set we use) and in-Studio script removal via `multi_edit`.
- Removed references to skills we do not vendor (asset-pipeline, performance-optimization) and the "Next" section.
