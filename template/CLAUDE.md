# <Game Name> — Claude Code Project Guide

## Project Summary

<One paragraph: what the game is, who it's for (audience/age), the core loop, and how it makes money. Fill this in on day one; update it when the design changes.>

---

## Team conventions (defaults — edit for your project)

- Claude Code writes, tests and commits the code.
- The maintainer makes the design, art, pricing and publishing decisions, tests feel on real devices, and does all git pushes.

---

## Shared Hub

This game was started from the `roblox-hub` folder that sits next to it (`../roblox-hub`). Before building a system, check the hub:

- `roblox-hub/skills/` — Roblox skills (installed user-wide). **`roblox-lessons` is required reading**: it holds the gotchas earlier games paid for.
- `roblox-hub/systems/` — proven game systems (saving, UI kit, monetization, live-ops) to copy in rather than rewrite.
- `roblox-hub/docs/` — onboarding and the reuse catalog.

When this game improves a shared system or discovers a new gotcha, update the hub as well (and say so in the commit).

---

## Folder Structure & Rojo Mapping

```
game/
├── src/
│   ├── server/   → ServerScriptService   (Scripts, server only)
│   ├── client/   → StarterPlayerScripts  (LocalScripts)
│   └── shared/   → ReplicatedStorage     (ModuleScripts used by both)
├── tests/        → ReplicatedStorage.Tests (TestEZ specs)
├── tools/        → ServerStorage.Tools    (Studio-only tooling, e.g. a map builder)
├── DevPackages/  → ReplicatedStorage.DevPackages (`wally install`)
└── default.project.json
```

Art made in Studio (models, meshes, imported assets) lives in the place file, in folders Rojo declares with `$ignoreUnknownInstances` (e.g. `ReplicatedStorage.Models`). **Save the place after changing them.**

| Suffix | Roblox type | Where |
| --- | --- | --- |
| `.server.lua` | Script | `src/server/` |
| `.client.lua` | LocalScript | `src/client/` |
| `.lua` | ModuleScript | `src/shared/` or nested |
| `.spec.lua` | TestEZ spec | `tests/` |

---

## Toolchain

`rokit install` installs the pinned tools (`rokit.toml`): Rojo, Wally, Selene, StyLua, luau-lsp, Lune. Then `wally install`.

Checks to run after every change (the AI's guardrails):

- `selene src/` — must be 0 errors, 0 warnings
- `stylua --check src/ tests/` — formatting
- `rojo sourcemap -o sourcemap.json` then `luau-lsp analyze --sourcemap=sourcemap.json --platform=roblox src/` — type errors
- TestEZ specs (see Testing)

New modules should start with `--!strict` when practical; the project default is non-strict.

---

## Testing

Specs live in `tests/` as `<Module>.spec.lua`; only pure-Lua shared modules get specs. `TestRunner` (server, Studio-only) runs them when `ReplicatedStorage.Tests` has the attribute `RunTests = true`: set it in Edit, press Play, read the console, then set it back to `false`.

TestEZ is archived upstream but works; jest-lua is Roblox's successor if the project migrates.

---

## Rules for Claude

1. **Shared data lives in `src/shared/` ModuleScripts.** Never duplicate a table or utility across files.
2. **No comments** unless the WHY is genuinely non-obvious (a Roblox quirk, a subtle invariant, a workaround). One short line max. No block comments or file headers.
3. **No external production dependencies** beyond the reviewed, vendored ones (e.g. ProfileStore). TestEZ is a dev dependency only.
4. **Validate every client → server request on the server.** Player exists and data is loaded; every argument has the right type and is a valid key; the player can afford and is eligible. Bad requests are silently rejected. ProximityPrompts, Touched and ClickDetectors are client input too.
5. **Server authority is strict.** Currency, inventory and progression change only on the server; clients display what the server sends.
6. **`shared.X = T` publishes before any yield and with all methods attached.** Server scripts run concurrently; consumers read `shared.X` the instant it lands.
7. **Verification trust order:** (a) the original error is gone after a fresh Play, (b) runtime state observed through the Studio MCP, (c) specs, (d) `selene`. Never treat `shared.*` read from MCP `execute_luau` as truth — that runs in a sandboxed plugin context.
8. **Verify in Studio through the Roblox Studio MCP, end to end.** Start/stop Play, read the console, inspect server and client state, fire remotes (including forged payloads, which must be rejected), trigger prompts, and screenshot anything visual. Prove every observable behaviour the change adds; if something can't be exercised in Studio, say so and why. Remove temporary instances afterwards. Never put diagnostic prints in production scripts or hand the maintainer Command Bar snippets.
9. **When a fix produces a new error of similar shape, re-derive — don't patch.** Re-read the affected file end to end and fix the ordering once.
10. **Imported assets never contain scripts** (third-party models with scripts can be malware). Any exception is approved by the maintainer and reviewed first.
11. **Real money and publishing are the maintainer's call.** Creating products, changing prices, publishing or changing visibility need an explicit go-ahead.

## How Claude Should Work

- State in one sentence what you're about to change and where, then do it.
- Read only the files the task needs; never re-read a file already in context.
- Implement the change, verify it, then stop. No unrequested refactors or features.
- If the task is ambiguous, ask one clarifying question.
- Commit when a change is verified; the maintainer pushes.
- Keep this file current: every system, remote, saved field and world object gets documented here as it's built.

---

## <Game-specific sections — grow these as the game is built>

- Game loop
- Systems (one paragraph each)
- Saved data fields and `DATA_VERSION`
- RemoteEvents (name, direction, payload, validation)
- Gamepasses & developer products (ids, prices, effects)
- World (how it's built, named objects other code relies on)
