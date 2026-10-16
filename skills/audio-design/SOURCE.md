# Source

| | |
| --- | --- |
| Upstream | https://github.com/gamedev-skills/awesome-gamedev-agent-skills |
| Path | `skills/disciplines/audio-design/` |
| Pinned commit | `0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd` |
| License | Apache-2.0. `LICENSE` and `NOTICE` are copied verbatim from the upstream repo root. |
| Vendored | 2026-10-16 |

## Files taken

- `SKILL.md` → `SKILL.md` (modified)
- `references/adaptive-music.md` → `references/adaptive-music.md` (modified)
- `LICENSE`, `NOTICE` (from the repo root, unmodified)

Nothing else was taken. Upstream has no `scripts/` or `agents/` files for this skill; no code from upstream is executed.

## Modification notice (Apache-2.0 §4(b))

**These files were modified.** `SKILL.md` and `references/adaptive-music.md` are substantially rewritten, and each one carries a "Modified; see SOURCE.md" footer. The engine-agnostic design substance is kept; the changes are listed below.

## Changes we made

- Frontmatter: `name` kept as the folder name; `description` rewritten (under 900 chars) to say it is engine-agnostic guidance and when to use it in a Roblox game.
- Added the line "Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins." near the top of every file, and an "On Roblox" section to SKILL.md.
- On Roblox mapping: SoundGroups as buses, linear Volume (0-10) with dB conversion, SoundEffect children (Compressor/Reverb/EQ/PitchShift) and tween-based ducking, the newer wire-based Audio API noted, Roblox-licensed library audio only (APM Music, Pro Sound Effects, rbxasset://sounds), client vs server playback, PlaybackSpeed variation, TimePosition as the music clock, PlaybackLoudness client-only.
- Removed all Godot AudioServer/AudioStreamPlayer GDScript samples and the specific LUFS loudness target. Replaced them with Luau sketches for layered fades and bar-quantized switching.
- Reference: added a Roblox reality check (library tracks are full mixes, not stems; layered Sounds can drift; test loop seams) and simulator-flavoured intensity inputs; dropped the FMOD/Wwise middleware advice.
- Removed the router and engine-detection wording, the "When not to use" lists, and every link to upstream skills we did not vendor. Related links now point only to the vendored skills and `roblox-lessons`.
- Trimmed SKILL.md to 5 KB or less; the detail lives in references/.
