---
name: game-feel
description: Engine-agnostic game-feel ("juice") design guidance, adapted for Roblox. Covers layered feedback, decaying-trauma camera shake, faked hit-stop, eased tweens, squash and stretch, importance tiers and accessibility toggles. Use when a Roblox action (dig, hatch, collect, buy, rebirth, hit, jump, pickup) works but feels flat or weightless, when adding TweenService pops, ParticleEmitter bursts, sounds, camera shake, flashes or coins flying to a counter, or when deciding how much feedback an event deserves. It adds polish on top of a working mechanic; it does not implement the mechanic.
---

# Game feel (juice)

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

The difference between a mechanic that works and one that feels good is feedback: a layered, briefly exaggerated response to each action.

## On Roblox

- **Client-only, on server-confirmed events.** Play the payoff when the server's push arrives (a RemoteEvent, an attribute change, a coin delta), not on the button press. Give the press a neutral response, so a refused action never celebrates.
- **Tweens:** `TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Back, Enum.EasingDirection.Out), goal)`. GUI pops go through their own `UIScale`, never one shared with fit-to-screen scaling. Models tween a value that drives `PivotTo`.
- **Particles:** `ParticleEmitter:Emit(n)` from a pooled, disabled emitter. Small additive particles vanish in daylight and inside avatars (roblox-lessons `assets-visuals.md`).
- **Sound:** route through `SoundGroup`s and vary `PlaybackSpeed` slightly. See `audio-design`.
- **Camera shake:** offset `Camera.CFrame` on the client after the default camera runs (`BindToRenderStep` at `Enum.RenderPriority.Camera.Value + 1`), or use `Humanoid.CameraOffset`. Never move the character.
- **Hit-stop:** Roblox has no global time scale, and you can't pause physics for one player. Fake it locally: `AnimationTrack:AdjustSpeed(0)` for 50 to 120 ms, then restore.
- **Flash:** a `Highlight`, or a `SurfaceAppearance.Color` tint on textured meshes, tweened back.
- **Screen effects** (coins flying to the counter, floating text, full-screen flash) go on a high-`DisplayOrder` ScreenGui with `IgnoreGuiInset`.

## Core principle

One satisfying event is 5 to 8 tiny responses within about 100 ms: a sound, a burst, a flash, a small shake, a number pop and a counter bump. Exaggerate briefly, then return to rest. Scale the response to the event's importance: a coin tick is not a rebirth.

## Workflow

1. Confirm a client-visible event hook exists. If it doesn't, add it first.
2. Pick 2 or 3 feedback channels per event. Add more until the event reads clearly, then stop.
3. Ease everything: Back Out for a pop, Quad or Cubic Out for settling, Sine InOut for camera moves. Linear motion feels robotic.
4. Save shake and hit-stop for impacts. Keep them short and scaled, and never use them on routine actions.
5. Keep juice off the simulation. Shake the camera, not the body. Hit-stop is purely visual.
6. Define small, medium and large presets, and assign every event to one.
7. Verify by triggering each event repeatedly. Check that it fires, decays to rest, never blocks input, and reads on a phone.

## Pitfalls

- Moving the `HumanoidRootPart` for shake breaks physics and replication.
- A fresh `math.random` offset every frame buzzes. Multiply a decaying trauma value by `math.noise` or summed sines instead.
- Permanent exaggeration (a scale that never resets, a shake that never decays) stops reading as feedback.
- Over-juicing routine actions hides real impacts and causes nausea. Offer reduce-shake and reduce-flash options.
- Long freezes or uncancellable sequences block input.
- Effects spawned per event without cleanup leak. Use pools or `Debris:AddItem`.
- Celebrating before the server confirms, then the action fails.

## References

- `references/feedback-recipes.md`: the trauma math with a Luau sketch, an easing cheat sheet using Roblox `EasingStyle` names, the rest of the feedback menu, importance tiers, accessibility, and Roblox bindings.

Related: `audio-design`, `game-ui-ux`, `roblox-lessons`.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `SOURCE.md`.
