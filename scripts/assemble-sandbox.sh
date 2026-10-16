#!/usr/bin/env bash
# Builds .sandbox/: the template with every system copied in, the way a game adopts them.
# CI lints, format-checks and builds it; it can also be served with Rojo to try the systems in Studio.
set -euo pipefail

hub="$(cd "$(dirname "$0")/.." && pwd)"
out="$hub/.sandbox"

rm -rf "$out"
cp -r "$hub/template" "$out"

collisions=0
for system in "$hub"/systems/*/*/; do
	for part in server client shared tests; do
		[ -d "$system$part" ] || continue
		case "$part" in
			tests) dest="$out/tests" ;;
			*) dest="$out/src/$part" ;;
		esac
		for file in "$system$part"/*; do
			name="$(basename "$file")"
			if [ -e "$dest/$name" ]; then
				echo "collision: $dest/$name (from ${system#"$hub"/})" >&2
				collisions=1
			fi
			cp -r "$file" "$dest/$name"
		done
	done
done

[ "$collisions" -eq 0 ] || exit 1
echo "assembled $(find "$out/src" "$out/tests" -name '*.lua' | wc -l) Lua files into .sandbox/"
