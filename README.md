# roblox-hub

A toolkit for building Roblox games where **the code is written, tested and maintained by an AI agent** ([Claude Code](https://claude.com/claude-code)) and a human makes the design, art and business calls.

It packages what shipping a Roblox simulator this way taught us: a project template wired for AI guardrails, game systems you can drop into a new game, and "skills" — knowledge files the agent loads on demand — including a hard-won list of Roblox gotchas.

## What's inside

| Folder | Contents |
| --- | --- |
| [`template/`](template/) | An empty Rojo project: pinned toolchain (Rojo, Wally, Selene, StyLua, luau-lsp, Lune), lint/format/type-check configs, a TestEZ runner and a starter `CLAUDE.md` with working rules for the agent. |
| [`systems/`](systems/) | Reusable game systems, copied into a game rather than linked: **core** (save data with migrations, economy, remotes, number formatting), a cartoon-style **UI kit**, **monetization** (receipts, game passes, paid-random-items policy, offline earnings) and **live-ops** (codes, playtime gifts, group rewards, badges, social prompts). They share one contract: [`systems/CONVENTIONS.md`](systems/CONVENTIONS.md). |
| [`skills/`](skills/) | Claude Code skills. [`roblox-lessons`](skills/roblox-lessons/) is original: the gotchas learned shipping a game. [`skills/vendored/`](skills/vendored/) holds 18 skills curated from public collections — trimmed, corrected and pinned, each with its license and a `SOURCE.md` describing the changes. |
| [`docs/`](docs/) | [Onboarding](docs/onboarding.md), the [reuse catalog](docs/reuse-catalog.md) and a [survey](docs/research/2026-10-skill-and-tool-survey.md) of Roblox tools, libraries and AI skill repos. |
| [`scripts/`](scripts/) | Maintenance scripts, e.g. installing the skills for every project. |

## Quick start

1. Clone this repo into a workspace folder that will hold your games next to it:
   ```
   roblox/
   ├── roblox-hub/
   └── my-game/
   ```
2. Install the skills for all your Claude Code projects (Windows):
   ```powershell
   powershell -ExecutionPolicy Bypass -File roblox-hub\scripts\sync-skills.ps1
   ```
   This copies `skills/*` and `skills/vendored/*` into `%USERPROFILE%\.claude\skills\`, replacing only the folders the hub owns. Re-run it after pulling skill updates.
3. Start a new game from the template by following [`docs/onboarding.md`](docs/onboarding.md) — or open a Claude Code session in an empty folder next to the hub and ask it to start a game from `../roblox-hub`.

**Requirements:** Roblox Studio with its built-in MCP server enabled (the agent verifies every change through it), the Rojo Studio plugin, [Rokit](https://github.com/rojo-rbx/rokit), git and Claude Code.

## Status

| Part | State |
| --- | --- |
| `template/` | Builds and lints clean. |
| `skills/` | Ready to use. |
| `systems/` | Extracted from the shipped game and made game-agnostic. The full stack builds and lints clean together, but the generic versions **have not yet been run in Studio** — expect the first game that adopts them to find and fix a few issues (their READMEs list the checks to run). |

## Principles

- **Prove it in Studio.** A change counts as done when it's been exercised in a fresh playtest through the Studio MCP — not when it compiles.
- **Copy, don't link.** A game owns its copy of a system; improvements are copied back into the hub deliberately.
- **Lessons flow back.** When a game teaches something new, it goes into `skills/roblox-lessons`.
- **Vendored content is curated.** Third-party skills are copied by hand (never via installers), pinned to a commit, kept under their license and documented in `SOURCE.md`. Content that tries to steer the agent ("load me first", "override other rules") is removed.

## License

The hub's own content is [MIT](LICENSE). Vendored skills and ProfileStore keep their own licenses (MIT or Apache-2.0) — see each folder's `LICENSE` / `SOURCE.md` and the note at the end of [`LICENSE`](LICENSE).
