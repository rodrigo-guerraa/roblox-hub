# Onboarding — starting a new Roblox game with AI

Who does what: **the AI (Claude Code) writes, tests and commits all code.** The owner decides design, art, prices and publishing, makes images/models, tests on real devices, and pushes commits.

## 0. One-time machine setup
- Roblox Studio, VS Code with the Rojo extension, git.
- Rokit (https://github.com/rojo-rbx/rokit) — installs every other tool per project.
- In Studio: Assistant settings → enable the **Studio MCP server**; Rojo plugin installed.
- Hub skills installed for every project: `powershell -ExecutionPolicy Bypass -File C:\Users\Digo\roblox\roblox-hub\scripts\sync-skills.ps1` (re-run when the hub's skills change).

## 1. Create the project (owner + AI)
1. Copy `roblox-hub/template/` to `C:\Users\Digo\roblox\<game-name>`; `git init`.
2. `rokit install`, then `wally install`.
3. Rename the game in `default.project.json` and `wally.toml`.
4. Fill in the top of `CLAUDE.md`: what the game is, the audience (age!), core loop, how it makes money.
5. New place in Studio → Game Settings → Security → **Enable Studio Access to API Services**; Rojo plugin → Connect; `rojo serve` in the project.
6. Ask Claude to verify the pipeline: fresh Play, clean console, sample spec passes.

## 2. Pull in hub systems (AI)
Start from `docs/reuse-catalog.md`. Typical simulator: core (data, economy, remotes, format) → UI kit → monetization (receipts, gamepasses, paid-random-items, offline earnings) → live-ops (codes, playtime gifts, group rewards, badges, social prompts). Each system's README has the exact files, saved fields and config. Document each one in the game's `CLAUDE.md` as it lands.

## 3. Build the game (AI, owner reviews in Studio)
- One vertical slice at a time, each verified in Studio through the MCP (skill: `roblox-to-issues`).
- Worlds come from a builder script in `tools/` that's re-run, not hand-placed objects.
- Art: the owner imports models/meshes; anything with a script is rejected (skill: `roblox-creator-store-security-audit`). Studio-made art lives in the place file — **save the place**.
- Read `roblox-lessons` before UI, saving, monetization or publishing work.

## 4. Things only the owner can do
- Create the group / decide group-owned vs personal; make an **Open Cloud API key** scoped to this game (store it outside the repo, e.g. `C:\Users\Digo\.<game>_api_key.txt`). With it, Claude can create passes and products, set icons, server size, name, description and voice chat (see `roblox-lessons/references/open-cloud.md`).
- Prices and anything spending Robux; the Maturity & Compliance questionnaire (answer paid random items honestly); game icon, thumbnails, trailer; making the game public (dashboard).
- Generate images (icons for passes/products/badges, thumbnails) — Claude writes the prompts and uploads what the API allows.
- Test on a real phone; buy one cheap product live; test passes with an alt (the creator owns its own passes).

## 5. Release
Skills: `roblox-publish-checklist`, `roblox-release-operations`. Keep a `RELEASE_CHECKLIST.md` in the game (Dino Simulator's is a good model). Publish from Studio with Rojo synced; then run the live test.

## 6. After every game
- New gotcha learned → add it to `skills/roblox-lessons/references/` (+ re-run the sync script).
- Improved a shared system → copy the improvement back into `systems/` and note it in the system's README.
- Commit to the hub; the owner pushes.

## A new AI session on an existing game
Claude reads the game's `CLAUDE.md` (the project's memory) and the `roblox-lessons` skill. Keep `CLAUDE.md` current — it's how the next session knows what exists.
