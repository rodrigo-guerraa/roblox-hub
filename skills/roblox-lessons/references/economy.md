# Economy design lessons (big-number simulators)

- **Pay rewards in seconds of the player's income** (codes, gifts, money pads, group bonus, Robux money packs), with a small floor for brand-new players. Flat rewards ($1,000) become worthless within an hour of a big-number progression.
- Expose the player's current income to the client (a server-written attribute) so UIs can show real payouts ("+$1.2M") instead of formulas.
- **Spending must keep up with income.** A hatch/upgrade cost of max(base × growth^rebirths, N seconds of income) × rarity multiplier keeps players near zero coins if they spend constantly; mutated/rare variants cost a big multiple of the income they add.
- Pace the progression with a quick simulation (Python is fine): model income, spending share (~50–70%), and rebirth goals, then tune goals for target minutes per rebirth. Re-run after any economy change.
- Count "earned this run" on every positive coin grant (not net of spending) for rebirth/goal progress; never count dev/test grants.
- Repeated small boosts (playtime gift every 10 minutes, growing within a session; group bonus ≈ +10% income) work when the timer **stops at ready until claimed** — no stacking — and progress is saved.
- Any repeatable purchase that multiplies something needs a cap or escalating price (see monetization.md).
- Offline earnings: a capped pool at a reduced rate (e.g. 50%, a pass doubles it), collected once via a welcome-back popup.
