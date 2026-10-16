# UI lessons

## Text
- **`TextWrapped = false` switches `TextScaled` off.** Order matters: set `TextWrapped` first, `TextScaled` last. Symptom: labels stuck at a tiny fixed `TextSize` (e.g. 8 px) inside a big box. Check `TextBounds` vs `AbsoluteSize`.
- Pair `TextScaled` with a `UITextSizeConstraint` (MaxTextSize) so text doesn't balloon on big screens.
- Cartoon fonts (e.g. LuckiestGuy, FredokaOne) stream in after join. Hide the loading screen only after `ContentProvider:PreloadAsync` on labels using them, or every label flashes in the default font.
- Glyphs like ✓ may be missing from cartoon fonts; use a font that has them (GothamBold) for those labels.

## Positions and insets
- `GuiObject.AbsolutePosition` is measured from **below the top bar** (`GuiService:GetGuiInset().Y`, ~58 px on phones, ~36 on desktop) **for every ScreenGui** — measured on an iPhone 14 emulator: an `IgnoreGuiInset = true` ScreenGui reports its canvas at `AbsolutePosition.Y = -58`, a normal one at `0`. So screen Y = `AbsolutePosition.Y + inset`, always. Offsets you set inside an `IgnoreGuiInset` gui are screen pixels; offsets inside a normal gui start below the bar. Converting one into the other without the inset misplaces things by ~58 px (cards overlapping the coin counter). Simplest: make every ScreenGui `IgnoreGuiInset = true`, convert AbsolutePosition with `+ inset`, and keep content below the top bar yourself.
- `GetGuiInset()` can read 0 right after join; re-apply layout periodically or on change.

## Sizing
- Prefer scale sizes + `UIAspectRatioConstraint`. But **`AspectType.FitWithinMaxSize` only shrinks**: a row sized `(1, 0, 0, 0)` stays 0 tall. Use `ScaleWithParentSize` (dominant axis Width) when the other axis is zero, and on `UIGridLayout` cells.
- **`AutomaticCanvasSize` undercounts aspect-sized children** → the last rows of a ScrollingFrame are unreachable. Set `CanvasSize` from `layout.AbsoluteContentSize` on its change signal (+ a little padding).
- A `UIScale` used for a pop-in tween fights a `UIScale` used for fit-to-screen. Keep them separate (named) or make the pop end at the fitted scale.
- Desktop-sized offset panels (e.g. 820×480) overflow an iPhone 14 landscape (~749×367 usable). Size windows from the screen with a max-size cap.

## Phones (touch)
- Roblox's thumbstick sits bottom-left and the jump button bottom-right — exactly where HUD menus and travel rows usually go. With a visible `PlayerGui.TouchGui`: keep HUD above `ThumbstickStart` and left of `JumpButton` (read their AbsolutePosition at runtime).
- Roblox's chat button sits top-left under the top bar.
- MCP mouse clicks don't reach the game while Studio's device emulator is on — ask the maintainer to tap-test; screenshots also don't render the 3D world/ViewportFrames in emulation.

## Layering (DisplayOrder) that worked
HUD 2–4 · modal windows 5 · notices/dialogue 6 · celebration reveals 7 · tutorial 9 · screen effects 20 · loading 100. Toasts that explain a refusal ("not available in your region") must draw above the window that triggered them.

## Live-updating UI
- Rebuilding a list on every server push restarts every progress-bar tween from empty (visible flicker once per second). Build rows once, update them in place.
- Buttons that wait on the server should show a pending label ("REBIRTHING...") — showing the "not eligible" text while waiting reads as a bug.
- `Active = false` doesn't stop `Activated`; also set `Interactable = false`, and still check eligibility in the handler.
- Free-strip placement: banners/toasts should fit the gap between side menus and side cards rather than a fixed % width.
