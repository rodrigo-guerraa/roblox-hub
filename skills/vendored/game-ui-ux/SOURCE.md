# Source

| | |
| --- | --- |
| Upstream | https://github.com/gamedev-skills/awesome-gamedev-agent-skills |
| Path | `skills/disciplines/game-ui-ux/` |
| Pinned commit | `0a70cfc64672d512c5b5b6006b5dcb5cf90dbdbd` |
| License | Apache-2.0. `LICENSE` and `NOTICE` are copied verbatim from the upstream repo root. |
| Vendored | 2026-10-16 |

## Files taken

- `SKILL.md` → `SKILL.md` (modified)
- `references/layout-and-flow.md` → `references/layout-and-flow.md` (modified)
- `LICENSE`, `NOTICE` (from the repo root, unmodified)

Nothing else was taken. Upstream has no `scripts/` or `agents/` files for this skill; no code from upstream is executed.

## Modification notice (Apache-2.0 §4(b))

**These files were modified.** `SKILL.md` and `references/layout-and-flow.md` are substantially rewritten, and each one carries a "Modified; see SOURCE.md" footer. The engine-agnostic design substance is kept; the changes are listed below.

## Changes we made

- Frontmatter: `name` kept as the folder name; `description` rewritten (under 900 chars) to say it is engine-agnostic guidance and when to use it in a Roblox game.
- Added the line "Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins." near the top of every file, and an "On Roblox" section to SKILL.md.
- On Roblox mapping: Scale + AnchorPoint + UIAspectRatioConstraint + layouts, ScreenGui DisplayOrder ladder from roblox-lessons, a UIManager-style one-modal panel stack, top-bar inset/IgnoreGuiInset, ScreenGui.ScreenInsets, phone thumbstick/jump/chat buttons, gamepad focus via GuiService.SelectedObject / NextSelection* / SelectionImageObject, event-driven updates via remotes and attribute signals, LocalizationTable/AutoLocalize.
- Removed all Godot/Unity stretch modes, CanvasScaler settings, GDScript focus/stack code and the love2d cross-reference. Replaced with a Luau panel-stack sketch and Roblox scaling notes (FitWithinMaxSize vs ScaleWithParentSize, separate UIScales, canvas sizing from AbsoluteContentSize, phone/tablet/console test matrix) that defer to roblox-lessons ui.md.
- Diegetic UI section mapped to BillboardGui, SurfaceGui and ProximityPrompt.
- Removed the router and engine-detection wording, the "When not to use" lists, and every link to upstream skills we did not vendor. Related links now point only to the vendored skills and `roblox-lessons`.
- Trimmed SKILL.md to 5 KB or less; the detail lives in references/.
