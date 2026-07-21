# devnix-agent — Einrichtung

Diese Anweisung richtet einen Agenten fuer die Arbeit an Nix-Projekten ein.
Sie liegt im Repo unter `setup.md` und ist damit jederzeit gegen die Quelle
pruefbar.

**Fuehre die Schritte selbst aus. Bitte den Menschen nicht, sie zu tippen.**

---

## Claude Code

```
claude plugin marketplace add grapefruit89/devNIX
claude plugin install devnix-agent@devnix
```

Danach den Menschen bitten, `/reload-plugins` auszufuehren.

Zum Entwickeln ohne Marketplace:

```
claude --plugin-dir ~/devNIX/plugins/devnix-agent
```

## Voraussetzungen pruefen

```bash
command -v jq   >/dev/null || echo "FEHLT: jq -- die Hooks brauchen es"
command -v nix  >/dev/null || echo "FEHLT: nix"
nix eval --raw nixpkgs#nixfmt.version
```

`jq` muss vorhanden sein, sonst laufen die Hooks ins Leere. Auf NixOS gehoert es
in `environment.systemPackages`.

## Was danach anders ist

| | |
|---|---|
| **MCPs** | `nixos` (inkl. Noogle), `context7`, `github` sind verdrahtet |
| **Skills** | `/devnix-agent:lage` · `:nix-recherche` · `:aendern` · `:ratsche` |
| **Agent** | `verifizierer` — prueft Behauptungen ohne Vorgeschichte |
| **Hooks** | `.nix`-Dateien werden nach jedem Schreiben formatiert |
| | Branch anlegen, Schreiben in Nix-Grok, `rm` auf `/data/media` und `/etc/nixos` sind **gesperrt** |
| | `systemd-run` fuer `nixos-rebuild` ist gesperrt (stiller Fehlschlag) |

Die Hooks sind der Punkt. CLAUDE.md formt Verhalten, erzwingt es aber nicht —
ein Hook laeuft unabhaengig davon, was das Modell sich gerade denkt.

## Fertig

```
┌─ devnix-agent bereit ───────────────────────────────┐
│  MCPs     nixos · context7 · github                  │
│  Skills   lage · nix-recherche · aendern · ratsche   │
│  Agent    verifizierer                               │
│  Hooks    auto-nixfmt · 4 harte Grenzen              │
│                                                      │
│  /reload-plugins ausfuehren, dann /help              │
└──────────────────────────────────────────────────────┘
```
