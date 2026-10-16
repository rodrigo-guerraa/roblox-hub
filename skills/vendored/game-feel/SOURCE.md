# Source

| | |
| --- | --- |
| Upstream | https://github.com/gamedev-skills/awesome-gamedev-agent-skills |
| Path | `skills/disciplines/game-feel/` |
| Pinned commit | `0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd` |
| License | Apache-2.0. `LICENSE` and `NOTICE` are copied verbatim from the upstream repo root. |
| Vendored | 2026-10-16 |

## Files taken

- `SKILL.md` → `SKILL.md` (modified)
- `references/feedback-recipes.md` → `references/feedback-recipes.md` (modified)
- `LICENSE`, `NOTICE` (from the repo root, unmodified)

Nothing else was taken. Upstream has no `scripts/` or `agents/` files for this skill; no code from upstream is executed.

## Modification notice (Apache-2.0 §4(b))

**These files were modified.** `SKILL.md` and `references/feedback-recipes.md` are substantially rewritten, and each one carries a "Modified; see SOURCE.md" footer. The engine-agnostic design substance is kept; the changes are listed below.

## Changes we made

- Frontmatter: `name` kept as the folder name; `description` rewritten (under 900 chars) to say it is engine-agnostic guidance and when to use it in a Roblox game.
- Added the line "Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins." near the top of every file, and an "On Roblox" section to SKILL.md.
- On Roblox mapping: client-only feedback on server-confirmed events, TweenService/TweenInfo, ParticleEmitter:Emit pools, SoundGroups, camera shake via BindToRenderStep after Camera priority or Humanoid.CameraOffset, faked hit-stop (Roblox has no global time scale) via AnimationTrack:AdjustSpeed(0), Highlight/SurfaceAppearance.Color flashes, high-DisplayOrder effect ScreenGui.
- Removed all Godot 4.7 GDScript and Unity C# samples (including a Unity pop coroutine with an unused variable). Replaced them with one Luau trauma-shake sketch and prose recipes.
- Easing table rewritten with Roblox EasingStyle/EasingDirection names; importance tiers re-keyed to simulator events (coin tick, dig, hatch, rebirth).
- Added Roblox notes: client network ownership for knockback impulses, lighting post-process punches (BlurEffect, ColorCorrectionEffect, FieldOfView), counter count-up feedback, Debris cleanup, particle-visibility pointer to roblox-lessons.
- Fixed a stray box-drawing character (U+2592) in the upstream 'Chromatic/vignette' line (dropped with the line rewrite).
- Removed the router and engine-detection wording, the "When not to use" lists, and every link to upstream skills we did not vendor. Related links now point only to the vendored skills and `roblox-lessons`.
- Trimmed SKILL.md to 5 KB or less; the detail lives in references/.
