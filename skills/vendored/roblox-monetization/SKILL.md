---
name: roblox-monetization
description: "Roblox purchase correctness: Game Passes, Developer Products, receipts (ProcessReceipt / BindReceiptHandler), subscriptions, private servers, Robux transfers, PolicyService and paid-random-item odds disclosure. Use when adding, changing, debugging or auditing purchases: a purchase not granting or double-granting, receipt bugs, pricing, shop offers, Robux prompts, refunds or make-goods, and paid random item policy."
---

# Roblox monetization

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins (see its `references/monetization.md`).

## When to use

Adding a Game Pass, Developer Product, subscription, private server, Robux transfer, Creator Rewards-related product decision, or purchase eligibility check.

## Quick reference

- Prompt purchases from the client; grant value only from server-owned code.
- Passes: one server-owned ID-to-benefit registry; join and in-session purchase run the same idempotent benefit path. A failed ownership query is "unknown", never "does not own". Full.md §2a.
- Developer Products: repeatable consumables. Exactly one receipt owner per server. `ProcessReceipt` still works; `BindReceiptHandler` (with `Enum.ReceiptType.DeveloperProduct`) is a newer alternative. `PromptProductPurchaseFinished` is not purchase confirmation.
- Dedupe by `PurchaseId` stored in the player's own session-locked save, written together with the grant. Return `NotProcessedYet` whenever the grant cannot happen (player gone, data not loaded, nothing to grant, policy-blocked).
- Creator Rewards is a platform program, not a grant API.
- Test failed/duplicate grants, absent players and interrupted saves. Transfers, subscriptions and dynamic pricing: full.md.
- A receipt handler's presence is not proof of correctness; inspect ownership, durable idempotent grant, and retry paths.

## Paid random items

- If currency can be bought with Robux, every roll paid with that currency is a paid random item, as are Robux shortcuts into a roll and odds-changing passes.
- Disclose every outcome with its exact odds before purchase, computed by the same code the server rolls with, summing to 100%.
- Read `PolicyService:GetPolicyInfoForPlayerAsync(player).ArePaidRandomItemsRestricted` on join (retry; a failed lookup counts as restricted).
- **Our default for restricted players** (from `roblox-lessons` monetization.md): block Robux-to-currency products and Robux-to-roll shortcuts (UI notice plus the server refuses the receipt), do not sell odds-changing passes, and leave pass-only outcomes out of their rolls, so their currency is earned-only. Upstream instead suggests presenting Roblox's full list of treatments and avoiding blocking by default; consider those alternatives only when the owner asks for a different trade-off.

> Purchase flows, receipts, subscriptions and failure tests: [references/full.md](references/full.md)
