# Pacing, flow, teaching and guidance

Geometry is the medium; the goal is a felt rhythm. Where this conflicts with `roblox-lessons`, `roblox-lessons` wins.

## The difficulty and tension curve

Plot intended intensity against progress. Two principles:

- **Overall rise with local dips.** Tension trends up toward a climax in a *sawtooth*: spikes (combat, gauntlets, bosses, hard gates) separated by rests (exploration, rewards, safe hubs). A monotone high numbs the player; a monotone low bores them.
- **Rest before the climax.** Put a clear breather (a vista, a reward cache, the hub) right before the hardest beat.

A useful rhythm: **introduce, build, peak, release, then repeat higher.** Each cycle's peak exceeds the last.

In a simulator or idle game the "level" is mostly the progression track. Pacing comes from how long each zone or rebirth gate takes, not from enemy density. Keep each gate's time in a sawtooth too: a fast early win, then longer goals with a reward or new zone between them (see roblox-lessons `economy.md`).

## The teaching loop

1. **Introduce** the mechanic in isolation, where failure is harmless.
2. **Develop** it: combine it with movement or a second element.
3. **Twist** it: change the context so the player applies the idea rather than a memorized motion.
4. **Test** it under time, health or resource pressure.

New mechanics meet the player before a test, never during one. On Roblox a step-by-step tutorial with world arrows can play the "introduce" role. Keep it short, and unlock the rest of the UI once it's done.

## Critical path, golden path and branches

- **Critical path:** the minimal route from start to goal. It must always be solvable with keys, abilities or tiers obtainable in order. Validate it.
- **Golden path:** the route most players actually take. Pace along this one.
- **Branches:** optional loops for exploration and reward that rejoin the golden path quickly.

Loops and shortcuts back to a hub, plus a fast-travel bar once the tutorial ends, reduce backtracking fatigue.

## Gating tools

- **Locks and keys:** explicit, readable order control.
- **Ability gates:** a chasm that needs a later ability. Validate the order in which abilities are acquired.
- **Progression gates:** a zone that opens at a rebirth tier or a level. Show what unlocks it on the gate itself ("Locked · Rebirth 2"), and enforce it on the server.
- **One-way drops:** enforce direction. Telegraph them.
- **Soft gates:** hazards or difficulty that say "not yet" without a hard wall.

## Readability and guidance (lead without walls)

- **Light and contrast:** a bright doorway reads as "go here".
- **Leading lines:** paths, fences and rails that point at the objective.
- **Landmarks:** a tall, unique silhouette (a volcano, a tower, a giant dino) orients players across the map. Keep it visible from the hub. With StreamingEnabled, far landmarks may not be streamed in, so mark them persistent or rely on low-detail stand-ins.
- **Colour and material:** one consistent colour for "interactive" or "exit".
- **Framing:** show the next goal from a high point before the player descends to it.

When playtesters get lost, the fix is usually guidance (a sightline, a light, a sign), not a wall.

## Hub-and-spoke worlds (common on Roblox)

- The hub holds spawn, the shops, the rebirth station and the leaderboards; players return to it often, so keep it compact and readable.
- Player plots or homes radiate from the hub. Spawn each player at their own plot's entrance.
- Zones sit behind gates in the order of progression, each with its own visual identity (material, palette, landmark).
- Invisible boundary walls at the world rim and between sectors stop players leaving the playable space; fences meant to block must be taller than a jump.

## 3D and camera notes

- Roblox's default third-person camera pulls back and collides with walls. Tight interiors and low ceilings feel cramped, so give rooms headroom.
- Players get lost in 3D more than in 2D, so landmarks and framed vistas matter more.
- Mobile players see less at a time and steer less precisely, so make paths wide and targets big.

## Blockout review checklist

- The critical path is solvable with keys, abilities and tiers available *in order* (no soft-lock).
- Every required traversal is within the metrics. Blocking walls are taller than a jump or have a collider.
- Pacing reads as a rising sawtooth, with a rest before each spike.
- Each mechanic is introduced safely before it's tested.
- The eye is guided toward the path; tested for "lost".
- Optional content rewards the detour and rejoins smoothly.
- It plays well as plain parts; dressing would not rescue a bad layout.
- The part count and streaming behaviour are acceptable on a phone.
- It is validated with players, not just the designer.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `../SOURCE.md`.
