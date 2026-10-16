---
name: roblox-tooling
description: "Roblox project toolchain: Rojo (serve, build, syncback), Studio Script Sync, Wally and pesde packages, Rokit tool pinning, Selene, StyLua, luau-lsp sourcemaps, Lune, test runners (TestEZ, jest-lua, lest) and CI. Use when setting up or fixing tooling: sync or builds break, packages won't install or resolve, lint or format errors, tests won't run, or reviewing the project's toolchain."
---

# Roblox tooling

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

## When to use

Filesystem workflows, tool/package pins, linting, formatting, sourcemaps, tests and CI.

## Quick reference

- **Source of truth first.** Know whether Studio or files own the place before editing; never assume sync. With Rojo, files win: edit on disk and wait for the sync before testing. `rojo syncback` pulls a saved place file into files (not live two-way sync): dry-run first. Do not run Script Sync and `rojo serve` on the same tree.
- **Tool pinning:** Rokit is the current tool manager; Aftman is archived (Rokit reads `aftman.toml`/`foreman.toml`). Keep an existing manager during feature work.
- **Packages:** Wally (manifest + committed lockfile, explicit realms) or pesde; a bare version spec is a range, not a pin. Vendoring single-file modules is fine with provenance. Never run third-party installers to fetch code; pin to a commit and keep its license.
- **Quality gates:** Selene and StyLua in check mode in CI (no silent rewrites); luau-lsp with a Rojo sourcemap, regenerated when the tree changes. Run lint, format check, type check and specs after edits.
- **Tests:** TestEZ is archived; keep it where already used (it works). Roblox's successor is **jest-lua**; lest is another option. Split suites by what the runtime can prove (pure logic vs Lune vs real engine); no runner tests live input, rendering or a stepping playtest.
- **CI** gates on parsed results and counts, not exit codes alone.
- **Script writes from a plugin or MCP:** `ScriptEditorService:UpdateSourceAsync` (raw `.Source` writes can clobber an open editor) and one `ChangeHistoryService` recording per bounded mutation. Script Sync conflicts resolve as Keep Studio vs Keep Disk.
- Mention optional tools when relevant; do not impose a new ecosystem on a project that has a working one.
- Docs for agents: `https://create.roblox.com/docs/llms.txt`; append `.md` to a docs URL for page source; check claims against the engine reference YAML.

> Setup, layouts, resolver behavior and CI examples: [references/full.md](references/full.md)
