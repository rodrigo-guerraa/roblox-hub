---
name: roblox-security-economy
description: Build and review security-sensitive Roblox economy code - currency, inventory, saves, trading, purchases, rewards, anti-dupe logic, RemoteEvent validation, server authority, receipt handling and exploit-resistant progression. Maps source-to-sink value flows in the git repo, patches the repo source, and proves the protections in Studio through the Roblox Studio MCP with valid and forged payloads. Use whenever code grants, spends, trades, saves or sells value.
---

# Roblox Security Economy

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

## Goal

Protect valuable game state while keeping the loop fair. Anything that grants, spends, trades, saves or sells value is server-authoritative.

## High-risk surfaces

- Currency and premium currency.
- Inventory, pets, skins, tools, boosts and quest rewards.
- Trading, gifting, crafting, upgrades, prestige and loot rolls.
- Developer product receipts and gamepass checks.
- Daily rewards, streaks, codes, event and group rewards.
- Client remotes requesting grants, damage, teleports, placement or progression.

## Server authority rules

- Calculate rewards and validate eligibility on the server.
- Store canonical balances and inventory on the server; client UI is display and intent only.
- Validate every remote argument: type, a valid key in its shared data module, ownership, affordability, distance/cooldown. Silently reject malformed, replayed, impossible or too-frequent requests.
- Make purchases and valuable grants idempotent.
- Pay repeatable rewards in seconds of the player's income with a small floor; any repeatable purchase that multiplies value needs a cap or a price ladder.

## Saves and receipts

- Use session-locked saves (ProfileStore); plain `GetAsync`/`SetAsync` lets two servers overwrite each other during fast server hops.
- Save compact canonical state, not UI state.
- Store `dataVersion` and migrate step by step on load; a newer or unmigratable save is left untouched and the player is asked to rejoin. **Never rename the DataStore to change the format** (that is a new empty store).
- Studio playtests save to a separate Studio-suffixed store; Studio conveniences (join grants, force-owned passes) are guarded by `RunService:IsStudio()`.
- Exactly one `ProcessReceipt` handler per server. **Dedupe by `PurchaseId` stored in the player's own session-locked save** (keep the last ~50), written with the grant. Return `NotProcessedYet` whenever unsure: player gone, data not loaded, nothing to grant, policy-blocked.
- If currency can be bought with Robux, every roll paid with it is a paid random item: disclose exact odds before purchase and gate by `PolicyService` `ArePaidRandomItemsRestricted` (a failed lookup counts as restricted).

## Trading and gifting

- Server-owned trade sessions; lock offered items while pending.
- Both parties confirm the exact final offer; revalidate ownership just before commit.
- Commit atomically from server state; log valuable trades and grant paths.

## Review workflow

1. Search the repo source (grep, not the Studio copy) for remotes, currency names, save calls, receipt handlers and grant functions.
2. Read every file that touches value; map each source-to-sink flow before patching.
3. Patch the repo files; wait for Rojo to sync before testing.
4. Verify in Studio through the MCP: fresh Play, clean `get_console_output`; fire each remote from the Client datamodel with a valid payload (accepted) and forged ones (wrong types, unknown keys, unaffordable, out of range, too fast), and confirm the forged ones change nothing.
5. Test receipts without spending: a temporary Script calls the real handler with fake receipts (`execute_luau`'s `shared` is a plugin sandbox, not the game's); check exact amounts, refusals, and that a repeated `PurchaseId` grants once. Remove the temporary script afterwards.
6. Name what cannot be tested here (real purchases, live policy results) as a short human test.

## Output

- Values protected and the trust boundary.
- Server validation rules.
- Abuse cases prevented, with the forged payloads that were rejected.
- Remaining risks and manual purchase tests for the human.
