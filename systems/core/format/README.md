# core/format — number formatting

## 1. What it does

**Player-facing:** every big number reads short and consistent: "25.3M", "$25.3M", "$37.5/s".

**Technical:** `NumberFormat` is a pure ModuleScript, usable on the server and the client.

| Function | Example |
| --- | --- |
| `NumberFormat.Short(n)` | `999` → `"999"`, `37.5` → `"37.5"`, `1450` → `"1.4K"`, `25300000` → `"25.3M"`, `-1450` → `"-1.4K"` |
| `NumberFormat.Money(n)` | `NumberFormat.CURRENCY .. Short(n)` → `"$2.5M"` |
| `NumberFormat.Rate(n)` | `Money(n) .. "/s"` → `"$30/s"` |

- Results round **down**, so a balance never looks bigger than it is (`1999` → `"1.9K"`).
- Suffixes run K, M, B, T, Qa, Qi, Sx, Sp, Oc, No, Dc.
- Numbers below 100 keep one decimal.
- Non-numbers and NaN format as `"0"`.

## 2. Depends on

Nothing.

## 3. Install

| File | Destination |
| --- | --- |
| `shared/NumberFormat.lua` | `src/shared/NumberFormat.lua` |
| `tests/NumberFormat.spec.lua` | `tests/NumberFormat.spec.lua` |

- **Config:** set `NumberFormat.CURRENCY` at the top of the copied file (default `"$"`). Use `""` for a currency without a symbol.
- **Saved fields:** none.

## 4. Remotes

None.

## 5. Verify in Studio (MCP)

1. In Edit, set `ReplicatedStorage.Tests:SetAttribute("RunTests", true)`.
2. Start Play (`start_stop_play`) and read `get_console_output`. Expect the `NumberFormat` spec to report 0 failures.
3. Optionally run `execute_luau` (Server): `return require(game.ReplicatedStorage.NumberFormat).Money(2500000)`. Expect `"$2.5M"`.

## 6. Origin

Extracted from the reference game's `src/shared/NumberFormat.lua` and `tests/NumberFormat.spec.lua`. Changes:
- The `$` became `NumberFormat.CURRENCY`.
- Sp, Oc, No and Dc suffixes were added.
- NaN is guarded.
- The spec gained negative and NaN/non-number cases.
