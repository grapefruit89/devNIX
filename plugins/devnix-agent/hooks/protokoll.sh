#!/usr/bin/env bash
# PostToolUse / alle Werkzeuge — schreibt eine Zeile pro Aufruf.
#
# WOZU
# Nicht Neugier, sondern Nachweis. Die Frage ist nicht "wurde recherchiert",
# sondern das VERHAELTNIS: wie viele .nix-Dateien wurden geschrieben, ohne dass
# vorher irgendetwas nachgeschlagen wurde. Genau dieses Muster fuehrt zu
# Behauptungen aus dem Gedaechtnis -- und damit zu Arbeit, die spaeter
# zurueckgedreht werden muss.
#
# Das Protokoll ist eine Strichliste ueber Sitzungen hinweg. Ein einzelner
# Lauf sagt nichts; zehn Laeufe zeigen, ob die Werkzeuge wirklich benutzt
# werden oder nur in der Anleitung stehen.
#
# LEISTUNG
# Laeuft nach JEDEM Werkzeugaufruf. Deshalb: ein jq-Aufruf, ein append, Ende.
# Kein Netzwerk, keine Schleife, kein Unterprozess mehr als noetig.
#
# Faellt hier etwas aus, wird geschwiegen und 0 zurueckgegeben. Ein kaputtes
# Protokoll darf niemals die Arbeit blockieren.
set -uo pipefail

LOGDIR="${XDG_STATE_HOME:-$HOME/.local/state}/devnix"
LOG="$LOGDIR/protokoll.tsv"
mkdir -p "$LOGDIR" 2>/dev/null || exit 0

INPUT=$(cat 2>/dev/null) || exit 0
[ -z "$INPUT" ] && exit 0

read -r TOOL DETAIL <<<"$(
  printf '%s' "$INPUT" | jq -r '
    [ (.tool_name // "?"),
      ((.tool_input.command // .tool_input.file_path // "") | gsub("\\s+"; " ") | .[0:200])
    ] | @tsv' 2>/dev/null | tr '\t' ' '
)" || exit 0
[ -z "${TOOL:-}" ] && exit 0
DETAIL="${DETAIL:-}"

# ── Einordnen ─────────────────────────────────────────────────────────────
# Die Kategorien entsprechen den Arbeitsschritten aus AGENTS.md. Was sich
# nicht einordnen laesst, wird "sonstiges" -- lieber ungenau als erfunden.
kat="sonstiges"
case "$TOOL" in
  mcp__nixos__*|mcp__*noogle*)          kat="recherche" ;;
  mcp__*context7*|mcp__*Context7*)      kat="recherche" ;;
  mcp__*github*)                        kat="recherche" ;;
  Write|Edit|NotebookEdit)
      case "$DETAIL" in
        *.nix) kat="schreiben-nix" ;;
        *)     kat="schreiben" ;;
      esac ;;
  Bash)
      case "$DETAIL" in
        *"nix eval"*|*"nix search"*|*"nix build"*|*"nix why-depends"*|*noogle*)
            kat="recherche" ;;
        *nixfmt*|*nixf-diagnose*|*statix*|*deadnix*|*nixcheck*)
            kat="lint" ;;
        *"NRestarts"*|*"ss -tlnp"*|*"curl "*|*"systemctl is-active"*|*"drvPath"*)
            kat="nachweis" ;;
        *"git commit"*)  kat="git-commit" ;;
        *"git push"*)    kat="git-push" ;;
        *"nixos-rebuild"*) kat="rebuild" ;;
        *) kat="shell" ;;
      esac ;;
  Read|Grep|Glob)                       kat="lesen" ;;
  Skill)                                kat="skill" ;;
esac

printf '%s\t%s\t%s\t%s\n' \
  "$(date -Iseconds)" "$kat" "$TOOL" "${DETAIL:0:160}" >> "$LOG" 2>/dev/null

# Deckel: aelteste Zeilen fallen raus, damit die Datei nicht unbegrenzt waechst.
# 20000 Zeilen sind grob ein halbes Jahr normaler Arbeit.
if [ "$(wc -l < "$LOG" 2>/dev/null || echo 0)" -gt 20000 ]; then
  tail -n 15000 "$LOG" > "$LOG.tmp" 2>/dev/null && mv "$LOG.tmp" "$LOG" 2>/dev/null
fi

exit 0
