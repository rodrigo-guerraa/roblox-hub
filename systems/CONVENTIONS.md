# Hub systems — conventions

Every system in `systems/` is copied into a game (never linked) and must work in any game built from `template/`. These rules are the contract between systems.

## Layout

```
systems/<area>/<system>/
├── README.md        what it does, depends on, install steps, settings, saved fields, remotes, how to verify, origin
├── server/          → copy to the game's src/server/
├── client/          → copy to src/client/
├── shared/          → copy to src/shared/
└── tests/           → copy to tests/ (specs for pure modules)
```

File suffixes follow the template: `.server.lua` Script, `.client.lua` LocalScript, `.lua` ModuleScript, `.spec.lua` TestEZ spec. No game-specific names (no dinos, eggs, plates, rebirths) — use neutral words (currency, income, item, reward).

## Settings

Each system ships `shared/<System>Config.lua` with all its tunables and their defaults (ids are `0` = disabled). Systems never read a global `Config`. A game edits the copied config file.

## Core APIs every system may use (provided by `systems/core`)

**Remotes** — `local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))`
- `Remotes.event(name)` → RemoteEvent in `ReplicatedStorage.RemoteEvents`. On the server it creates it if missing; on the client it waits for it. Systems create their own remotes this way; there is no central list.

**Data** — `shared.DataServiceAPI` (server; wait with `repeat task.wait() until shared.DataServiceAPI`)
- `GetData(player)` → the live, auto-saved profile table, or `nil` while loading
- `WaitForData(player)` → the table, or `nil` if the player left / load failed
- `PlayerLoaded` → signal `(player, data)` fired once per join after migration + reconcile, with `:Connect` / `:Once` / `:Wait` like an RBXScriptSignal (a custom object, because a BindableEvent would deep-copy `data` instead of passing the live table)
- `HasPurchase(player, purchaseId)` / `RecordPurchase(player, purchaseId)` — receipt dedupe kept in the save (last 50)
- Systems mutate their own fields on the returned table directly and must tolerate a missing field (`data.x = data.x or default`). Each system's README lists the fields + defaults the game adds to its `DataTemplate`.

**Economy** — `shared.EconomyAPI` (server). Core ships a default; a game may replace it with its own implementation of the same functions.
- `Grant(player, amount, source)` → new balance. Adds currency (positive amounts only) and syncs it.
- `Spend(player, amount, source)` → `true` if the player could afford it and it was taken.
- `GetBalance(player)` → number.
- `GetIncome(player)` → currency per second (used for income-scaled rewards; `0` if the game has no idle income).
- The default also mirrors `Currency` and `IncomePerSecond` as **Player attributes** — client UIs read those (never a game-specific remote).

**UI** — `systems/ui/kit` provides `UIStyle` (cartoon kit, windows, buttons, HUD dock), `UIManager` (panel registry, tutorial lock), `Notice`, `Effects`, `SoundFX`, `NumberFormat` lives in core. Client UIs of other systems use these.

## Code rules (same as the template CLAUDE.md)
- No comments unless the WHY is non-obvious; one short line max.
- Every client→server request is validated on the server (types, loaded data, eligibility, rate limit where it matters); bad requests are silently ignored.
- `shared.X = T` is assigned with all methods attached and before any yield.
- Studio-only conveniences are guarded by `RunService:IsStudio()`.
- `selene` clean. Pure modules get TestEZ specs.

## README must include
1. What it does (player-facing and technical) · 2. Depends on (other hub systems) · 3. Install: exact files → destinations, DataTemplate fields to add, config to edit, ids to create · 4. Remotes it creates · 5. How to verify in Studio via the MCP (concrete checks) · 6. Origin (which Dino Simulator files it came from and what changed).
