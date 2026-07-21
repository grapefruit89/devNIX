#!/usr/bin/env bash
# PreToolUse / Write|Edit — verhindert Schreiben im stillgelegten Repo.
set -uo pipefail

INPUT=$(cat)
FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE" ] && exit 0

case "$FILE" in
  *[Nn]ix-[Gg]rok*)
    SPERRLOG="${XDG_STATE_HOME:-$HOME/.local/state}/devnix/sperren.tsv"
    mkdir -p "$(dirname "$SPERRLOG")" 2>/dev/null || true
    printf '%s\t%s\n' "$(date -Iseconds)" "Schreiben in Nix-Grok: $FILE" \
      >> "$SPERRLOG" 2>/dev/null || true
    echo "BLOCKIERT: $FILE liegt in Nix-Grok.
Das Repo ist stillgelegt -- besonders modules/50-media darf nicht weiter
kaputtgehen. mediNix ist die Wahrheit. Lesen ist erlaubt, Schreiben nicht." >&2
    exit 2 ;;
esac
exit 0
