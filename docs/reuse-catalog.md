# Reuse catalog

Everything in the hub that a new game can take, and what it costs to take it. Each system's README has exact install steps; `systems/CONVENTIONS.md` is the contract they share.

**Status legend:** ✅ proven in a shipped game (Dino Simulator) · 🔁 extracted from proven code and made generic — builds and lints clean as a full stack, **not yet run in Studio** (first new game must verify it through the MCP).

## Systems (`systems/`)

### core — install first, everything else depends on it
| System | What you get | Saved fields | Status |
| --- | --- | --- | --- |
| `core/remotes` | `Remotes.event(name)`: systems create their own RemoteEvents, no central list | — | 🔁 |
| `core/format` | `NumberFormat`: `Short` "25.3M", `Money` "$25.3M", `Rate` "$37.5/s" (to decillions) + spec | — | 🔁 (✅ logic) |
| `core/data` | ProfileStore session locking, Studio-only `_Studio` store, step-by-step save migrations (refuse newer/broken saves, never wipe), purchase-id dedupe, `PlayerLoaded` signal | `dataVersion`, `lastSeen`, `purchaseIds` + your game's | 🔁 (✅ logic) |
| `core/economy` | Default `EconomyAPI` (Grant / Spend / GetBalance / GetIncome) over one currency, mirrored to `Currency` / `IncomePerSecond` Player attributes | `currency`, `totalEarned` | 🔁 |

### ui
| System | What you get | Status |
| --- | --- | --- |
| `ui/kit` | Cartoon UI kit (`UIStyle`: windows, buttons, cards, lists, bars, HUD dock that dodges phone controls), `UIManager` (one window at a time, tutorial lock), `Notice` toasts, `Effects` (flying coins, confetti, banners), `SoundFX` (licensed library audio), music + mute tile, loading screen with font preload, `CurrencyDisplay` counter, the owner's cartoon `Icons` | 🔁 (✅ look and phone layout) |

### monetization
| System | What you get | Saved fields | Status |
| --- | --- | --- | --- |
| `monetization/receipts` | The single `ProcessReceipt`, PurchaseId dedupe in the save, `ReceiptAPI.Register(productId, handler)`, income-scaled currency packs from config | — | 🔁 (✅ logic) |
| `monetization/gamepasses` | Live ownership (join + purchase), Studio force-own switch, `Pass_<KEY>` attributes, `PassPrompt.Offer` for in-world pitches | — | 🔁 |
| `monetization/paid-random-items` | Policy lookup (`PaidRandomRestricted`), blocking hooks for receipts/passes, `OddsDisclosure` (exact odds that match the roll) + specs | — | 🔁 (✅ logic) |
| `monetization/offline-earnings` | Offline pool at a reduced rate with a cap, booster pass, welcome-back popup, exploit-proof doubling ladder (9/19/39/79/159 R$) | `offlinePool`, `offlineDoubles` | 🔁 |

### liveops
| System | What you get | Saved fields | Status |
| --- | --- | --- | --- |
| `liveops/codes` | Promo codes paying seconds of income, once per player, expiry, rate limit, Codes window | `redeemedCodes` | 🔁 (✅ logic) |
| `liveops/playtime-gifts` | Gift every 10 min online, stops at ready (no stacking), grows within a session, Gift tile + window | `giftProgress` | 🔁 |
| `liveops/group-rewards` | Group members' income bonus, one-time join reward (in-game join prompt), group card, `GroupPad`-tagged world pads | `groupJoinClaimed` | 🔁 |
| `liveops/badges` | Badge engine: definitions judged from the save, award loop with retry (`AwardBadgeAsync`), ids 0 = off | `badgesAwarded` | 🔁 |
| `liveops/social-prompts` | Invite tile (no rewards), favorite prompt once at a moment the game chooses | `favoritePromptShown` | 🔁 |

**Typical simulator install order:** core (remotes → format → data → economy) → ui/kit → monetization (receipts → gamepasses → paid-random-items → offline-earnings) → liveops.

**Not in the hub (game-specific in Dino Simulator, rebuild per game):** the core loop (dig/hatch/plates/rebirth), map builder, quests, cosmetics shop, money boost ×N, clone, Hatch Now / Free Hatch products, tutorial, shopkeeper dialogue. Patterns from them live in `skills/roblox-lessons`.

## Skills (`skills/`, installed user-wide by `scripts/sync-skills.ps1`)

| Skill | Use for | Source |
| --- | --- | --- |
| `roblox-lessons` | **Always** — our gotchas (UI, Studio MCP, saving, monetization, Open Cloud, assets, economy, AI workflow) | Ours |
| `roblox-dev` | Engineering reference: worked examples, persistence, receipts, MCP + agent safety, deprecated APIs, security, networking | MSayib (MIT) |
| `roblox-data`, `roblox-monetization`, `roblox-networking`, `roblox-security`, `roblox-studio-mcp`, `roblox-tooling`, `roblox-publish-checklist` | Domain guides with sources | TabooHarmony/roblox-brain (MIT) |
| `roblox-debugging-bugfix`, `roblox-to-issues` | Process: hypothesis-driven debugging with the MCP; slicing work into verifiable pieces | AshExplained (MIT), derived from mattpocock/skills (MIT) |
| `roblox-creator-store-security-audit`, `roblox-security-economy`, `roblox-release-operations` | Asset audits, economy exploits, releasing and rolling back | AshExplained (MIT) |
| `game-feel`, `game-ui-ux`, `level-design`, `audio-design`, `save-systems` | Engine-agnostic design craft, adapted for Roblox | gamedev-skills (Apache-2.0) |

Every vendored skill has `SOURCE.md` (pinned commit, license, our changes) and says `roblox-lessons` wins on conflicts.

## Template (`template/`)
Empty game with pinned tools (Rojo 7.7.1, Wally, Selene 0.32, StyLua 2.6, luau-lsp 1.70.1, Lune 0.11), lint/format/type-check configs, TestEZ runner, starter `CLAUDE.md`. ✅ builds; first Studio run happens with the first new game.

## Docs
- `onboarding.md` — starting a game; who does what.
- `research/2026-10-skill-and-tool-survey.md` — tools, libraries and skill repos we evaluated and why.
