# Studio MCP and Rojo lessons

Studio has a **built-in** MCP server (Assistant settings). The standalone `Roblox/studio-rust-mcp-server` repo is archived. Tools used daily: `list_roblox_studios`, `get_studio_state`, `start_stop_play`, `get_console_output`, `execute_luau` (Edit / Server / Client datamodels), `screen_capture`, `user_mouse_input`, `character_navigation`, `search_asset`, `insert_asset`, `generate_mesh` (use `async`).

## Contexts
- `execute_luau` runs in a **plugin context**: its `shared` table and `require` cache are not the game's. To call a real server API (`shared.DataServiceAPI` etc.), create a temporary `Script` in ServerScriptService with `Source`, let it write results to its own attributes, read them, then `Destroy()` it.
- Plugin `require` caches the first load: `Clone()` a ModuleScript before requiring it to get fresh code.
- Connections made inside one `execute_luau` call die when it returns. For frame-driven checks across calls, use a temporary LocalScript driven by an attribute.
- A call returning several values shows only the first — return one formatted string.
- Setting `CameraType = Scriptable` is reset by the tool afterwards (it logs this).

## Play sessions
- **Kicking the only player while Play is starting wedges `start_stop_play`** ("Start play hasn't finished yet"). The maintainer must press Play and Stop by hand once. Test join-time kicks by reading the DataStore from Edit instead.
- `screen_capture` during Play shows the player's own view; move the character/camera (from the Client datamodel) to frame a shot.
- `screen_capture` with `camera_position` cancels any ProximityPrompt hold.
- SurfaceGuis don't render in Edit-mode captures; Decals do.
- Prompts: trigger with `prompt:InputHoldBegin()` / `InputHoldEnd()` only after `ProximityPromptService.PromptShown` fired for it (move closer first).
- `user_mouse_input` with `instance_path` fails on names containing spaces (e.g. "Item ShopSlot") — click by coordinates instead (AbsolutePosition + the GUI inset).
- Clicks that land on CoreGui (e.g. a Roblox purchase dialog) are refused; read CoreGui texts from the Client datamodel to confirm dialogs (e.g. the favorite prompt, invite screen).
- Studio is treated as owning every gamepass if your code force-owns them in Studio — timings and offers differ from live.
- Multi-client: the maintainer starts Test → Start Test Session; each window appears as its own studio id. `start_stop_play` is solo only.

## Rojo
- Rojo doesn't auto-reconnect after Studio restarts; the maintainer clicks Connect in the plugin.
- After editing files, **wait for the sync** (poll a script's `Source` for the new text) before rebuilding or pressing Play, or you test stale code.
- Adding a new `$path` entry needs `rojo serve` restarted.
- Studio-made art lives in the place file: declare its folders with `$ignoreUnknownInstances: true` (a parent with `$path` deletes unknown children otherwise) and **save the place** after changes. Publishing from Studio is what ships code and art.
- For temporary Studio-only tweaks (e.g. shortening a timer to test it), edit the Studio copy of the source, not the repo, and restore it after.
