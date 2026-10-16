---
name: game-ui-ux
description: Engine-agnostic game UI/UX design guidance, adapted for Roblox ScreenGuis. Covers responsive scale-based layout, safe areas, gamepad focus navigation, a panel/screen stack, event-driven HUD updates, accessibility and localization. Use when building or fixing a Roblox HUD, menu, shop, modal window or overlay; when UI breaks on phones, tablets or consoles, collides with the top bar, thumbstick or jump button, or can't be used with a gamepad; when a HUD polls state every frame; or when structuring panel flow so only one window is open at a time.
---

# Game UI/UX

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins. Read roblox-lessons `references/ui.md` before building UI. It holds the TextScaled, inset, canvas-size and aspect-constraint traps.

Build HUDs and menus that stay correct on a phone in landscape, a desktop monitor and a TV with a gamepad.

## On Roblox

- **Layout:** use Scale sizes with `AnchorPoint`, `UIAspectRatioConstraint`, and `UIListLayout`/`UIGridLayout`/`UIPadding`. Never use offset-only pixel layouts. Size windows from the screen with a maximum cap.
- **Layering:** give each layer its own ScreenGui with a fixed `DisplayOrder` (ladder: HUD 2–4, windows 5, notices 6, reveals 7, tutorial 9, effects 20, loading 100). Set `ResetOnSpawn = false` on persistent UI.
- **Panel stack:** use a `UIManager`-style client module. Panels register by name, opening one closes the others, Escape or gamepad B closes the top one, and a changed signal lets HUD tiles hide under an open window.
- **Safe areas:**
  - The top bar: `GuiService:GetGuiInset()` and `IgnoreGuiInset`.
  - Notches: `ScreenGui.ScreenInsets`.
  - On phones, the thumbstick (bottom-left), the jump button (bottom-right) and the chat button (top-left). Read `TouchGui` positions at runtime.
- **Gamepad and console:** set the initial focus with `GuiService.SelectedObject`, set explicit neighbours with `NextSelectionUp/Down/Left/Right`, and mark controls `Selectable`. Style focus with `SelectionImageObject`. Track the input device with `UserInputService.LastInputTypeChanged`.
- **Event-driven:** update on RemoteEvent pushes or `GetAttributeChangedSignal`, never by polling in `RenderStepped`. Build list rows once and update them in place.
- **Localization:** use `LocalizationTable` and `AutoLocalize`, and let text containers grow with `AutomaticSize`.

## Workflow

1. Lay out with anchors, scale and layouts, never absolute pixel positions.
2. Pick one scaling policy for the whole UI (size from screen height with caps), and decide where extra width goes.
3. Inset critical UI from the top bar, notches and touch controls. Decorative art can bleed to the edges.
4. Make every screen reachable by gamepad: give it an initial focus, neighbours and a visible focus style.
5. Model screens as a stack (push an overlay, pop on back) instead of boolean flags.
6. Drive the HUD from events.
7. Verify at real sizes: a phone in landscape (about 749×367 usable), a tablet, 1080p, and gamepad-only. Report what you observed at each size.

## Pitfalls

- Offset sizes designed on one monitor overflow phones.
- `TextScaled` turned off by setting `TextWrapped` afterwards (roblox-lessons ui.md).
- HUD under the top bar, a notch or the thumbstick.
- Nothing focused when a window opens, so the gamepad does nothing.
- Polling player state every frame instead of reacting to pushes.
- Rebuilding lists on every push, which restarts every progress bar.
- Tiny fixed text; text with no size cap that balloons on big screens.
- Menu flow as flags (`isShopOpen`, `inSettings`, ...). Use a stack.
- English baked into fixed-width buttons, so translations overflow.
- A refusal toast drawn under the window that triggered it.

## References

- `references/layout-and-flow.md`: scaling, safe-area math, focus navigation, a panel-stack sketch, world-space UI (BillboardGui, SurfaceGui, ProximityPrompt), accessibility, and localization-ready layout.

Related: `game-feel` (pops and transitions on top of this layout), `roblox-lessons`.

---
Adapted from awesome-gamedev-agent-skills (Apache-2.0). Modified; see `SOURCE.md`.
