# Open Cloud API lessons

Base URL `https://apis.roblox.com`, header `x-api-key`. Docs index: `https://create.roblox.com/docs/cloud/llms.txt` (feature pages at `/docs/cloud/reference/features/<name>.md`).

## Keys
- A key is owned by a user or a group; it only reaches that owner's games. Group-owned game → group key (the owner's role permissions cap it).
- Store the key in a file **outside the repo** (e.g. `%USERPROFILE%\.<game>_api_key.txt` — Windows may append `.txt`); read it into a shell variable, never echo it, never paste it in chat.
- Check what a key can do: `POST /api-keys/v1/introspect` with `{"apiKey": "..."}` → scopes, universe limits, expiry.
- Scope names matter exactly: `universe.place` (dot) edits place settings; `universe-places` (dash) only publishes place files.
- Keys auto-expire (set one) and expire after long non-use; delete the file when done.

## What works with a key (verified)
| Task | Endpoint | Scope |
| --- | --- | --- |
| List / create / update game passes (name, description, price, on-sale, **icon**) | `GET/POST /game-passes/v1/universes/{u}/game-passes`, `PATCH …/{id}` (multipart; `imageFile`) | `game-pass:read/write` |
| List / create / update developer products (incl. icon) | `/developer-products/v2/universes/{u}/developer-products` (multipart) | `developer-product:read/write` |
| Server size, place name, description | `PATCH /cloud/v2/universes/{u}/places/{p}?updateMask=serverSize` (JSON) | `universe.place:write` |
| Voice chat and other universe settings | `PATCH /cloud/v2/universes/{u}?updateMask=voiceChatEnabled` | `universe:write` |
| Read a player's save | `GET /cloud/v2/universes/{u}/data-stores/{store}/entries/{key}` | `universe-datastores.objects:read` |

- Creating passes/products: set `isRegionalPricingEnabled=false` if displayed prices must match exactly. Rate limits ~3–5 req/s; pause between calls.
- Icons go through moderation (minutes). Read back after writing — but a product's `iconImageAssetId` is non-zero even with the default image, so track what you uploaded yourself.
- Universe description is set through the root **place** (the universe field mirrors it). Emoji need UTF-8 JSON (`--data-binary @file`, Python with `PYTHONIOENCODING=utf-8`).

## What doesn't (verified)
- `PATCH …/universes/{u}?updateMask=visibility` returns 200 but **is ignored**. Making a game public needs `POST /legacy-develop/v1/universes/{u}/activate` with `legacy-universe:manage` — or the owner clicks it in the dashboard.
- **Game thumbnails/icon can't be uploaded with an API key** (cookie-only endpoints) — the owner uploads them.
- Creating badges needs `legacy-universe.badge:manage-and-spend-robux` (badges can cost Robux beyond a free allowance).
- Public game info (`games.roblox.com`) shows placeholders while a game is private.
