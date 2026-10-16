# liveops/social-prompts — Invite tile and a one-time favorite prompt

## 1. What it does

**Player-facing:**
- An "Invite" HUD tile opens Roblox's invite-friends prompt. There is **no reward for inviting**, since incentivized invites are not allowed for a young audience. Accounts that can't send invites don't see the tile.
- Once per player ever, at a high point the game chooses (the first rebirth, the first boss, the first big unlock), Roblox's "favorite this experience?" prompt appears a few seconds after the celebration. It is skipped if they already favorited.

**Technical:**
- Client: the tile uses `SocialService:CanSendGameInviteAsync` / `PromptGameInvite`. The tile hides when the check says no; a failed check keeps it, and the click re-checks.
- The favorite prompt fires when the Player attribute `FavoritePromptMoment` becomes `true`, at most once per session. After `FAVORITE_DELAY` seconds it calls `AvatarEditorService:GetFavorite(game.PlaceId, Asset)`, and `PromptSetFavorite` only if that isn't already true.
- Server: `shared.SocialPromptsAPI.FavoriteMoment(player)` sets that attribute at most once per save (the saved `favoritePromptShown` flag) and returns whether it did. It is published with no yield before it.

## 2. Depends on

- `systems/core`: data (`shared.DataServiceAPI`, for the saved once-per-player flag).
- `systems/ui/kit`: `UIStyle`, `Notice`; `Icons` (`Icons.Friends`).

## 3. Install

| File | Destination |
| --- | --- |
| `server/SocialPromptsService.server.lua` | `src/server/` |
| `client/SocialPrompts.client.lua` | `src/client/` |
| `shared/SocialPromptsConfig.lua` | `src/shared/` |

**DataTemplate:** add `favoritePromptShown = false`.

**Config (`SocialPromptsConfig.lua`):**

| Key | Default | Meaning |
| --- | --- | --- |
| `INVITE_TILE` | `true` | Show the Invite HUD tile |
| `INVITE_ORDER` | `11` | Tile order |
| `FAVORITE_ATTRIBUTE` | `"FavoritePromptMoment"` | Player attribute that triggers the prompt |
| `FAVORITE_DELAY` | `4` | Seconds after the moment, so the game's own celebration plays first |

**Triggering the favorite prompt (game code, server):** call it once at your first big high point, after the player has had fun, never on join:

```lua
-- e.g. in your rebirth handler, after the rebirth succeeded
if data.rebirths == 1 and shared.SocialPromptsAPI then
	shared.SocialPromptsAPI.FavoriteMoment(player)
end
```

It is safe to call it at every milestone: it asks only the first time per save. You can also set `player:SetAttribute("FavoritePromptMoment", true)` yourself, but then only the client's once-per-session guard applies; the saved flag is the API's job.

No ids to create. No remotes.

## 4. Remotes

None. The trigger is a server-written Player attribute, which replicates to the client.

## 5. Verify in Studio (MCP)

1. `start_stop_play`, then `get_console_output`: no errors.
2. **Tile:** `execute_luau` (Client): `PlayerGui.HudDock` has an `InviteSlot`. Its `Visible` matches `SocialService:CanSendGameInviteAsync(LocalPlayer)`. In Studio this is usually false or errors: false hides the tile, an error keeps it.
3. **Favorite trigger:** call `FavoriteMoment` from a temporary server script, since MCP `shared` is sandboxed. It writes the return value to a player attribute. Expect `true` the first time and `false` the second time. On the Client, `LocalPlayer:GetAttribute("FavoritePromptMoment") == true`.
4. **Once per save:** with API access on, rejoin and call it again: it returns `false` and the attribute stays unset.
5. **Not testable in Studio:** `PromptSetFavorite` and `PromptGameInvite` only show real prompts in a live game. Check them on a published test place: the prompt appears about 4 s after the moment, and not at all when the place is already favorited.

## 6. Origin

Extracted from the reference game's `src/client/SocialPrompts.client.lua`.
- The trigger was "the client saw `UpdateRebirths` go 0 → 1 live". It is now any game's server setting `FavoritePromptMoment` through `SocialPromptsAPI.FavoriteMoment`, with a saved `favoritePromptShown` flag. That makes it once per player across sessions, where the original was implied by the rebirth count.
- Options moved into `SocialPromptsConfig`.
- The invite tile is unchanged apart from config.
