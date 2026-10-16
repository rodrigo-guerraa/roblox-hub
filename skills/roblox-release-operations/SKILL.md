---
name: roblox-release-operations
description: Run Roblox release operations for games kept in git and synced to Studio with Rojo - pre-publish gates (specs, lint, fresh-Play smoke test through the Roblox Studio MCP, saves, purchases, Studio-only guards), release notes, rollback plans for code and save-schema changes, live issue response and post-release monitoring. Use before publishing an update, when judging version readiness, or when a live release goes wrong.
---

# Roblox Release Operations

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

## Goal

Ship updates with confidence and a clear recovery path. The repo is the source of truth for code; the place file holds Studio-made art; **publishing from Studio is what ships**, and the human owner decides when to publish and pushes commits.

## Pre-release gate

Verify, and report each item:

- Specs pass and lint is clean (`selene`, StyLua, type checks); no new warnings.
- The work is committed in git; Studio is Rojo-synced to that commit (spot-check a changed script's `Source`), and the place is saved so place-file art is current.
- Fresh Play through the MCP (`start_stop_play`): `get_console_output` free of errors and missing-object warnings; the core loop smoke test passes, observed with `execute_luau` and `screen_capture`, not assumed.
- Save/load checked: an old save migrates, a new player starts clean, nothing renames the DataStore.
- Purchases are server-authoritative: one receipt handler, `PurchaseId` dedupe in the save, fake-receipt tests pass.
- Studio-only conveniences (join grants, force-owned passes, test runner) are guarded by `RunService:IsStudio()`.
- Product and pass ids are real and display prices match the dashboard; paid-random-item odds and policy gating still hold.
- UI checked at phone size; performance risks known.
- Release notes match the build.
- Anything untestable here (real purchases, phones, multi-client) is handed to the human as a short, specific test.

## Release notes

- New content.
- Balance changes.
- Bug fixes.
- Known issues when necessary.
- Return hook or event deadline.

## Rollback thinking

- Know which changes touch the save schema. Migrations run step by step on load and must never be irreversible without a fallback.
- During a rolling update an old server can load a save written by a newer build: it must leave that save untouched and ask the player to rejoin, never overwrite it.
- Code rollback = revert the commit, let Rojo sync, verify, and have the human republish. A previous place version can also be restored from the place's version history, but saves already migrated forward stay migrated, so the old code must cope (see above).
- Stage risky economy or persistence changes behind server flags where possible.
- Keep manual recovery steps for grant/data issues (reading a live save needs an Open Cloud key with datastore read scope, held by the human).

## Post-release watch

- Error spikes.
- Purchase/grant failures.
- Save/load failures and kicked-for-newer-save reports.
- Funnel drop-offs.
- Economy inflation.
- Community reports.

## Live issue response

Reproduce in Studio first, fix in the repo, verify with a fresh Play, then the human republishes. Never hot-edit the Studio copy as the fix.

## Output

- Release readiness status.
- Blocking issues.
- Smoke test plan (the MCP steps) and the human-only tests.
- Rollback or mitigation plan.
- Post-release watchlist.
