#!/usr/bin/env bash
# PreToolUse / Bash — blockt, was in AGENTS.md verboten ist.
#
# WARUM ALS HOOK UND NICHT ALS REGEL IN CLAUDE.md:
# CLAUDE.md formt Verhalten, erzwingt es aber nicht ("not a hard enforcement
# layer", Claude-Code-Doku). Ein Hook laeuft unabhaengig davon, was das Modell
# sich gerade denkt. Genau das ist der Unterschied zwischen Erinnerung und Sperre.
#
# EXIT-CODES (verifiziert an der Doku):
#   0  durchlassen
#   2  BLOCKEN, stderr geht als Fehlermeldung an Claude
#   1  waere NICHT blockend -- die Aktion liefe trotzdem. Niemals 1 benutzen.
set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$CMD" ] && exit 0

# Sperren werden mitgeschrieben -- sonst weiss niemand, ob sie je greifen.
# Eine Sperre, die nie ausloest, ist entweder ueberfluessig oder falsch
# formuliert; beides sieht man nur an Zahlen.
SPERRLOG="${XDG_STATE_HOME:-$HOME/.local/state}/devnix/sperren.tsv"
mkdir -p "$(dirname "$SPERRLOG")" 2>/dev/null || true

deny() {
  printf '%s\t%s\n' "$(date -Iseconds)" "$(printf '%s' "$1" | head -1)" \
    >> "$SPERRLOG" 2>/dev/null || true
  echo "$1" >&2
  exit 2
}

# ── Branchless: es gibt genau einen Branch ────────────────────────────────
# Ausdrueckliche Ansage: "ich will branchless arbeiten, das ist zu viel
# Verwirrung fuer mich, deshalb main only!"
if printf '%s' "$CMD" | grep -qE '(^|[;&|] *)git +(checkout +-b|switch +-c|branch +[^-])'; then
  deny "BLOCKIERT: Branch anlegen ist in diesem Projekt verboten (AGENTS.md Regel -1).
Es gibt genau einen Branch: main. Stattdessen:
  Riskant     -> erst Dry-Build, dann committen
  Unfertig    -> nicht committen, im Arbeitsverzeichnis liegen lassen
  Ausprobieren-> Kopie unter /tmp
  Zurueck     -> git revert (neuer Commit auf main)"
fi

# ── Nix-Grok ist stillgelegt ──────────────────────────────────────────────
if printf '%s' "$CMD" | grep -qiE '(Nix-Grok|nix-grok)' \
   && printf '%s' "$CMD" | grep -qE '(git +(push|commit|add)|>|>>|tee|rm |mv |cp .* )'; then
  deny "BLOCKIERT: Schreibzugriff auf Nix-Grok.
Das Repo ist stillgelegt, mediNix ist die Wahrheit. Lesen ist erlaubt."
fi

# ── Die zwei Pfade, die nie geloescht werden ──────────────────────────────
if printf '%s' "$CMD" | grep -qE 'rm +(-[a-zA-Z]+ +)*(/data/media|/etc/nixos)(/|\s|$)'; then
  deny "BLOCKIERT: /data/media und /etc/nixos werden nicht geloescht.
Alles andere auf dieser Maschine darf gewischt werden -- diese beiden nicht."
fi

# ── systemd-run fuer nixos-rebuild: heute real reingefallen ───────────────
if printf '%s' "$CMD" | grep -q 'systemd-run' \
   && printf '%s' "$CMD" | grep -q 'nixos-rebuild'; then
  deny "BLOCKIERT: systemd-run gibt der Unit einen minimalen PATH.
nixos-rebuild scheitert darin mit \"[Errno 2] No such file or directory: 'test'\"
-- und der Switch gilt faelschlich als erfolgreich. Am 2026-07-21 zweimal passiert.

Stattdessen:
  setsid nohup sudo nixos-rebuild switch --flake /etc/nixos#q958 > /tmp/sw.log 2>&1 &"
fi

exit 0
