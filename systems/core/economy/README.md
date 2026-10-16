# core/economy — default currency API

## 1. What it does

**Player-facing:** one soft currency that every system pays into and charges from. Its balance is always visible to client UIs.

**Technical:** `EconomyService.server.lua` publishes the default `shared.EconomyAPI` over `data.currency`, the saved field from core/data.

| Function | Returns | Behaviour |
| --- | --- | --- |
| `Grant(player, amount, source)` | new balance | Adds currency and bumps `data.totalEarned`. Only finite, positive amounts change anything; `0`, negatives, NaN and non-numbers return the unchanged balance. Returns `0` (and `warn`s) while the player's data isn't loaded. |
| `Spend(player, amount, source)` | `true` if taken | `false` when the player can't afford it, the amount is invalid (negative, NaN, infinite or not a number), or the data isn't loaded. `Spend(player, 0)` returns `true`. |
| `GetBalance(player)` | number | `0` for non-players or data that isn't loaded. A corrupt balance (not a number, NaN or negative) is repaired to `0`. |
| `GetIncome(player)` | currency per second | The player's `IncomePerSecond` attribute, or `0` when unset or invalid. |

- `source` is a free-form string (`"Gift"`, `"Shop:Sword"`, ...). The default ignores it; it exists so a replacement API can log or analyse sinks and sources.
- **Player attributes**, which client UIs read (never a game-specific remote):
  - `Currency`: set on load and after every `Grant`/`Spend`. A 0.5 s loop also re-syncs it, so a direct write to `data.currency` shows up too. Still prefer the API.
  - `IncomePerSecond`: set to `0` on load if unset. **The game owns this value.** Set it from your own income logic with `player:SetAttribute("IncomePerSecond", n)` whenever income changes, for example every tick of an idle-income loop. Income-scaled rewards (gifts, codes, care packages) read it through `GetIncome`. A game with no idle income can leave it at `0`.
- `data.totalEarned` is a lifetime counter of everything granted. Spending never reduces it, and it is never reset. A run-scoped counter such as a rebirth goal belongs to the system that resets it.
- In Studio only, `STUDIO_START_BALANCE` (default `0` = off) tops the balance up on join. It doesn't count as earned.

### Replacing it

A game with its own currency logic deletes `EconomyService.server.lua` and publishes its own `shared.EconomyAPI` with the same four functions and the same attribute mirroring, before any yield. Keep only one publisher.

## 2. Depends on

core/data (`shared.DataServiceAPI`).

## 3. Install

| File | Destination |
| --- | --- |
| `server/EconomyService.server.lua` | `src/server/EconomyService.server.lua` |
| `shared/EconomyConfig.lua` | `src/shared/EconomyConfig.lua` |

- **DataTemplate fields:** `currency = 0` (or your starting balance) and `totalEarned = 0`. Both are already in core/data's shipped template.
- **Config (`EconomyConfig.lua`):**

  | Key | Default | What it sets |
  | --- | --- | --- |
  | `CURRENCY_ATTRIBUTE` | `"Currency"` | The balance attribute's name. Other hub systems read `"Currency"`, so keep it. |
  | `INCOME_ATTRIBUTE` | `"IncomePerSecond"` | The income attribute's name. Other hub systems read `"IncomePerSecond"`, so keep it. |
  | `STUDIO_START_BALANCE` | `0` | Studio top-up on join (`0` = off). |
  | `ATTRIBUTE_SYNC_INTERVAL` | `0.5` | Seconds between attribute re-syncs. |

## 4. Remotes

None. Clients read the `Currency` and `IncomePerSecond` attributes.

## 5. Verify in Studio (MCP)

1. **Clean start.** `start_stop_play` to start, then `get_console_output`. Expect no errors.
2. **Attributes on load.** `execute_luau` (Server): `local p = game.Players:GetPlayers()[1]; return p:GetAttribute("Currency"), p:GetAttribute("IncomePerSecond")`. Expect a number and `0`.
3. **Studio top-up.** Set `STUDIO_START_BALANCE = 1000` and Play. Expect `Currency` to be `1000` (or more, if the save already had more). Set it back to `0` afterwards.
4. **Grant / Spend.** The MCP's `shared` is sandboxed, so drive the API from a temporary `src/server/TempVerify.server.lua`. It should:
   - wait for `shared.EconomyAPI` and a loaded player;
   - call `Grant(p, 100, "test")`, `Spend(p, 40, "test")`, `Spend(p, 1e12, "test")`, `Grant(p, -5)`, `Grant(p, 0/0)` and `Spend(p, -1)`;
   - write each result to attributes on the player.

   Then read the attributes back with `execute_luau`. Expect:
   - the balance rises by 100, then falls by 40;
   - `Spend(p, 1e12)` is `false`;
   - the invalid calls change nothing (`Spend(p, -1)` is `false`);
   - `Currency` matches each step.

   Delete the temp script afterwards.
5. **Direct-write sync.** In the temp script, set `data.currency` directly through `shared.DataServiceAPI.GetData(p)`. Expect the `Currency` attribute to follow within about 0.5 s.
6. **Persistence.** With API access on, Stop and Play again. Expect `Currency` to keep the value.

## 6. Origin

Extracted from the reference game, generalised:
- `DataService.AddCoins`/`SetCoins` (coins clamped at 0, positive gains counted into `runEarned`) became `Grant`/`Spend` with validation and an affordability check.
- `PlateService`'s `UpdateCoins` fires and its per-tick `ActiveCPS` attribute became the `Currency` and `IncomePerSecond` attributes. The income is now game-supplied instead of computed from species CPS.
- The Studio `$10K` join grant from `DataService` became `STUDIO_START_BALANCE`.
- `runEarned` became the lifetime `totalEarned`, which is never reset here.
