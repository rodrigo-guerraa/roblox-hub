---
name: level-design
description: Engine-agnostic level-design practice, adapted for Roblox worlds. Covers player metrics, blockout before art, critical path and gating, the tension/rest pacing curve, teach-then-test, and guidance through light, landmarks and leading lines. Use when planning or reviewing a Roblox map, hub or zone layout; deciding zone order and progression gates; sizing paths, gaps, fences and jumps from Humanoid metrics; choosing StreamingEnabled or fast-travel; or when players get lost, stuck or bored in the world. For world generation it assumes a re-runnable builder script synced by Rojo, not hand-placed parts.
---

# Level design

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

A level is a sequence of intentional experiences delivered through space. Design is a process: derive metrics, block out, play, then dress. Never dress first.

## On Roblox

- **Metrics come from the Humanoid.**
  - Defaults: `WalkSpeed` 16 studs/s, `JumpHeight` 7.2 studs, `Workspace.Gravity` 196.2 studs/s².
  - So a flat running jump clears about 8.5 studs, and a character is about 5 studs tall.
  - Re-derive the numbers if upgrades raise walk speed. Measure them in play.
- **Blocking walls:** anything under 7.2 studs can be jumped. A wall that must block gets an invisible collider above that height.
- **Build the world from a builder script** (a Rojo-synced ModuleScript run in Edit), never by hand-placing objects that code depends on. The blockout is the builder with plain Parts; dressing swaps in assets later. Keep a separate folder for user decoration that the builder never touches.
- **Server-enforced gates:** progression gates (a rebirth tier, a key, a pass) are checked on the server for every action in the zone. A client may make a gate non-solid locally, but that is cosmetic.
- **StreamingEnabled:**
  - On: big worlds and lower memory, but far instances may not exist on the client. Use bounded `WaitForChild`, `ModelStreamingMode = Persistent` for anchors clients must always resolve, and `RequestStreamAroundAsync` before teleports.
  - Off: simpler, but everything loads, so budget the part count for phones.
- **Fast travel:** `Character:PivotTo(target.CFrame)` to named target parts. Guidance can use a `PathfindingService` route drawn as a trail, a `Beam` and a `Highlight`.
- **Terrain** snaps to a 4-stud grid. Turn the terrain under paths to a grassless material so grass doesn't poke through.

## Workflow

1. **Derive metrics** (speed, jump, reach, camera) and size every gap, ledge, path and fence in them.
2. **Block out** the whole level with primitives at the correct scale, and validate flow, sightlines and reachability while changes are cheap.
3. **Define the critical path** (start to goal) and the golden path most players take. Hang optional branches off it.
4. **Pace it** as a rising sawtooth of tension and rest, with a breather before each spike.
5. **Teach, then test:** introduce each mechanic somewhere safe, let the player practise, then test it under pressure.
6. **Gate with intent:** locks, abilities and progression tiers. Guide with light, lines and landmarks rather than walls.
7. **Playtest and iterate:** watch where players get lost, stuck or bored, and fix the blockout before dressing.

## Patterns

- **Pacing as data:** a list of beats `{ area, type = "teach" | "combat" | "rest" | "climax", intensity }`. Read the intensity column: it should rise overall with dips, never flatline.
- **Gating graph:** areas with exits that may need a key or ability, and areas that grant them. A flood fill that only crosses an exit once its requirement is obtainable proves there is no soft-lock.

## Pitfalls

- Dressing before the layout plays well.
- Geometry that ignores metrics: impossible gaps, jumpable "walls", paths narrower than the camera needs.
- Flat pacing, or testing a mechanic before teaching it.
- Soft-locks: a gate whose key is only reachable past the gate.
- Nothing to draw the eye, so players get lost.
- Unsignposted one-way drops.
- Client-only gates that exploiters walk through.
- Hand-edited builder-owned objects, lost on the next rebuild.

## References

- `references/pacing-and-flow.md`: the tension curve, the teaching loop, paths and gating tools, readability, hub-and-spoke worlds, and a blockout review checklist.

Related: `game-feel`, `game-ui-ux`, `roblox-lessons`.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `SOURCE.md`.
