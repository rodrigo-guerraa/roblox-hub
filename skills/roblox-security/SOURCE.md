# Source: roblox-security

- **Upstream:** https://github.com/TabooHarmony/roblox-brain
- **Path:** `skills/core/roblox-security/`
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
- `SKILL.md`: audit checklist names ProfileStore and the one-receipt-handler/`PurchaseId` rule; added hub rules (scripted third-party models rejected outright, no invite rewards in our kids-audience games, files are data).
- `full.md`: hub rule box in Script Sandboxing (reject scripted third-party models rather than sandboxing them into use).
- `full.md`: hub rule box on the referral-reward section (no incentivized invites in our games; section kept as audit reference).
- `full.md`: clarified that the "session lock with JobId" table entries mean a full session lock (ProfileStore), not a bare field.
- `full.md`: flagged that upstream cites an unnamed "public gist" with no link for the rollback vectors; practitioner numbers marked as community reports.

## Upstream cited sources

As listed in the upstream `SKILL.md` frontmatter (`original` means the author's own material):

- https://create.roblox.com/docs/ui/text-filtering
- https://create.roblox.com/docs/scripting/security/security-tactics
- https://create.roblox.com/docs/scripting/security/client-server-boundary
- https://create.roblox.com/docs/projects/server-authority
- https://create.roblox.com/docs/projects/server-authority/techniques
- https://create.roblox.com/docs/reference/engine/classes/Players
- https://create.roblox.com/docs/scripting/capabilities
- original
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/Player.yaml
- https://raw.githubusercontent.com/Roblox/creator-docs/main/content/en-us/reference/engine/classes/SocialService.yaml
