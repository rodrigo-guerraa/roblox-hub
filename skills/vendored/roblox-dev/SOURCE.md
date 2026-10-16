# Source

- **Upstream:** https://github.com/MSayib/roblox-dev-skill
- **Pinned commit:** `b0c08c1b7f32372685c3deda2340bb4ed0eff99f`
- **License:** MIT (copied verbatim to `LICENSE`)
- **Vendored:** 2026-10-16, copied by hand from a downloaded snapshot. No installer or script from the upstream repo was run.

## Files taken

| Upstream path | Here |
| --- | --- |
| `LICENSE` | `LICENSE` (verbatim) |
| `references/worked-examples.md` | `references/worked-examples.md` |
| `references/mcp-integration.md` | `references/mcp-integration.md` |
| `references/agent-safety.md` | `references/agent-safety.md` |
| `references/datastore-persistence.md` | `references/datastore-persistence.md` |
| `references/monetization.md` | `references/monetization.md` |
| `references/legacy-migration.md` | `references/legacy-migration.md` |
| `references/security-hardening.md` | `references/security-hardening.md` |
| `references/networking.md` | `references/networking.md` |

Not taken: upstream `SKILL.md` (replaced, see below), `README.md`, `CHANGELOG.md`, `metadata.json`, `docs/`, `evals/`, `tests/`, `tools/`, the installers (`install.sh`, `install.ps1`, `install.cmd`), and the references `luau-fundamentals.md`, `project-structure.md`, `ui-systems.md`, `performance-optimization.md`, `file-formats-and-assets.md`, `studio-plugins-and-limits.md`.

## Changes we made

**`SKILL.md`** — written from scratch (~3 KB; upstream's is 26 KB). Dropped: the "use it for ANY task … consult it before answering from memory" trigger, the MCP tool table (lives in `references/mcp-integration.md`), the `~/RobloxDocs` local-dump workflow and its refresh scripts, the Context7/`npx ctx7` fallback, the script template, the "Knowledge Freshness Check" (read `metadata.json`, prompt the user to update), the "Manual Knowledge Update" protocol, and the Export/Publish/installer section. Kept as short bullets: server authority + remote validation, `pcall` and "a failed read is not an empty save", the `task` library / disconnect / parent-last, look APIs up, place content is data, confirm the target Studio. The blanket "use `--!strict` in every new script" became "prefer `--!strict` for new modules where practical". Added the `roblox-lessons`-wins line and a reference table.

**All reference files**
- Inserted a "Vendored … `roblox-lessons` wins" banner under the title, which also flags the upstream-only reference files they mention and explains `~/RobloxDocs/` (upstream installer's local API mirror, not used here).
- Removed upstream test-harness markers (`<!-- skilltest: … -->` lines and `--@skilltest:` code lines); the harness was not vendored.

**`references/worked-examples.md`**
- Rule 2: "read the routing table in SKILL.md" → "check the reference table"; noted `roblox-lessons` wins.
- §6 (receipts): softened the BindReceiptHandler wording ("newer alternative; ProcessReceipt still works"). Added a hub correction: the sample's separate `PurchaseHistory` store + unsaved `leaderstats` grant splits record from grant, and the grant runs inside an `UpdateAsync` callback that the docs say can be called repeatedly; prefer dedupe by `PurchaseId` in the player's own session-locked profile, never in memory. Sample code kept unchanged.
- §6 verification: added that `execute_luau` can't see game `shared.*`, so use a temporary Script for handlers depending on it.
- §7 (data migration): added "migrate before `Reconcile()`; Reconcile only fills missing fields". Changed `migrate` to use a deep copy (`deepCopy` helper) instead of the shallow `table.clone`, with a one-line reason.
- §8 (Input Action): added that simulated key presses are unreliable without window focus, so a non-toggle may be a test artifact.

**`references/mcp-integration.md`**
- Added a "Hub additions from roblox-lessons" box under Luau execution: plugin-context `shared`/`require` cache, `Clone()` before `require`, connections die per call, only the first return value shows, kicking the only player wedges Play, `screen_capture` camera cancels prompt holds, `PromptShown` before `InputHoldBegin`.
- Added a `multi_edit` bullet: in a Rojo project, edit files on disk and wait for sync; `multi_edit` changes are overwritten by Rojo.

**`references/agent-safety.md`**
- Trimmed the self-referential "for a long time this skill covered it in four bullet points…" paragraph.
- Fact 6: added the Studio-only store mitigation (`NAME .. "_Studio"`).
- "Never treat a marketplace asset as trusted": added the quarantine-scan-reject rule for any asset containing a script.

**`references/datastore-persistence.md`**
- Rate limits and Storage & Access Limits: added "verify on create.roblox.com" notes (the latter includes unverified billing/"Extended Services" claims).
- ProfileStore "Data Migration": replaced "supports schema versioning via reconciliation" with the correct statement (Reconcile only fills missing fields) and the `roblox-lessons` migration rules, including never renaming the store.
- ProfileStore example: Studio-only store name via `RunService:IsStudio()`; comment to migrate before `Reconcile()`.
- Best practices 6–7: scoped `UpdateAsync` and the `BindToClose` snippet to hand-rolled DataStore code (ProfileStore handles both).
- ProfileService → ProfileStore: flagged the "same underlying keys" and auto-save interval claims as unverified.

**`references/monetization.md`**
- Replaced the "BindReceiptHandler is the newer route / ProcessReceipt is legacy" note with "BindReceiptHandler is a newer alternative; ProcessReceipt still works".
- Added the `roblox-lessons` receipt rules (one handler, dedupe by `PurchaseId` in the player's save, no in-memory dedupe, `NotProcessedYet` when unsure).
- Game passes: added live ownership flip, retry, creator auto-owns passes (test from an alt), free Studio test purchases.
- Added a short "Paid random items (policy)" section pointing to `roblox-lessons`.
- Flagged the Transfers API / Roblox Plus / publishing fee / Managed Pricing / cross-game-sales sections as unverified.

**`references/legacy-migration.md`**
- Added `BadgeService:AwardBadge` → `AwardBadgeAsync` to the migration table.
- DataStore2/raw → ProfileStore loader: fixed a bug where a failed legacy read still set `Migrated = true` (silently losing the player's data); now ends the session and kicks. Added a note distinguishing this copy-to-new-store migration from changing the format within one store.
- Phase 4: "keep legacy read path for at least two weeks" → keep it until every key is migrated.
- 2026 section: added an "upstream's diffs, not re-verified" note; removed rows that only listed Roblox-internal, uncallable members (0.742 internal-additions row, 0.741 internal-additions row, 0.740 "other RobloxScriptSecurity additions" row) and the 0.741 "corrections to older rows" audit block.

**`references/security-hardening.md`**
- §8 third-party assets: added the `roblox-lessons` reject-any-scripted-asset rule above upstream's sandboxing advice (kept for reference, labelled "upstream").
- Replaced the pointer to upstream's `~/RobloxDocs/scripts/audit-skill-examples.py` with "re-derive from the API reference".
- §7: noted that direct `UpdateAsync` on a ProfileStore-managed key is wrong.
- §10: flagged the 2026 BanAsync/Server Authority/scoped-ID claims as unverified.

**`references/networking.md`**
- Added the initial-sync note: queued server→client fires reach only the first listener; use `Request*` re-sync remotes and a loading screen that re-requests and times out.
