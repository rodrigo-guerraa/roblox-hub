#!/usr/bin/env bash
# Installs Linux builds of the tools pinned in template/rokit.toml, for CI. Locally, use `rokit install`.
set -euo pipefail

hub="$(cd "$(dirname "$0")/.." && pwd)"
bin="${1:?usage: install-tools.sh <bin-dir>}"
mkdir -p "$bin"

version() {
	sed -n "s/^$1 = \".*@\(.*\)\"/\1/p" "$hub/template/rokit.toml"
}

fetch() {
	local tmp
	tmp="$(mktemp -d)"
	curl -sSLf -o "$tmp/tool.zip" "$1"
	unzip -q -o "$tmp/tool.zip" -d "$bin"
	rm -rf "$tmp"
}

stylua="$(version stylua)"
selene="$(version selene)"
rojo="$(version rojo)"

fetch "https://github.com/JohnnyMorganz/StyLua/releases/download/v$stylua/stylua-linux-x86_64.zip"
fetch "https://github.com/Kampfkarren/selene/releases/download/$selene/selene-$selene-linux.zip"
fetch "https://github.com/rojo-rbx/rojo/releases/download/v$rojo/rojo-$rojo-linux-x86_64.zip"
chmod +x "$bin/stylua" "$bin/selene" "$bin/rojo"
echo "installed stylua $stylua, selene $selene, rojo $rojo into $bin"
