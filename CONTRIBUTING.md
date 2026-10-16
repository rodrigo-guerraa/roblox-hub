# Contributing

The hub grows out of real games. When a game builds something reusable that we're happy to share, it comes back here. Because this repo is public and every new game starts from it, contributions are held to a higher bar than game code.

## What belongs here

**Belongs in the hub**

- Systems most games need, made generic: saving, economy hooks, monetization plumbing, live-ops, UI components, tooling.
- New Roblox gotchas, learned the hard way → [`skills/roblox-lessons`](skills/roblox-lessons/).
- Template improvements: a rule, config or tool every new game should start with.
- Third-party skills or libraries worth vendoring (see [Vendoring](#vendoring-third-party-content)).

**Stays in the game (proprietary)**

- The core loop and everything that makes the game *that* game: content, items, creatures, map, story, names and branding.
- Art, models, audio and icons the game owns.
- Economy tuning, prices and balance numbers. The hub ships neutral example values.
- Anything that carries the game's ids: universe, place, group, products, passes, badges.

When in doubt, ask the maintainer.

## When

Once a feature is finished and verified in its game, the agent checks whether it qualifies. If it does, it says so in one line and ports it after the maintainer agrees, as a separate piece of work, never in the middle of a feature. Improvements to a system a game took from the hub go through the same path.

## The bar

1. **Generic.** No game names, ids, paths or numbers that only make sense in one game. Everything a game would change lives in the system's `<System>Config.lua`, with ids at `0` (meaning "off") and neutral example values. It should read as if it was written for the hub.
2. **Follows the contract** in [`systems/CONVENTIONS.md`](systems/CONVENTIONS.md): folder layout, published APIs, remotes, attributes, saved fields, publish-before-yield.
3. **Self-contained.** No file-name collisions with other systems (`assemble-sandbox.sh` refuses them); dependencies on other systems are listed in its README.
4. **Tested.** Pure logic has TestEZ specs. Everything else is verified in Studio (below), including forged remote payloads, which must be rejected.
5. **Documented.** The system's README covers what it does, install steps, config, API, saved fields and a verification checklist. [`docs/reuse-catalog.md`](docs/reuse-catalog.md) gets a row with an honest status. UI changes come with a screenshot.
6. **Clean.** StyLua-formatted, selene with 0 errors and 0 warnings, builds with Rojo. Comments only where the *why* isn't obvious.
7. **Private.** Nothing personal: no user paths, emails, real ids or keys. `scripts/check.sh` catches the common cases; review the diff anyway.
8. **Licensed.** The hub's own code is MIT. Third-party content must be MIT, Apache-2.0 or similarly permissive, vendored as described below.

## Process

1. **Port.** Copy the code into `systems/<area>/<name>/` (or edit the existing system) and move every game-specific value into its config.
2. **Check.** Run `bash scripts/check.sh`: the privacy guards, format check, lint and build of the template with every system installed. CI runs exactly the same script. It needs `stylua`, `selene` and `rojo` on `PATH`; `rokit install` inside `template/` installs the pinned versions.
3. **Verify in Studio.**
   - `bash scripts/assemble-sandbox.sh`, then `rojo serve --port 34873` inside `.sandbox/` (a different port from the game's).
   - The maintainer opens an empty Baseplate and connects the Rojo plugin to that port.
   - Set the `RunTests` attribute on `ReplicatedStorage.Tests`, press Play and read the results.
   - Exercise the behaviour through the Studio MCP: valid and forged remote calls, purchases with fake receipts (a temporary Script calling `shared.ReceiptAPI.HandleReceipt`), clicks on the real UI, screenshots.
   - Temporary test scripts go in `.sandbox/` only. It is gitignored and rebuilt from scratch, so they can never be committed.
   - Record what was verified, and what couldn't be, in the catalog status.
4. **Commit.** One logical change per commit. The subject is an imperative sentence under ~72 characters saying what changed; the body says why and how it was verified. Docs describing the change go in the same commit. No "WIP" or "fix typo" chains: tidy them up before pushing.
5. **Push.** Only with the maintainer's go-ahead. Watch the CI run and fix it straight away if it goes red.

## Vendoring third-party content

- Copy by hand at a pinned commit; never run installers.
- Keep the upstream `LICENSE` (and `NOTICE` for Apache-2.0) in the folder.
- Add a `SOURCE.md` with the source, commit, license and every change made.
- Mark each modified file: `Adapted from <project> (<license>). Modified; see SOURCE.md.`
- Remove text that tries to steer the agent ("load me first", "override other rules"). Where advice conflicts with `roblox-lessons`, fix it and note that `roblox-lessons` wins.
- List it in [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) and, for skills, in [`skills/vendored/README.md`](skills/vendored/README.md).

## Outside contributions

Issues and pull requests are welcome. The same bar applies, and CI must pass before anything is merged.
