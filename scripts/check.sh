#!/usr/bin/env bash
# Every check CI runs, for running locally before a commit. Needs stylua, selene and rojo on PATH.
set -euo pipefail

hub="$(cd "$(dirname "$0")/.." && pwd)"
cd "$hub"

fail() {
	echo "check failed: $*" >&2
	exit 1
}

for tool in git stylua selene rojo; do
	command -v "$tool" >/dev/null || fail "$tool is not on PATH (see template/rokit.toml for the pinned versions)"
done

echo "== privacy: no personal paths or emails"
if git grep -nIE '[A-Za-z]:\Users\[A-Za-z]|/(Users|home)/[a-z]' -- .; then
	fail "absolute paths into a user folder; use a placeholder such as %USERPROFILE% or <workspace>"
fi
if git grep -nIhoE '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z.]{2,}' -- . | grep -vE 'noreply|@example\.(com|org)'; then
	fail "email addresses in tracked files"
fi

echo "== privacy: no live ids in system configs (0 = not created)"
if git grep -nE '(^|[^A-Za-z])(id|ID|_ID)[[:space:]]*=[[:space:]]*[1-9]' -- 'systems/*Config.lua'; then
	fail "a system config ships a real id; the hub keeps every id at 0"
fi

echo "== format"
stylua --check template systems

echo "== sandbox (template + every system)"
bash scripts/assemble-sandbox.sh
cd .sandbox

echo "== lint"
selene src tests

echo "== build"
# TestEZ is only needed in Studio; an empty DevPackages folder is enough to build
mkdir -p DevPackages
rojo build -o game.rbxl

echo "all checks passed"
