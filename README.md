# roblox-hub

Shared toolkit for Roblox games built with AI (Claude Code). Every game starts from here and gives back to it.

| Folder | What's in it | Status |
| --- | --- | --- |
| `skills/` | Skills the AI reads. `roblox-lessons` = our own gotchas from shipped games. Third-party skills are vendored here (trimmed, pinned, licensed). | `roblox-lessons` done; third-party picks: step 2 |
| `template/` | An empty game wired for AI development (Rojo, Wally, Selene, StyLua, luau-lsp, Lune, TestEZ, starter `CLAUDE.md`). | Done |
| `systems/` | Proven game systems to copy into new games (saving, UI kit, monetization, live-ops). | Step 3 |
| `docs/` | Onboarding, reuse catalog, research notes. | Research saved; onboarding + catalog: step 3 |
| `scripts/` | Hub maintenance (e.g. installing skills user-wide). | Done |

## Install the skills (every project gets them)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\sync-skills.ps1
```

Copies `skills/*` into `%USERPROFILE%\.claude\skills\`. Re-run after the hub's skills change. It only replaces skill folders the hub owns (listed in `skills/`).

## Rules for the hub

- **Vendoring third-party skills:** copy chosen files by hand (never run installers), pin the source commit, keep the license, and record source + changes in a `SOURCE.md` next to them. Repos with no license are reference-only.
- **Systems are copied into games, not linked.** A game owns its copy; improvements are copied back here deliberately.
- **Lessons flow back.** When a game teaches something new, add it to `skills/roblox-lessons/references/`.
- Origin: built from Dino Simulator ("[BETA] +1 Hatch a Dino!"), `C:\Users\Digo\dino-game`.
