# UI kit

The shared client UI layer every hub system builds on: a bright cartoon style kit (`UIStyle`), panel coordination (`UIManager`), toasts (`Notice`), screen/world feedback (`Effects`), sound (`SoundFX`, `Music`), a loading screen and a top-centre currency counter.

## 1. What it does

**Player-facing**
- A loading screen (game title, bouncing icon, progress bar) that stays up until the game's initial data has arrived and the cartoon fonts have loaded (10 s safety timeout).
- A currency counter at the top centre: icon, balance that counts up on gains and flashes red on spends, and a green income pill ("$37.5/s").
- Glossy chunky buttons that bounce and click, modal windows with a title ribbon and round X (Escape closes), a HUD dock (2-wide menu grid mid-left, round travel row bottom-right) that avoids the phone thumbstick and jump button, pill toasts, flying coins, confetti, banners, floating text.
- Background music playlist with a Music HUD tile to mute it.

**Technical**
- Every ScreenGui is created by `UIStyle.screen` with `IgnoreGuiInset = true` and a `DisplayOrder` from the layering table below.
- Sizes are scale + `UIAspectRatioConstraint`; text is `TextScaled` with a `UITextSizeConstraint` cap; outline widths follow the screen height.
- The kit's fixes for known traps are built in (see `skills/roblox-lessons/references/ui.md`): `TextScaled` set after `TextWrapped`, `ScaleWithParentSize` for zero-height rows and grid cells, `CanvasSize` from `AbsoluteContentSize`, `screenTop/screenBottom` for AbsolutePosition vs the top-bar inset, separate named `UIScale`s (`PressScale`, `PopScale`, `FitScale`, `BumpScale`), windows sized from the screen with a max-size cap, font preload before the loading screen hides.

Layering (`DisplayOrder`): HUD 2–4 (CurrencyDisplay 2, HudDock 3) · windows 5 · notices/dialogue 6 · reveals 7 · tutorial 9 · effects 20 · loading 100.

## 2. Depends on

- `systems/core`: `NumberFormat` (`ReplicatedStorage.NumberFormat`, used by `CurrencyDisplay`), `Remotes` (`ReplicatedStorage.Remotes`, only when `UIConfig.LoadingScreen.waitEvents` is non-empty), and the economy's `Currency` / `IncomePerSecond` Player attributes (read by `CurrencyDisplay` and, by default, the loading screen).

## 3. Install

| File | Copy to | Roblox type |
| --- | --- | --- |
| `client/UIStyle.lua` | `src/client/` | ModuleScript — the style kit |
| `client/Notice.lua` | `src/client/` | ModuleScript — `Notice.Show(text)` pill toast |
| `client/Effects.lua` | `src/client/` | ModuleScript — flying coins, float text, confetti, banners, world bursts |
| `client/SoundFX.lua` | `src/client/` | ModuleScript — named one-shot sounds in `SoundService.SFX` |
| `client/Music.client.lua` | `src/client/` | LocalScript — playlist/ambience in `SoundService.Music` + Music mute tile |
| `client/LoadingScreen.client.lua` | `src/client/` | LocalScript — loading overlay |
| `client/CurrencyDisplay.client.lua` | `src/client/` | LocalScript — top-centre currency counter |
| `shared/UIManager.lua` | `src/shared/` | ModuleScript — panel registry, mutual exclusion, tutorial lock |
| `shared/UIConfig.lua` | `src/shared/` | ModuleScript — settings |
| `shared/Icons.lua` | `src/shared/` | ModuleScript — icon asset ids |
| `tests/UIManager.spec.lua` | `tests/` | TestEZ spec |

Then edit `src/shared/UIConfig.lua`:

| Setting | Default | Meaning |
| --- | --- | --- |
| `Title` | `"MY GAME"` | Loading-screen title |
| `Currency.icon` / `prefix` / `rateSuffix` | `Icons.Coin`, `"$"`, `"/s"` | Counter icon (also the flying-coin image) and text format |
| `Currency.showIncome` | `true` | Show the income pill (only while the income attribute exists) |
| `Currency.attribute` / `incomeAttribute` | `"Currency"`, `"IncomePerSecond"` | Player attributes the counter reads |
| `LoadingScreen.enabled` | `true` | |
| `LoadingScreen.waitEvents` | `{}` | RemoteEvents the screen waits for: `"UpdateX"` or `{ event = "UpdateX", request = "RequestX" }` (the request is fired once after connecting, because a queued payload only reaches the first listener) |
| `LoadingScreen.waitAttributes` | `{ "Currency" }` | Player attributes that must be set |
| `LoadingScreen.timeout` | `10` | Seconds before it hides anyway and `warn`s the missing names |
| `LoadingScreen.icon`, `topColor`, `bottomColor`, `barColor` | star, greens, orange | Look |
| `Music.enabled` / `muteButton` / `buttonOrder` | `true`, `true`, `9` | |
| `Music.tracks` | 3 APM library tracks | `{ id, volume }` list, shuffled |
| `Music.ambience` | `nil` | A looped `{ id, volume }` bed. The reference game used jungle ambience `rbxassetid://9112805601` (volume 0.3) |
| `Sounds` | `{}` | Extra or replacement `SoundFX` entries, `name = { id, volume?, pitch? }` |

No DataTemplate fields, no ids to create.

**Icons.** `Icons.lua` holds image ids from a cartoon icon pack uploaded to the original author's account; replace them with your own pack's ids: `Book, Quests, Trophy, Store, Crown, CashBag, Rebirth, House, Egg, Coin, Gem, Gift, Lock, Settings, SoundOn, SoundOff, CoinStack, Star, Codes, Friends, Click`. Add new ids here, never inline in UIs.

**Sounds.** Every `SoundFX` id is Roblox-licensed library audio (APM Music, Pro Sound Effects) or an engine-bundled `rbxasset://sounds` file, so it plays in any game. Names: `click` (every kit button), `coin` (every `FlyCoins`), `pop`, `crack`, `reveal`, `levelup`, `fanfare`, `victory`, `deny`, `talk`, `dialogOpen`, `dialogClose`. `SoundFX.play(name, { gap, jitter, pitch, volume })`; an unknown name is a no-op.

## 4. Remotes it creates

None. `LoadingScreen` only listens to (and optionally fires) the remotes named in `UIConfig.LoadingScreen.waitEvents`, through core's `Remotes.event`.

## 5. API cheat sheet

All builders take `(parent, props)` and return the instance. **Common props** (every builder): `name`, `anchor` (Vector2), `position` (UDim2), `size` (UDim2, default full), `order` (LayoutOrder), `z` (ZIndex), `visible` (false hides), `aspect` (number → adds `UIStyle.aspect`).

**Theme tables**
- `UIStyle.Colors`: `green blue purple gold orange red teal pink amber brown grey`
- `UIStyle.Theme`: `outline panel panelEnd card cardLine well ink inkSoft white dim`
- `UIStyle.Fonts`: `title` (LuckiestGuy), `body` (FredokaOne). Glyphs like ✓ are missing from these; use `Enum.Font.GothamBold` for them.

**Helpers**
- `isPhone()` → `ViewportSize.Y < 520`
- `stroke(parent, width?=3, color?=Theme.outline, mode?=Border)` → UIStroke whose thickness follows screen height (authored for 720p)
- `corner(parent, scale?=0.2)` → UICorner (reuses an existing one)
- `gloss(parent)` → vertical white→grey UIGradient (multiplies `BackgroundColor3`, so recolouring keeps the shine)
- `aspect(parent, ratio, dominant?=Width)` → UIAspectRatioConstraint; picks `ScaleWithParentSize` for a UIGridLayout or a zero-size other axis, else `FitWithinMaxSize`
- `padding(parent, x?=0.04, y?=x)` → scale UIPadding

**Builders**
- `text(parent, props)` → TextLabel. `text`, `font`(=body), `color`(=ink), `wrap`(default true; false for one-liners), `rich`, `alignX`, `alignY`, `max` (MaxTextSize, 48), `outline` (true or width), `outlineColor`
- `image(parent, props)` → ImageLabel. `image`, `square` (default true → 1:1 aspect unless `aspect` given)
- `button(parent, props)` → glossy TextButton; text lives in child `Label`. `text`, `icon` (image id, left side), `color`(=green), `textColor`, `font`, `max`(40), `round` (pill), `outlineWidth`(3). Bounces and plays `click`.
- `setText(button, text)`; `setEnabled(button, enabled, color?)` (greys out, sets `Active` and `Interactable`; `color` replaces the base colour); `isEnabled(button)`
- `panel(parent, props)` → Frame. `color`(=Theme.panel), `transparency`, `corner`(0.12), `outlineWidth`(3; 0 = none), `outlineColor`, `gloss`
- `card(parent, props)` → white `panel` with `cardLine` outline, width 2, corner 0.14
- `scroll(parent, props)` → `ScrollingFrame, layout`. `gap`(8), `columns` (grid; else list), `cellAspect`(1). List rows: `Size = UDim2.new(1, 0, 0, 0)` + `UIStyle.aspect(row, ratio)`. CanvasSize follows the layout.
- `bar(parent, props)` → `frame, set(fraction, text?)`. `color`, `outlineWidth`(2), `text = false` for no label; plus common positional props
- `screen(name, order?=5, ignoreInset?=true)` → ScreenGui in PlayerGui, `ResetOnSpawn = false`
- `pop(object, from?=0.85)` → pop-in tween on the object's `PopScale`
- `window(props)` → `win` modal. Props: `name` (ScreenGui), `key` (UIManager name), `title`, `icon`, `color` (ribbon, orange), `aspect`(1.55), `order`(5), `onOpen`, `onClose`. Returns `{ gui, overlay, frame, ribbon, title, icon, body, close, open(), hide(), toggle(), setTitle(text) }`; fill `win.body`. Open it with `UIManager.open(key)` / `win.open()` (respects the tutorial lock).
- `styleButton(button, variant?)` → restyles an existing TextButton (`"close"` = red X). Legacy.
- `fitToScreen(object, { margin?=8, belowTopBar? })` → `UIScale, refresh`; shrinks (never grows) an offset-sized object to fit its ScreenGui. `fitScale(object)` → the current fit (end pop tweens there).

**Screen space**
- `screenTop(object)` / `screenBottom(object)` → screen-pixel Y of an object (AbsolutePosition + top-bar inset). Use these, not raw `AbsolutePosition`, when placing one layer from another.
- `topLane(gap?=8, extraCards?)` → `left, right` screen X of the free strip across the top between the menu dock and any visible side card. Use for banners/toasts.
- `registerSideCard(guiObject)` → a card at the left/right edge (e.g. a held-item card) that narrows `topLane` while visible.
- `registerTopCard(guiObject)` → a top-centre element; `topLaneY(gap?=8, skip?)` → screen Y just below every visible registered top card (the currency counter's `Footprint` is registered; a banner registers itself and passes itself as `skip` when placing).

**HUD dock**
- `hudButton({ label, icon, color?, order?, dock? })` → `button, slot`. `icon` is an `rbxassetid://` image (or a text glyph). `dock = "travel"` puts a round tile in the bottom-right row, else the 2-wide menu grid. Tiles covered by an open UIManager panel hide themselves.
- `UIStyle.LeftDock`, `UIStyle.TravelDock` → the dock frames (in `PlayerGui.HudDock`).

**UIManager** (`ReplicatedStorage.UIManager`): `register(name, frame)` (opening one closes the others), `open/close/toggle(name)`, `getOpenPanels()`, `panelsChanged`, `setTutorialLock(locked, allowList?)`, `canOpen(name)`, `registerTutorialTarget(key, instance)`, `getTutorialTarget(key)`, `tutorialTargetRegistered`.

**Notice**: `Notice.Show(text)` — pill toast at 72% height, `DisplayOrder` 6 (above windows).

**Effects** (all local-only; fire them only on server-confirmed changes)
- Screen: `FlyCoins(fromScreen: Vector2, count?=8, text?)` — coins arc into the currency target and bump it; with no target they pop at the source. `text` (e.g. "+$1.2K") floats up too. `FloatText(text, screenPos, color?, size?=30)`, `ScreenFlash(color?, strength?=0.5, seconds?=0.35)`, `Confetti(count?=40)`, `Banner(text, color?)`, `BumpCounter()`
- `setCurrencyTarget(guiObject)` / `getCurrencyTarget()` — `CurrencyDisplay` registers its panel.
- World: `Burst(position, color?, amount?=24)`, `Ring(position, color?, radius?=5)`
- Helpers: `WorldToScreen(position)` → `Vector2, onScreen`; `CenterOf(guiObject)` → screen-pixel centre (inset-corrected); `Effects.Colors`

## 6. How to verify in Studio via the MCP

1. **Play** (`start_stop_play`), then `get_console_output`: no errors; no `LoadingScreen: timeout` warning (if there is one, it names the missing event/attribute).
2. **Loading screen**: in the `Client` datamodel, `PlayerGui.LoadingScreen` exists right after join and is gone within a few seconds once `Currency` is set.
3. **Currency counter**: on the `Server`, `player:SetAttribute("Currency", 1234)` (or `EconomyAPI.Grant`) and `IncomePerSecond`; on the `Client`, `PlayerGui.CurrencyDisplay.Panel.Amount.Text` reads `$1.2K` after ~0.7 s and `Panel.Rate.Income.Text` the rate. Lower the balance: the text turns red then fades back. With `IncomePerSecond` unset the pill is hidden.
4. **Effects**: in the `Client`, `require(PlayerScripts.Effects).FlyCoins(Vector2.new(400, 400), 8, "+$50")` → coins fly to the counter; `screen_capture` mid-flight.
5. **Windows / HUD**: build a test `UIStyle.window({ key = "Test", title = "TEST" })`, `UIManager.open("Test")`, screenshot; HUD tiles under it hide (`Visible = false`). Escape or the X closes it.
6. **Layout on two screens** — `screen_capture` on desktop, then with Studio's device emulator on **iPhone 14 landscape**. For each window/HUD element, read `AbsolutePosition`/`AbsoluteSize` and confirm it lies inside `workspace.CurrentCamera.ViewportSize` (convert with `screenTop/screenBottom`), that labels' `TextBounds` aren't tiny inside big boxes, and that the menu sits above `TouchGui…ThumbstickStart` and the travel row left of `JumpButton`.
7. **Known MCP limits**: mouse clicks don't reach the game while the device emulator is on (tap-test by hand, or fire the `Activated` handler logic from `execute_luau`); emulator screenshots don't render the 3D world or ViewportFrames; `execute_luau` connections die when the call returns (store captured values as attributes); moving the camera cancels ProximityPrompt holds.
8. **Spec**: run `tests/UIManager.spec.lua` with the template's TestRunner.

## 7. Origin

Extracted from the reference game's `src` (a shipped Roblox simulator):

| Kit file | Source | Changes |
| --- | --- | --- |
| `UIStyle.lua` | `client/UIStyle.lua` | `topLane` no longer looks up `EggCarryGui.EggCard`; it takes `(gap, extraCards?)` and narrows around cards registered with the new `registerSideCard`. New `registerTopCard` + `topLaneY` replace hard-coded `CoinDisplay.Footprint` / `ServerEventBanner.Banner` lookups. Everything else identical. |
| `UIManager.lua`, `Notice.lua`, `Icons.lua` | `shared/UIManager.lua`, `client/Notice.lua`, `shared/Icons.lua` | Unchanged. |
| `Effects.lua` | `client/Effects.lua` | Coin target is `setCurrencyTarget(guiObject)` instead of `PlayerGui.CoinDisplay.Panel`; with no target, coins pop at the source. `FlyCoins` gained an optional `text`. Bump uses a named `BumpScale`. The coin image comes from `UIConfig.Currency.icon`. The target centre goes through `CenterOf` (inset-correct for either kind of ScreenGui). |
| `SoundFX.lua` | `client/SoundFX.lua` | Dropped `dig`, `dig2`, `roar`; `rebirth` renamed `fanfare`. Music and ambience moved to `UIConfig.Music`; `UIConfig.Sounds` merges extra entries. |
| `Music.client.lua` | `client/Music.client.lua` | Reads `UIConfig.Music` (enable, mute tile, order, tracks, optional ambience). |
| `LoadingScreen.client.lua` | `client/LoadingScreen.client.lua` | Wait list (events with optional re-pull request, and Player attributes), title, icon, colours and timeout come from `UIConfig`; remotes resolved through core `Remotes`. |
| `CurrencyDisplay.client.lua` | `client/CoinDisplay.client.lua` | Reads the `Currency` / `IncomePerSecond` Player attributes instead of the reference game's remotes and client-side CPS math; ScreenGui renamed `CurrencyDisplay`; registers its `Footprint` as a top card and its `Panel` as the Effects target; the income pill hides when there is no income attribute. |
