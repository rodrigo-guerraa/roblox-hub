---
name: roblox-networking
description: "Roblox client-server networking: RemoteEvents, RemoteFunctions, UnreliableRemoteEvents, bindables, argument validation, rate limits, server authority, payload budgets, hit validation with GetServerTimeNow, TextChatService. Use when adding, changing, debugging or auditing anything sent between client and server: remote validation, cooldowns, laggy or dropped events, desync, payload size, exploit-proofing remotes."
---

# Roblox networking

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

## When to use

Adding a remote, handling untrusted input, adding cooldowns, assigning authority, or reviewing remote security. Broader exploit audits: `roblox-security`.

## Quick reference

- Every client argument is attacker-controlled: validate type, size, ownership, state, distance and cooldown on the server. Exploits with bad arguments are rejected silently.
- Look up prices, damage, rewards and permissions from server-owned definitions; the client asks for "buy item Y", never "subtract 20 coins".
- Choose the authority model first. Server Authority (`Workspace.AuthorityMode = Server` plus its settings bundle) uses client prediction and rollback; it is not `SetNetworkOwner`. Simulation input there uses `InputAction` + `BindToSimulation()`, not a remote.
- `RemoteEvent` for most requests; keep `RemoteFunction` calls short and bounded.
- `RemoteEvent` is reliable but not ordered against property/attribute replication; use one explicit channel or version state. `UnreliableRemoteEvent` only for replaceable data (droppable, 1000-byte cap).
- Engine ceiling: about 500 FireServer requests/s per client, pooled across remotes of the same type. A ceiling, not a target.
- Budget rate x bytes x recipients; snapshot on join, diffs after.
- Hit timestamps are untrusted context, never proof; bound freshness and validate against server history (full.md §3a).
- Typed schemas/IDLs do not replace security checks. Pin generators and verify generated output in CI.
- Check NaN/infinity first (`x ~= x`, `math.abs(x) == math.huge`); `NaN` defeats `<`/`>`. `utf8.len` catches malformed UTF-8 that would fail a DataStore save.
- Serialization: functions arrive `nil`, metatables stripped, mixed keys mangled, `nil` truncates arrays, tables are copies. Validate field by field; share state via server-owned snapshots or ids.
- Rate limits protect the server; validation still rejects invalid requests. Bindables are same-side only.
- Record suspicion with thresholds; never punish one malformed packet.
- `ProximityPrompt`/`ClickDetector`/`DragDetector` triggers are remote-equivalent input: validate them the same way.

## Initial sync (from `roblox-lessons` data.md)

A queued RemoteEvent payload is delivered only to the **first** client listener. If several client scripts need an on-join push, each fires its own `Request*` remote on startup; the server handler only re-sends, never mutates. A loading screen waits for the list of on-join events, re-requests any it missed, and times out with a warning naming them.

> Validation, throttling, budgets, chat and mock patterns: [references/full.md](references/full.md)
