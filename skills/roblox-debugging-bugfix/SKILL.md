---
name: roblox-debugging-bugfix
description: Disciplined debugging for Roblox games kept in git and synced to Studio with Rojo. Build a fast repro loop driven through Roblox Studio's built-in MCP (start_stop_play, get_console_output, execute_luau, character_navigation, screen_capture), rank falsifiable hypotheses, probe with tagged logs in temporary scripts, fix the repo source, and re-verify in a fresh Play. Use for console errors, broken UI, failed gameplay systems, remote or data issues, regressions, intermittent bugs, and root-cause reports.
---

# Roblox Debugging Bugfix

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

## Goal

Move from symptom to verified fix without guessing. All game code lives in the git repo and reaches Studio through Rojo; fixes are made in repo files, never only in the Studio copy.

## Phase 1: Build a repro loop first (this is the skill)

Everything else is mechanical once you have a fast, repeatable pass/fail signal. Spend disproportionate effort here, before touching a fix. Ways to build one, roughly in order:

1. **Studio playtest repro**: `start_stop_play`, drive the steps with `character_navigation`, `user_mouse_input` or `execute_luau` in the Client datamodel, then read `get_console_output`.
2. **Direct harness**: exercise the suspect code with a fixture input. Pure shared modules: `execute_luau` can `require` a `Clone()` of the ModuleScript (plugin `require` caches the first load). Live server APIs: `execute_luau`'s `shared` is a plugin sandbox, not the game's, so create a temporary `Script` that calls the API and writes results to its own attributes; read them, then `Destroy()` it.
3. **Targeted scenario**: spawn the minimal instances/state that hit the code path.
4. **Replay a captured payload**: capture the real remote payload (an `OnClientEvent` listener storing JSON on a `LocalPlayer` attribute) or the offending save, and push it back through the code path; include forged payloads that must be rejected.

Make the loop fast, narrow and deterministic (pin randomness and timing). Connections made inside one `execute_luau` call die when it returns; for checks across calls use a temporary LocalScript driven by an attribute.

**Intermittent bugs:** aim for a higher reproduction rate, not a clean one-shot. Loop the trigger, add stress, narrow timing windows.

If you cannot build a loop, stop and say so: list what you tried and ask the human for a captured artifact or a specific manual test (real purchases, phones, multi-client).

## Phase 2: Reproduce

Confirm the loop produces the failure the user described (not a lookalike), that it repeats, and capture the exact symptom for later verification.

## Phase 3: Hypothesize

Write **3-5 ranked, falsifiable hypotheses** before testing any. Each predicts: "if X is the cause, changing Y makes it disappear." Show the list to the user; they often re-rank instantly. Proceed on your ranking if they are away.

## Phase 4: Instrument

One probe per hypothesis; change one variable at a time. Prefer reading real values (instances, attributes, captured payloads via `execute_luau`) over log spam. **Tag every diagnostic print** with a unique prefix like `[DEBUG-a4f2]`. Diagnostic prints go only in temporary scripts (for example `src/server/TempVerify.server.lua`, `src/client/TempVerify.client.lua`, or a temporary Script created via `execute_luau`), **never in production scripts**. For performance, measure first (`os.clock`, MicroProfiler, instance counts) and bisect.

## Phase 5: Fix and verify

1. Make the smallest root-cause fix in the repo source; wait for Rojo to sync (poll the script's `Source` for the new text) before pressing Play.
2. Fresh Play, re-run the repro, confirm `get_console_output` is clean (no new errors or warnings).
3. Turn the repro into a durable check where a seam exists: a TestEZ spec for pure shared modules, or a documented MCP verification step. If no good seam exists, report that as a finding.
4. Delete every temporary script and grep the repo for the `[DEBUG-` prefix; it must return nothing.

## Common bug classes

- Client/server state mismatch; UI not updating after a server change.
- Remote payload trusted without validation.
- Duplicated or never-disconnected connections.
- Save load/save races; initial-sync payload consumed by the wrong listener (a queued RemoteEvent payload reaches only the first listener).
- Publish-before-yield bugs on `shared` service tables.
- Renamed or missing instance paths; Rojo not synced, so Studio runs stale code.
- Races between character spawn, UI creation and server init.

## Fix rules

- Root-cause fixes over defensive silence; never swallow errors without context.
- Validate at trust boundaries; no unrelated refactors in bug fixes.
- The human owner pushes commits; commit only verified work when asked.

## Output

- Repro (the MCP steps) and root cause (which hypothesis held).
- Files changed and verification performed.
- Residual risks and any human-only test.
- Post-mortem: what would have prevented it (missing seam, tangled boundary, hidden coupling)?
