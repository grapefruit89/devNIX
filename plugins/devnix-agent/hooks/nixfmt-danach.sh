#!/usr/bin/env bash
# PostToolUse / Write|Edit — formatiert geschriebene .nix-Dateien sofort.
#
# Damit kann keine unformatierte Nix-Datei mehr liegenbleiben, unabhaengig
# davon, ob der Agent daran denkt. Das ist der Unterschied zu einer Zeile in
# CLAUDE.md, die man ueberlesen kann.
#
# nixfmt, NICHT nixfmt-rfc-style: letzteres ist seit 2025-07-14 nur ein Alias
# ("should be used instead", pkgs/top-level/aliases.nix). nixpkgs' eigene CI
# benutzt nixfmt (ci/treefmt.nix).
set -uo pipefail

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

case "$FILE" in
  *.nix) ;;
  *) exit 0 ;;
esac
[ -f "$FILE" ] || exit 0

if command -v nixfmt >/dev/null 2>&1; then
  nixfmt "$FILE" 2>/dev/null
else
  nix run nixpkgs#nixfmt -- "$FILE" 2>/dev/null
fi

# Immer 0: Formatierung ist Komfort, kein Grund die Arbeit abzubrechen.
exit 0
