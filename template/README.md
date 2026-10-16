# Game template

An empty Roblox game wired for AI-driven development: Rojo, Wally, Selene, StyLua, luau-lsp, Lune and TestEZ, plus a starter `CLAUDE.md`.

## Start a new game

1. Copy this folder to the new project location (e.g. `C:\Users\Digo\my-new-game`) and `git init` it.
2. `rokit install` (first time on a machine: install Rokit itself from https://github.com/rojo-rbx/rokit).
3. `wally install`.
4. Fill in the top of `CLAUDE.md` (name, audience, core loop, monetization) and change `name` in `default.project.json` and `wally.toml`.
5. Open a new place in Roblox Studio, enable the Studio MCP (Assistant settings) and "Enable Studio Access to API Services", connect the Rojo plugin, then run `rojo serve`.
6. Ask Claude to set the place up: it checks the console, runs the sample spec, and confirms the pipeline works.
7. Copy in the hub systems the game needs (see `../docs/reuse-catalog.md`).
