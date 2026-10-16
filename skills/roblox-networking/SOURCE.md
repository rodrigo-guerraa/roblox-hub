# Source: roblox-networking

- **Upstream:** https://github.com/TabooHarmony/roblox-brain
- **Path:** `skills/core/roblox-networking/`
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
- `SKILL.md`: added the initial-sync lesson (a queued RemoteEvent payload reaches only the first client listener; use `Request*` re-sync remotes) and the prompt/detector-as-remote rule.
- `full.md` section 7e: added the same initial-sync lesson next to the buffering note; marked the "order of magnitude below the ceiling" guidance as upstream opinion.
- `full.md` header: practitioner/operator numbers marked as opinions to tune, not Roblox limits.
- Dropped the edit-mode network mock bullet from `SKILL.md` (still in full.md) to keep the entry point compact.

## Upstream cited sources

As listed in the upstream `SKILL.md` frontmatter (`original` means the author's own material):

- https://create.roblox.com/docs/scripting/events/remote
- https://create.roblox.com/docs/scripting/security/security-tactics
- https://create.roblox.com/docs/scripting/security/client-server-boundary
- https://create.roblox.com/docs/projects/server-authority
- https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent
- https://create.roblox.com/docs/reference/engine/classes/Workspace#GetServerTimeNow
- https://1axen.github.io/blink/
- original
