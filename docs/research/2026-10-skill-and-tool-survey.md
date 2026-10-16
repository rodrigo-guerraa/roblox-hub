# Survey: Roblox tools, libraries and AI skill repos (October 2026)

Checked on GitHub (activity, stars, license); skill repos read as text only, nothing installed or run. Lens: **development is AI-driven**, so what matters is what catches AI mistakes and what the AI knows well.

## Tools (template pins these in `rokit.toml`)
| Tool | Verdict |
| --- | --- |
| Rojo 7.7, Wally 0.3, Selene 0.32 | In use |
| Rokit 1.2 | Toolchain installer (Aftman archived) |
| StyLua 2.6 | Formatter — consistent code |
| luau-lsp 1.70 | `luau-lsp analyze` = type checker the AI runs after edits |
| Lune 0.11 | Run Luau scripts outside Studio |
| Studio built-in MCP | The verification loop; the standalone Roblox repo is archived |
| TestEZ | Archived but works; jest-lua is Roblox's successor (future migration) |
| `Roblox/creator-docs` (CC-BY-4.0) | Official docs as markdown — check APIs against it |
| rbxcloud | Optional Open Cloud CLI |

## Libraries
- Use: ProfileStore (saving), RbxUtil (Signal/Trove/...), roblox-lua-promise, TopbarPlus.
- Maybe later: Blink/Zap (schema → generated, validated networking), Cmdr (human live-testing console).
- Avoid for AI work: Fusion/Vide/Charm/jecs (less well known to AI, Fusion has breaking versions — the hub's documented UI kit is safer); Knit (archived).

## AI skill repos
| Repo | License | Verdict | Take |
| --- | --- | --- | --- |
| MSayib/roblox-dev-skill | MIT | **Adopt** (4.5/5, hand-maintained, Studio-tested) | `references/`: worked-examples (data migration §7, receipts §6), mcp-integration, agent-safety, datastore-persistence, monetization, legacy-migration. Write a short entry SKILL.md (its own is 25 KB and loads on every task). Don't run its installers. |
| TabooHarmony/roblox-brain | MIT | **Adopt most** (4/5, sourced, CI-checked) | roblox-data, roblox-monetization, roblox-networking, roblox-security, roblox-studio-mcp, roblox-tooling, roblox-publish-checklist. Patch roblox-gui (canvas/TextScaled). **Skip roblox-collaboration-mode** ("load first, wins over other framing"). Design skills = opinion. |
| gamedev-skills/awesome-gamedev-agent-skills | Apache-2.0 | Adopt a few | game-feel, game-ui-ux, save-systems (migration ref), level-design, audio-design. Skip its Roblox pack and router. |
| AshExplained/roblox-skills | MIT | Adopt a few | roblox-debugging-bugfix (best), roblox-creator-store-security-audit, roblox-to-issues, roblox-security-economy, roblox-release-operations. **Never run setup-roblox-skills** (rewrites CLAUDE.md; says code shouldn't be in git). |
| nonlooped/roblox-suite | MIT | Reference | Cherry-pick roblox-datastores, roblox-open-cloud, roblox-rojo, roblox-teleport. Its testing skill is outdated; receipt dedupe is in-memory. |
| andrian-syh/roblox-best-practices-skill | MIT | Reference | cases/monetization.md, false-positives.md. Says "version the store name" (wipes players), forces comment banners, has a "carry this verbatim through compaction" card. Don't install. |
| luumenlabs/luau-skills | MIT | Reference | luau-types, luau-performance at most; dead doc references. |
| sentinelcore/roblox-skills | none | Reference | Source of the hub's `roblox-gui` SKILL.md; animations + performance useful; datastores advice weak. |
| brockmartin/roblox-game-skill | none | Skip | One-shot AI generated; contradicts itself on receipts; outdated MCP detection. |
| "Best … 2026" repos, exploit tools | — | Avoid | Spam/malware-bait pattern. |

None of them cover the hub's own gotchas (TextScaled, GuiInset, canvas sizing, Open Cloud limits) → `skills/roblox-lessons`.

## Follow-ups found
- Reference game: `BadgeService:AwardBadge` is deprecated → `AwardBadgeAsync` (confirmed in creator-docs).
- `MarketplaceService:BindReceiptHandler` is a newer alternative to ProcessReceipt (ProcessReceipt still works).
