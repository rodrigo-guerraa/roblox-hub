# Source: roblox-monetization

- **Upstream:** https://github.com/TabooHarmony/roblox-brain
- **Path:** `skills/design/roblox-monetization/`
- **Pinned commit:** `ceee4aaa5004502e2a51d78b3c33bba44d84742b` (2026-10-14)
- **License:** MIT, Copyright (c) 2026 TabooHarmony (verbatim in `LICENSE`)
- **Vendored:** 2026-10-16
- **Upstream last_reviewed:** 2026-10-14

## Files taken

- `SKILL.md` (rewritten, see below)
- `references/full.md` (edited, see below)
- `LICENSE` (repository root `LICENSE`, verbatim)

Nothing was installed or executed from the upstream repository; files were read as data and copied by hand.

## Changes we made

- `SKILL.md` rewritten as a compact entry point (under 4 KB); frontmatter reduced to `name` + `description` (upstream `description` and `when_to_use` merged; `last_reviewed` and `sources` moved into this file).
- Added "Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins." near the top of `SKILL.md` and a matching hub note at the top of `references/full.md`.
- Links to upstream skills we did not vendor are rewritten to hub skills that exist (`roblox-lessons` reference files or the other six vendored skills) or removed.
- `SKILL.md`: added a "Paid random items" section with our default for restricted players (block Robux-to-currency products and Robux-to-roll shortcuts, no odds-changing passes, pass-only outcomes left out of their rolls); upstream's "do not default to blocking" stance is kept only as an alternative for the owner to choose.
- `SKILL.md`/`full.md`: `BindReceiptHandler` presented as the newer alternative; `ProcessReceipt` still works. `PurchaseId` dedupe stored in the player's own session-locked save.
- `full.md` section 6: hub-default box overriding the "present all options / do not block" paragraphs; added the questionnaire "yes" reminder.
- `full.md` section 3: `ApplyGrantOnce` tied to the player's ProfileStore profile.
- `full.md`: Creator Rewards figures and the Robux-transfer "Roblox Plus" claim marked as upstream claims not re-verified.
- `full.md` checklist: added restricted-player blocking and the 2 R$ minimum / capped-ladder rule from roblox-lessons.

## Upstream cited sources

As listed in the upstream `SKILL.md` frontmatter (`original` means the author's own material):

- https://create.roblox.com/docs/reference/engine/classes/MarketplaceService
- https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#BindReceiptHandler
- https://create.roblox.com/docs/production/monetization/passes
- https://create.roblox.com/docs/production/monetization/developer-products
- https://create.roblox.com/docs/production/monetization/subscriptions
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/production/monetization/regional-pricing.md
- https://create.roblox.com/docs/production/monetization/robux-transfers
- https://create.roblox.com/docs/production/monetization/paid-random-items
- https://create.roblox.com/docs/reference/engine/classes/PolicyService
- https://create.roblox.com/docs/creator-rewards
- https://devforum.roblox.com/t/creator-rewards-is-live/3838257
- original
