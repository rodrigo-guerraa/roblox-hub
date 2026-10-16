# Monetization lessons

## Receipts (developer products)
- Exactly **one** `MarketplaceService.ProcessReceipt` handler per server; dispatch every product inside it. (`BindReceiptHandler` is a newer alternative; ProcessReceipt still works.)
- **Dedupe by `PurchaseId` stored in the player's own save** (keep the last ~50 ids) — written in the same session-locked profile as the grant, so a crash can't double-grant or lose it. In-memory dedupe tables lose grants on crash.
- Return `NotProcessedYet` whenever the grant can't happen (player gone, data not loaded, nothing to grant, policy-blocked). Never charge for nothing: a "collect ×N" with empty plates returns NotProcessedYet.
- Test grants without spending: call the real handler (via a temporary Script) with fake receipts — check exact amounts, refusals, and that a repeated PurchaseId grants once.

## Passes vs products
- Gamepass = permanent, bought once. Developer product = consumable, repeatable. They don't compete (a permanent 2× income pass vs a one-off "collect what's waiting ×N").
- **The account that creates passes (including via an API key acting as you) automatically owns them** — the owner can't test buying a pass; use an alt. Products can still be test-bought.
- Studio prompts are free test purchases.
- Pitch passes in context (stepping on a locked plate offers its pass, a welcome-back popup offers the offline booster) with a cooldown.

## Pricing
- Roblox keeps 30% and rounds the creator share down (reportedly a 1 R$ item earns nothing). Keep prices ≥ 2 R$.
- Any **repeatable** product that multiplies a value must have a cap or a price ladder. A flat-price "double your offline earnings" was buyable repeatedly, doubling each time; fixed as a ladder (e.g. 9/19/39/79/159 R$, up to ×32) that resets when collected and refuses past the end.
- Income-scaled payouts ("1 hour of your income") keep packs worth buying at every stage; show the real amount ("+$2.1M instantly"), not "1h of income".

## Paid random items (policy)
- If currency can be bought with Robux, **every random roll paid with that currency is a paid random item**, as are Robux shortcuts into a roll and odds-changing passes.
- **Disclose every outcome with its exact odds before purchase**, summing to 100% (mark "rounded" if rounded); compute them with the same code the server rolls with. Odds-changing passes state their effect in numbers.
- Read `PolicyService:GetPolicyInfoForPlayerAsync(player).ArePaidRandomItemsRestricted` on join (retry; a failed lookup counts as restricted). For restricted players: block Robux→currency products and Robux→roll shortcuts (UI notice + server refuses the receipt), don't sell odds-changing passes, and leave pass-only outcomes out of their rolls. Then their currency is earned-only.
- Answer "yes" to paid random items in the Maturity & Compliance questionnaire.

## Young audience
- No rewards for inviting friends (incentivized invites). Favorite prompt once, at a high point (e.g. first rebirth), skipped if already favorited.
- The age label comes from the questionnaire; voice chat can be switched off via the API.

## Group-owned games
- Revenue lands in group funds; members are paid by recurring % payouts or one-time payouts by anyone with "Spend group funds".
