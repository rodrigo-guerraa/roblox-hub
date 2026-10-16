# liveops/playtime-gifts — free gift every N minutes online

## 1. What it does

**Player-facing:** the "Gift" HUD tile counts down (`9:41`). When the gift is ready it reads **CLAIM!**, wiggles, shows a gold "!" badge, and a "Your free gift is ready!" toast plays. The FREE GIFT window shows the gift number, the real payout ("+$1.2M"), a timer bar, the next gift's size ("Gifts grow the longer you play!") and a CLAIM button. Claiming flies coins to the counter.

**Technical:**
- The server adds one second per online second to the saved `giftProgress` until it reaches `INTERVAL` (600 s), then stops. A ready gift waits until it is claimed, so gifts never stack, and progress survives rejoining.
- Each gift claimed in a session is bigger: gift N pays `SECONDS_LADDER[N]` seconds of income (the last step repeats), never below `MIN`. The ladder restarts on rejoin.
- `GiftMath` (pure, with spec) holds `Payout(income, giftNumber, config?)`, `Progress(saved, config?)` and `IsReady(saved, config?)`. The client uses the same function for its preview, reading the `IncomePerSecond` attribute.
- The claim is validated on the server (data loaded, progress at the interval). The reward goes through `EconomyAPI.Grant(player, reward, "playtime_gift")`.

## 2. Depends on

- `systems/core`: remotes, data, economy (`GetIncome`, `Grant`, the `IncomePerSecond` attribute), format.
- `systems/ui/kit`: `UIStyle`, `Effects`, `SoundFX`, `Notice`; `UIManager`, `Icons` (`Icons.Gift`).

## 3. Install

| File | Destination |
| --- | --- |
| `server/PlaytimeGiftService.server.lua` | `src/server/` |
| `client/GiftUI.client.lua` | `src/client/` |
| `shared/PlaytimeGiftsConfig.lua` | `src/shared/` |
| `shared/GiftMath.lua` | `src/shared/` |
| `tests/GiftMath.spec.lua` | `tests/` |

**DataTemplate:** add `giftProgress = 0`.

**Config (`PlaytimeGiftsConfig.lua`):**

| Key | Default | Meaning |
| --- | --- | --- |
| `INTERVAL` | `600` | Online seconds per gift |
| `SECONDS_LADDER` | `{ 60, 90, 120, 150, 180 }` | Gift N of a session pays this many seconds of income. In Dino this was about +20% income over an hour. |
| `MIN` | `1000` | Floor for brand-new players |
| `WINDOW_KEY` | `"Gift"` | `UIManager` name |
| `HUD_ORDER` | `0` | Tile order (first in the menu) |
| `REMOTE_*` | `ClaimGift` / `UpdateGift` / `RequestGift` | Remote names |

No ids to create.

## 4. Remotes

| Remote | Direction | Payload |
| --- | --- | --- |
| `ClaimGift` | client → server | none. Ignored unless the data is loaded and the gift is ready. |
| `UpdateGift` | server → client | `{ progress, interval, ready, giftNumber, claimed? }`. Sent on join, when the gift becomes ready, after a claim (`claimed` = amount paid), and on `RequestGift`. |
| `RequestGift` | client → server | none. Re-sends `UpdateGift`; never changes data. `GiftUI` fires it on startup. |

To have the loading screen wait for it, add `{ event = "UpdateGift", request = "RequestGift" }` to `UIConfig.LoadingScreen.waitEvents` (optional).

## 5. Verify in Studio (MCP)

1. `start_stop_play`, then `get_console_output`: no errors.
2. **Join sync:** `execute_luau` (Client): `PlayerGui.HudDock` contains `GiftSlot`, and its label shows a `m:ss` countdown that drops between two reads a few seconds apart.
3. **Make it ready fast:** set `INTERVAL = 10` in the config and Play. Capture `UpdateGift` on the Client into a `LocalPlayer` attribute (JSON). After ~10 s the payload has `ready = true`, and the tile label reads `CLAIM!`.
4. **Early claim rejected:** right after a claim, fire `ClaimGift` again. No `UpdateGift` with `claimed` arrives, and `Currency` (Server) is unchanged.
5. **Claim:** when ready, fire `ClaimGift`. The payload has `claimed = GiftMath.Payout(IncomePerSecond, 1)` (≥ `MIN`) and `giftNumber = 2`, and `Currency` rose by that amount. Set `IncomePerSecond` to `1000` on the Server first to see the income scaling (60 000 for gift 1, 90 000 for gift 2).
6. **Timer stops at ready:** let it become ready and wait 20 s. On the Server, `shared` reads are sandboxed, so check through the remote instead: fire `RequestGift` and confirm `progress == interval`.
7. **Persistence:** with API access on, leave at about 5 s of progress and rejoin. The first `UpdateGift` shows `progress >= 5` and `giftNumber = 1`.
8. Set `INTERVAL` back to 600. Run the specs (`RunTests` attribute): `GiftMath.spec` passes.

## 6. Origin

Dino Simulator `src/server/GiftService.server.lua`, `src/client/GiftUI.client.lua`, `EconomyMath.GiftPayout` (`src/shared/EconomyMath.lua`) and its `GiftPayout` cases in `tests/EconomyMath.spec.lua`.
- `GiftPayout` became `GiftMath.Payout`, with an optional config argument and clamping for bad gift numbers. `Progress`/`IsReady` were pulled out of the service so they could be tested.
- Income comes from `EconomyAPI.GetIncome` (server) and the `IncomePerSecond` attribute (client) instead of `PlateServiceAPI.GetActiveCPS` and `ActiveCPS`.
- Payment goes through `EconomyAPI.Grant`; no `UpdateCoins` fire.
- `Config.GIFT_*` became `PlaytimeGiftsConfig`, and the remotes come from `Remotes.event`.
