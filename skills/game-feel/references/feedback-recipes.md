# Feedback recipes: depth for `game-feel`

This file has the detail the `game-feel` SKILL.md defers: the shake math, an easing cheat sheet, the rest of the feedback menu, importance tiers, accessibility, and how each piece binds to Roblox. Where it conflicts with `roblox-lessons`, `roblox-lessons` wins.

## 1. The trauma model (why shake feels good)

Track one `trauma` value in `[0, 1]`. Events **add** trauma, and it **decays** linearly each frame. The shake amount is `trauma^2` (or `trauma^3`), so:

- small, frequent events barely nudge the screen,
- big events punch hard,
- the shake always ends on its own.

Offset and roll are `max * shake * noise(t)`. Sample smooth noise over time, never a fresh random number per frame (that buzzes like static).

Luau sketch (a client LocalScript). The default camera script sets `Camera.CFrame` every frame at `Camera` priority, so an offset applied just after it never accumulates:

```lua
local RunService = game:GetService("RunService")
local trauma, t = 0, 0
local MAX_OFFSET, MAX_ROLL, DECAY = 0.6, math.rad(2), 1.2

local function addTrauma(amount)
	trauma = math.min(trauma + amount, 1)
end

RunService:BindToRenderStep("Shake", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if trauma <= 0 then return end
	trauma = math.max(trauma - DECAY * dt, 0)
	t += dt * 25
	local s = trauma * trauma
	workspace.CurrentCamera.CFrame *= CFrame.new(
		MAX_OFFSET * s * math.noise(t, 1.5),
		MAX_OFFSET * s * math.noise(t, 2.5),
		0
	) * CFrame.Angles(0, 0, MAX_ROLL * s * math.noise(t, 3.5))
end)
```

Starting values to tune: an offset of 0.3 to 1 stud, a roll of 1 to 3 degrees, a decay of 1.0 to 1.5 trauma per second, and per-event trauma from 0.15 (light) to 0.8 (heavy). `Humanoid.CameraOffset` is a simpler alternative: it doesn't fight custom camera scripts, but it can't roll. For UI shake, apply the same model as pixel offsets on a container.

## 2. Easing cheat sheet

| Goal | Roblox `TweenInfo` | Notes |
| --- | --- | --- |
| Pop in (UI or model) | `Back`, `Out` | Overshoots, then settles |
| Bouncy landing | `Elastic` or `Bounce`, `Out` | Use sparingly; reads as cartoonish |
| Settle or decelerate | `Quad` or `Cubic`, `Out` | The default for coming to rest |
| Anticipation or wind-up | `Cubic`, `In` | Slow start before a fast action |
| Smooth A to B | `Sine`, `InOut` | Camera moves, panel slides |

`TweenInfo.new(time, style, direction, repeatCount, reverses, delayTime)`. Tween a `UIScale.Scale` for GUI pops. To tween a model, tween a `CFrameValue` or `NumberValue` and apply it with `PivotTo` on `.Changed`. A squash-and-stretch pop sets a squashed scale instantly on the event (for example X 1.3, Y 0.7), then tweens back to 1 with Back Out.

## 3. The rest of the feedback menu

- **Flash:** a `Highlight` with a white `FillColor`, its `FillTransparency` tweened from about 0.2 back to 1 over 1 to 3 frames. Textured MeshParts ignore `Color`, so tint `SurfaceAppearance.Color` instead.
- **Knockback:** a short, clamped impulse away from the hit, with a brief control lockout. A player's character is physically owned by their own client, so a server-side impulse may not take effect. Apply it on the owning client, or set velocity there.
- **Number or text pop:** a `BillboardGui` label (or a ScreenGui label placed with `Camera:WorldToViewportPoint`) that rises, fades and eases out, with random horizontal drift so stacked pops fan out.
- **Particles:** a short burst at the contact point. Keep one disabled emitter per effect and call `Emit(n)`; don't create and destroy an emitter per hit. For effects around a character, emit from an invisible part sized to the character's bounds, with `LightInfluence = 0` (roblox-lessons `assets-visuals.md`).
- **Fake hit-stop:** pause the relevant `AnimationTrack`s (`AdjustSpeed(0)`) and hold for 40 ms (light) to 150 ms (heavy), then restore with `task.delay`. Freeze only the actors involved; the server world keeps running.
- **Anticipation and follow-through:** a small wind-up before a big action and a settle after it read as weight. That is animation work, not code.
- **Post-process punch:** briefly tween a `BlurEffect.Size`, a `ColorCorrectionEffect.Brightness` or `Camera.FieldOfView` for big moments.
- **Counter feedback:** count a number up over about 0.7 s instead of snapping it, bump the counter's scale on a gain, and flash red on a spend.

## 4. Importance tiers (keep the whole game proportional)

| Tier | Trauma | Hit-stop | Particles | Extra | Example events |
| --- | :-: | :-: | :-: | --- | --- |
| Small | 0.10–0.20 | none | 0–4 | tick sound | coin tick, button click, footstep |
| Medium | 0.30–0.50 | 0.04–0.06 s | 6–12 | flash | dig done, egg placed, purchase, pickup |
| Large | 0.70–1.00 | 0.10–0.15 s | 20–40 | flash, FOV punch, banner, confetti | rare hatch, level-up, rebirth, boss hit |

Put the presets in one client ModuleScript so every script calls `Feedback.play(tier, position)` instead of hand-tuning each event.

## 5. Accessibility (ship these toggles)

- **Reduce screen shake:** scale trauma output by a 0 to 100% setting.
- **Reduce or disable flashing** (photosensitivity): replace white flashes with a static tint.
- **Reduce camera motion:** cut the roll and the FOV punches.
- Roblox exposes some user accessibility preferences on `GuiService` (for example a reduced-motion setting). Check the current API and honour it where available.

## 6. Roblox binding summary

- Tweens: `TweenService` and `TweenInfo`. Pooled one-shots: `ParticleEmitter:Emit`.
- Shake: `BindToRenderStep` after `Camera` priority, or `Humanoid.CameraOffset`.
- Timing: `task.delay` and `task.wait` use real time, so Roblox has no time-scale trap.
- Cleanup: `Debris:AddItem(instance, seconds)` or pools.
- Feedback runs on the client and listens to server pushes; the server never plays cosmetic effects for one player.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `../SOURCE.md`.
