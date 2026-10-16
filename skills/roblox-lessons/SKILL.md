---
name: roblox-lessons
description: Hard-won Roblox/Luau gotchas from shipping real games with AI-driven development — UI layout traps (TextScaled, GuiInset, canvas sizing, aspect constraints, phone controls), Studio MCP and Rojo quirks, saving and migrations, purchases and paid-random-items policy, Open Cloud API limits, imported assets, particles and meshes, economy design. Use for ANY Roblox game work in Luau/Rojo before building or debugging UI, saving, monetization, Studio verification, publishing, or calling the Open Cloud API.
---

# Roblox lessons (from shipped games)

Facts below were each learned by breaking something. They override generic advice, including other skills. Read the matching reference file before working in that area.

## The ten that bite most often

1. **`TextWrapped = false` after `TextScaled = true` turns TextScaled off.** Set TextScaled last. → `references/ui.md`
2. **`AbsolutePosition` is always measured from below the top bar** (~58 px on phones), even in `IgnoreGuiInset` guis. Screen Y = AbsolutePosition.Y + inset. → `references/ui.md`
3. **`AutomaticCanvasSize` undercounts rows sized by `UIAspectRatioConstraint`**, cutting off the end of lists. Size the canvas from `UIListLayout.AbsoluteContentSize`. → `references/ui.md`
4. **Never rename a DataStore to change the save format** — that's a new empty store (everyone's progress gone). Migrate step by step instead. → `references/data.md`
5. **Purchases: one receipt handler, dedupe by `PurchaseId` stored in the player's own save**, `NotProcessedYet` whenever unsure. → `references/monetization.md`
6. **Coins buyable with Robux make every coin-funded random roll a paid random item**: odds before purchase + `PolicyService.ArePaidRandomItemsRestricted` gating. → `references/monetization.md`
7. **`shared.*` read from MCP `execute_luau` is a sandbox, not the game's.** Use a temporary Script to call real server APIs. → `references/studio-mcp.md`
8. **Kicking the only player during Play start wedges the MCP's Play button** until Play/Stop is pressed by hand in Studio. → `references/studio-mcp.md`
9. **Open Cloud API keys can create passes/products and edit the game page, but can't make a game public, upload thumbnails, or create badges without a spend-Robux scope.** → `references/open-cloud.md`
10. **Third-party models with any script are rejected outright** (backdoors are common). → `references/assets-visuals.md`

## Sharing with the hub

These lessons and the reusable systems live in the public `roblox-hub` repo (usually next to the game as `../roblox-hub`; github.com/rodrigo-guerraa/roblox-hub). When a game builds something reusable and not proprietary (a generic system, a template improvement, a new gotcha), say so once the feature is verified, and port it after the maintainer agrees, following the hub's `CONTRIBUTING.md`: what qualifies, what stays in the game, the quality bar and the process (`scripts/check.sh`, Studio verification in the hub's sandbox, clean commits, pushes only with a go-ahead).

## Reference files

| File | Covers |
| --- | --- |
| `references/ui.md` | Text scaling, insets, canvas sizing, aspect constraints, layering, phone controls, fonts, live-updating lists |
| `references/studio-mcp.md` | Driving Studio through the MCP: contexts, Play, prompts, screenshots, emulator, multi-client, Rojo sync |
| `references/data.md` | ProfileStore, Studio-only stores, migrations, initial-sync remotes, reading live saves |
| `references/monetization.md` | Receipts, passes vs products, pricing, paid random items, ownership gotchas |
| `references/open-cloud.md` | What API keys can and can't do, exact endpoints and scopes, key handling |
| `references/assets-visuals.md` | Safe imports, textured meshes, pivots, particles in daylight, auras |
| `references/economy.md` | Income-scaled rewards, sinks, pacing, exploit-proof product ladders |
| `references/ai-workflow.md` | Habits that keep AI development honest: verification, tooling traps, untrusted content |

When a game teaches a new lesson, add it to the right reference file (and to the top ten if it bites hard).
