---
name: roblox-to-issues
description: Break a Roblox game plan, PRD or feature idea into small vertical "tracer bullet" slices, each cutting through client, server, remotes, data and UI for one player-facing capability, and each done only when verified in Studio through the Roblox Studio MCP. Use when turning a concept into buildable tickets, splitting work, planning what to build next, or stopping an agent from building a whole game in one pass.
---

# Roblox to Issues (Vertical Slices)

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

Break a plan into small issues that are each **buildable and verifiable on their own**. This is the antidote to "build the whole game in one go, everything half-broken."

## Where slices live

Use whatever tracker the project already uses: GitHub issues via `gh` (only after the user approves publishing), or the project's existing plan/task file in the repo. If there is none, ask the user where slices should go; do not invent new tracker folders or config files.

## What a vertical slice is

A **tracer bullet**: the thinnest end-to-end path a player can feel, cutting through **every layer it touches** (client input, server authority, remotes, saved data, UI), not one horizontal layer.

- **Right (vertical):** "Player taps the ore, server grants 1 coin, HUD shows the new balance, balance survives rejoin."
- **Wrong (horizontal):** "Build the entire economy module." / "Build all the UI." Nothing is playable until everything is done.

### Slice rules

- Each slice delivers one narrow but **complete** player-facing capability.
- Each slice is **verifiable in Studio through the MCP** on its own; if it can't be, split it.
- Prefer many thin slices over a few thick ones.
- Valuable state (currency, inventory, purchases, rewards, progression) is **server-authoritative from the first slice**, never a client-trust shortcut to fix later.
- **Slice 1 is the tracer bullet**: the smallest thing proving the core loop end to end (one action, one reward, one visible next goal).

### Slice types

- **AFK**: can be built and verified without a human decision. Prefer these.
- **HITL**: needs the human: a design approval, a balance or price call, publishing, anything spending Robux, or a test only they can run (real purchases, phones, multi-client sessions). A UI slice with no agreed look is HITL: add a design-approval slice first and block the UI slice on it.

## Process

### 1. Gather context

Work from the plan or conversation. If the user passes a reference (issue number, file path), read it fully. Use the game's own vocabulary.

### 2. Draft the slices

Core-loop tracer bullet first, then layer outward (persistence, progression, social, monetization, polish). Each later slice builds on one that is already playable.

### 3. Quiz the user

Present a numbered list. For each slice show: **Title** (player-facing), **Type** (AFK/HITL), **Blocked by**, **Verification** (the exact MCP steps that prove it), **Server-authoritative?** (which state it protects). Ask whether granularity, dependencies and types are right. Iterate until approved.

### 4. Publish

Publish approved slices blockers-first so later slices can reference real IDs. Do NOT close or modify a parent PRD/issue.

<slice-template>
## What to build

The end-to-end behavior: what the player does and what the server does. Not a layer-by-layer implementation.

## Layers touched

- Client: ...
- Server (authoritative): ...
- Remotes: ...
- Data / persistence: ...
- UI: ...

## Done when (verified in Studio via MCP)

- [ ] Code is in the repo and Rojo-synced; a fresh Play (`start_stop_play`) shows no new errors or warnings in `get_console_output`.
- [ ] <exact action> produces <exact result>, observed through `execute_luau` (instances, attributes, captured remote payloads), not assumed.
- [ ] Client-to-server remotes accept a valid payload and silently reject forged ones.
- [ ] Server-to-client syncs fire, including on join.
- [ ] Valuable state is server-validated and survives rejoin (if applicable).
- [ ] UI and world changes checked with `screen_capture` (UI also at phone size).
- [ ] Temporary test scripts removed. Anything untestable here is named with a short human test.

## Blocked by

The blocking slice, or "None - can start immediately".
</slice-template>

## Status

A slice is **done** only when every "Done when" box is ticked from real MCP observations. "It compiles" or "the code looks right" is not done. Mark slices needing human approval as built-and-verified until the human signs off. The human pushes commits.
