# systems/core

These are the foundation every other hub system builds on. Install all four into every game made from `template/`; each sub-folder's README has the details.

| System | Provides | Depends on |
| --- | --- | --- |
| [`remotes/`](remotes/README.md) | `Remotes.event(name)`: RemoteEvents in `ReplicatedStorage.RemoteEvents`, created per system | — |
| [`format/`](format/README.md) | `NumberFormat.Short` / `Money` / `Rate` | — |
| [`data/`](data/README.md) | `shared.DataServiceAPI`: ProfileStore saves, migrations, `PlayerLoaded`, receipt dedupe | — |
| [`economy/`](economy/README.md) | `shared.EconomyAPI` (`Grant` / `Spend` / `GetBalance` / `GetIncome`), plus the `Currency` / `IncomePerSecond` attributes | data |

## Install order

1. **remotes**: copy `shared/Remotes.lua`.
2. **format**: copy `shared/NumberFormat.lua` and its spec.
3. **data**:
   - Copy the `server/`, `shared/` and `tests/` files.
   - Add `exclude = ["src/server/ProfileStore.lua"]` to `selene.toml`.
   - Set `DataConfig.STORE_NAME`.
4. **economy**: copy `server/EconomyService.server.lua` and `shared/EconomyConfig.lua`. Then set the `IncomePerSecond` attribute from your game's income logic, if it has idle income.
5. **Then the other areas** (`systems/ui`, `systems/monetization`, `systems/liveops`, ...). For each one, add the saved fields its README lists to `src/shared/DataTemplate.lua`.

Copy each sub-folder's `server/` to `src/server/`, `shared/` to `src/shared/`, and `tests/` to `tests/`.

## Contract

The APIs above are the ones `systems/CONVENTIONS.md` promises.
- Server APIs are published on `shared` before any yield, with every method attached. Wait for them with `repeat task.wait() until shared.X`.
- Client UIs never read save data. They read the `Currency` and `IncomePerSecond` Player attributes, or a system's own remotes.

## Checked

- The four systems were copied into a fresh `template/` copy.
- `selene src tests`: 0 errors, 0 warnings, with the ProfileStore exclude.
- `wally install` and `rojo build default.project.json` both succeed.
