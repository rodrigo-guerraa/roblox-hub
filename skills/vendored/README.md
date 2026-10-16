# Vendored skills

Third-party Claude Code skills, curated for Roblox work. Each folder was copied by hand at a pinned commit (no installers were run), then trimmed and corrected: agent-steering instructions removed, advice that contradicts [`roblox-lessons`](../roblox-lessons/) fixed with a note, and every file states that `roblox-lessons` wins on conflicts. Each folder keeps its upstream `LICENSE` (and `NOTICE` where required); `SOURCE.md` records the source, commit and every change.

| Skill | Use for | Source | License |
| --- | --- | --- | --- |
| [`roblox-dev`](roblox-dev/) | Engineering reference: worked examples, persistence and migrations, receipts, Studio MCP and agent safety, deprecated-API replacements, security, networking | [MSayib/roblox-dev-skill](https://github.com/MSayib/roblox-dev-skill) | MIT |
| [`roblox-data`](roblox-data/) | Save systems: DataStore, ProfileStore, session locks, migrations, limits | [TabooHarmony/roblox-brain](https://github.com/TabooHarmony/roblox-brain) | MIT |
| [`roblox-monetization`](roblox-monetization/) | Passes, products, receipts, PolicyService, paid-random-item disclosure | roblox-brain | MIT |
| [`roblox-networking`](roblox-networking/) | Remotes, validation, rate limits, payload budgets | roblox-brain | MIT |
| [`roblox-security`](roblox-security/) | Exploit hardening and security reviews | roblox-brain | MIT |
| [`roblox-studio-mcp`](roblox-studio-mcp/) | Driving Studio through its built-in MCP server | roblox-brain | MIT |
| [`roblox-tooling`](roblox-tooling/) | Rojo, Wally, Rokit, Selene, StyLua, luau-lsp, Lune, test runners | roblox-brain | MIT |
| [`roblox-publish-checklist`](roblox-publish-checklist/) | Evidence-backed release gate | roblox-brain | MIT |
| [`roblox-debugging-bugfix`](roblox-debugging-bugfix/) | Hypothesis-driven debugging with a Studio repro loop | [AshExplained/roblox-skills](https://github.com/AshExplained/roblox-skills), after [mattpocock/skills](https://github.com/mattpocock/skills) | MIT |
| [`roblox-to-issues`](roblox-to-issues/) | Slicing work into small, verifiable vertical slices | AshExplained, after mattpocock/skills | MIT |
| [`roblox-creator-store-security-audit`](roblox-creator-store-security-audit/) | Screening third-party assets before import | AshExplained | MIT |
| [`roblox-security-economy`](roblox-security-economy/) | Currency, inventory and purchase exploit review | AshExplained | MIT |
| [`roblox-release-operations`](roblox-release-operations/) | Publishing, rollback and live-issue response | AshExplained | MIT |
| [`game-feel`](game-feel/) | Feedback and "juice" design, adapted for Roblox | [gamedev-skills/awesome-gamedev-agent-skills](https://github.com/gamedev-skills/awesome-gamedev-agent-skills) | Apache-2.0 |
| [`game-ui-ux`](game-ui-ux/) | HUD, menus, safe areas, panel flow | awesome-gamedev-agent-skills | Apache-2.0 |
| [`level-design`](level-design/) | Layout, pacing, gating, guidance | awesome-gamedev-agent-skills | Apache-2.0 |
| [`audio-design`](audio-design/) | Buses, ducking, adaptive music | awesome-gamedev-agent-skills | Apache-2.0 |
| [`save-systems`](save-systems/) | Save schema design, versioning, migrations | awesome-gamedev-agent-skills | Apache-2.0 |

The full evaluation behind these picks (including the repos that were rejected and why) is in [`docs/research/2026-10-skill-and-tool-survey.md`](../../docs/research/2026-10-skill-and-tool-survey.md).
