# core/remotes — RemoteEvents by name

## 1. What it does

**Player-facing:** nothing directly. It is the plumbing every client↔server feature uses.

**Technical:** `Remotes.event(name)` returns the RemoteEvent `ReplicatedStorage.RemoteEvents.<name>`. Each system creates its own remotes by name, so there is no central list.

```lua
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"))
local claim = Remotes.event("ClaimGift")
```

- **On the server**, it creates the `RemoteEvents` folder and the event if missing. The lookup is synchronous and never yields, so it is safe before publishing a `shared` API. It errors if the name already exists as something other than a RemoteEvent, or if `RemoteEvents` exists but isn't a Folder.
- **On the client**, it waits for the folder and the event. After `CLIENT_WARN_AFTER` (10 s) it `warn`s "still waiting for remote X ... is its server script installed?", then keeps waiting, so a late server creation still connects. It never returns `nil`.
- Results are cached per name. The name must be a non-empty string (asserted).
- Create every server-side remote at the top of its server script, before any yield. Clients then never wait long, and a queued fire is never dropped.
- A queued payload is delivered only to the **first** client listener. When several client scripts need the same on-join push, give the system a `Request<Thing>` remote whose server handler re-sends the payload (see `skills/roblox-lessons/references/data.md`).

## 2. Depends on

Nothing.

## 3. Install

| File | Destination |
| --- | --- |
| `shared/Remotes.lua` | `src/shared/Remotes.lua` |

- **Saved fields:** none.
- **Config:** none. The folder name `RemoteEvents` is part of the hub contract (`Remotes.FOLDER_NAME`); don't change it.

## 4. Remotes

It creates only what callers ask for, inside `ReplicatedStorage.RemoteEvents`.

## 5. Verify in Studio (MCP)

1. **Clean start.** `start_stop_play` to start, then `get_console_output`. Expect no `Remotes:` warnings.
2. **Server side.** `execute_luau` (Server): `return #game.ReplicatedStorage.RemoteEvents:GetChildren()`. Every remote the installed systems create should be listed, and each should be a `RemoteEvent`.
3. **Client side.** `execute_luau` (Client):
   - `return require(game.ReplicatedStorage.Remotes).event("<an existing name>"):GetFullName()` returns at once.
   - A made-up name warns after 10 s; run it in a `task.spawn` so the call doesn't block.
4. **Repeat calls.** On the server, calling `Remotes.event("X")` twice returns the same instance (`==`).

## 6. Origin

Dino Simulator `src/server/RemoteSetup.server.lua` registered every remote from the `Config.EVENT_*` constants, and clients used `RemoteEvents:WaitForChild(name)`. Here creation is lazy and per system, so independent systems can be copied in without editing a central list. The client wait got a named warning.
