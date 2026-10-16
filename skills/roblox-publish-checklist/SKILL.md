---
name: roblox-publish-checklist
description: "Evidence-backed release gate for a Roblox experience: classify gates, block on persistence, remote, purchase and cloud failures, exercise the shipped surface, check Creator Dashboard settings, and report READY / NOT READY / READY WITH ACCEPTED RISK. Use before publishing or updating an experience, restarting servers, or when asked whether a build is ready, safe or tested enough to ship."
---

# Roblox publish checklist

Where this conflicts with the `roblox-lessons` skill, `roblox-lessons` wins.

## 1. Define the release

Record the changed places, scripts, assets, configuration, schemas, products, supported devices and rollback path. Classify each gate as required, conditional or not applicable before testing.

## 2. Block on high-consequence failures

- **Persistence changed:** load, save, migration, duplicate-session, disconnect and shutdown behavior (`roblox-data`).
- **Remotes or authority changed:** types, bounds, state, ownership, replay and abusive frequency (`roblox-networking`, `roblox-security`).
- **Purchases changed:** durable, idempotent receipt grants and retries; paid-random-item restrictions honoured (`roblox-monetization`).
- **Cloud auth or webhooks changed:** secrets, scopes, retries, signatures, deduplication (`roblox-lessons` `references/open-cloud.md`).

A failed high-consequence gate means NOT READY; never average it into a percentage. User approval authorizes an otherwise permitted action; it does not satisfy a mandatory policy or turn a failed or unverified gate into PASS.

## 3. Exercise the shipped surface

- One normal flow plus failure, retry, leave/rejoin and rapid-input cases relevant to the change.
- Every supported input mode and representative viewport/device tier.
- Errors, memory, frame/network cost and streaming.
- Focus, touch targets, contrast, non-color state cues, reduced motion, localized overflow where applicable.
- Dashboard metadata, permissions and policy; after publishing, the version actually serving players.

## 4. Hub gates (from `roblox-lessons`)

- Studio-only conveniences (starting grants, force-owned passes, test runners) are guarded by `RunService:IsStudio()`.
- Studio saves go to the `_Studio` store; production store names unchanged (no rename to change a format).
- Every pass/product id and display price matches the dashboard; prices are 2 R$ or more.
- Paid random items: odds shown before purchase; restricted players blocked from currency products, roll shortcuts and odds-changing passes; questionnaire answered "yes" to paid random items.
- Publishing ships from Studio: Rojo sync finished and the place saved before publishing (place-file art lives only there).
- The human owner decides prices, visibility and publishing; an API key cannot make a game public or upload thumbnails.

## 5. Require evidence

Every PASS cites a test, log, MCP readback, profiler capture, screenshot or dashboard inspection. UNVERIFIED if unavailable; approval is not evidence.

## Output

`READY`, `NOT READY`, or `READY WITH ACCEPTED RISK`; blockers first, then warnings, unverified gates, evidence, rollback plan, and skipped gates with reasons.

> Details: [references/full.md](references/full.md)
