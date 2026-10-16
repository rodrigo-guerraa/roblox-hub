# Layout, scaling and flow: depth for `game-ui-ux`

This file has the detail the `game-ui-ux` SKILL.md defers. Where it conflicts with `roblox-lessons` (especially `references/ui.md`), `roblox-lessons` wins.

## 1. Scaling

- **Scale, not Offset**, for anything that must fit the screen. Use Offset for hairlines, outlines and padding that should stay crisp.
- **Lock shapes with `UIAspectRatioConstraint`.** `FitWithinMaxSize` only shrinks, so a zero-height row stays zero. Use `ScaleWithParentSize` with the right `DominantAxis` for such rows and for `UIGridLayout` cells (roblox-lessons ui.md).
- **Derive window size from the screen** (for example 90% of height, clamped by a maximum offset), so a desktop-sized panel never overflows a phone.
- **Keep two `UIScale`s apart**: one for fit-to-screen and one for pop-in tweens, never the same instance.
- **Size scrolling canvases from the layout's `AbsoluteContentSize`.** `AutomaticCanvasSize` undercounts aspect-sized rows.
- **Test matrix:** a phone in landscape (about 749×367 usable, plus the top bar), a phone in portrait if you support it, a tablet, 1080p and 1440p, and a TV-distance console view. Studio's Device emulator approximates these, but MCP clicks don't reach the game while it is on, so a human taps to test.

## 2. Safe areas

Inset only **critical** UI: currency, timers, prompts and close buttons. Decorative art can bleed to the edges.

- **Top bar:** `GuiService:GetGuiInset()`. It can read 0 right after join, so re-apply on change. Simplest: set every ScreenGui to `IgnoreGuiInset = true` and keep content below the inset yourself.
- **Notches and rounded corners:** `ScreenGui.ScreenInsets` (device-safe vs core-UI-safe insets).
- **Touch controls:** when `PlayerGui.TouchGui` is visible, keep the HUD above `ThumbstickStart` and left of `JumpButton`, reading their `AbsolutePosition` at runtime.
- **Console overscan:** keep a margin of a few percent around critical UI on a TV.

Generic math, for any reported safe rectangle: `anchorMin = safe.min / screen` and `anchorMax = safe.max / screen`. Recompute on resolution or orientation change, not once at startup.

## 3. Focus navigation (gamepad and console)

1. **Initial focus** whenever a window opens: `GuiService.SelectedObject = defaultButton`.
2. **Explicit neighbours** for predictable movement: `NextSelectionUp/Down/Left/Right`. Leave them unset for simple lists where automatic selection works.
3. **Visible focus style**, distinct from hover: `SelectionImageObject`. Never signal focus by colour alone.
4. **Trap focus inside modals** so the stick can't wander to the HUD behind them, and restore the previous focus on close.
5. **Coexist with mouse and touch:** switching device must not strand the player. Watch `UserInputService.LastInputTypeChanged`.

## 4. Panel / screen stack

```lua
local stack = {}

local function push(panel)
	local top = stack[#stack]
	if top then top.setInteractive(false) end
	table.insert(stack, panel)
	panel.show()
	GuiService.SelectedObject = panel.defaultFocus
end

local function pop()
	local panel = table.remove(stack)
	if panel then panel.hide() end
	local top = stack[#stack]
	if top then
		top.setInteractive(true)
		GuiService.SelectedObject = top.defaultFocus
	end
end
```

For a simulator HUD, a simpler rule usually wins: **one modal window at a time**. Opening a window closes the others, Escape/B closes it, and a `panelsChanged` signal hides HUD tiles the window covers. Gate `open` behind a tutorial lock if the tutorial must stay focused. Confirm dialogs and refusal toasts push above the window that triggered them.

## 5. Diegetic, world-space and screen-space UI

- **Screen-space (non-diegetic):** ScreenGuis. The cheapest and clearest; most HUDs belong here.
- **World-space:** `BillboardGui` (set `MaxDistance` so far signs don't clutter the view, and use `AlwaysOnTop` sparingly) for labels over dens, plates and NPCs; `SurfaceGui` for boards and signs that belong to the world.
- **Interaction:** a `ProximityPrompt` is Roblox's built-in diegetic interaction UI. It handles keyboard, gamepad and touch for you, so prefer it over a custom "press E" label.
- Clamp off-screen markers to the screen edge, and scale world labels with distance.

## 6. Accessibility (bake it in)

- Text never smaller than readable on a phone: `TextScaled` with a `UITextSizeConstraint` (MinTextSize and MaxTextSize).
- Don't encode state in colour alone; add an icon, a shape or text, and use colour-blind-safe palettes.
- Touch targets of at least about 9 mm, with padding around small buttons.
- Reduce-motion and reduce-flashing options (coordinate with `game-feel`).
- Every action reachable by keyboard, gamepad and touch.

## 7. Localization-ready layout

- Keep display strings out of layout logic. Roblox auto-translation and `LocalizationTable`s work best when text is set as plain strings on labels with `AutoLocalize` on.
- Let containers size to content (`AutomaticSize`, layouts), so a German string about 30% longer doesn't clip. Avoid fixed-width buttons sized to English.
- Format numbers through one helper (for example, short money formats like "25.3M"), so units stay consistent.
- Keep icons separate from text, so only strings need translating.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `../SOURCE.md`.
