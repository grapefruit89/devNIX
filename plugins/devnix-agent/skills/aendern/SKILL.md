---
description: Der Arbeitsablauf fuer jede Aenderung an Nix-Code — committen vor den Werkzeugen, Werkzeuge laufen lassen, erneut committen, Diff pruefen, erst dann push. Nutzen bei jeder Code-Aenderung, vor jedem Commit und vor jedem Push.
---

# Aendern und nachweisen

## Die Reihenfolge, und warum sie so ist

```bash
# 1. committen, BEVOR die Werkzeuge laufen
git add -A && git commit -m "..."

# 2. Werkzeuge
NIXFILES=$(find . -name '*.nix' -not -path './.git/*')
nix run nixpkgs#nixfmt -- $NIXFILES
nix run nixpkgs#nixf-diagnose -- --ignore=sema-unused-def-lambda-noarg-formal $NIXFILES
nix run nixpkgs#statix -- check .
nix run nixpkgs#deadnix -- --fail .

# 3. committen, WAS die Werkzeuge geaendert haben
git add -A && git commit -m "nixfmt/nixf-diagnose/statix/deadnix"

# 4. Diff pruefen -- der eigentliche Zweck der Trennung
git show --stat HEAD && git show HEAD

# 5. push NUR nach ausdruecklicher Zustimmung im Chat
```

Die Trennung stammt vom Repo-Eigentuemer und hat sich sofort bewaehrt:
`deadnix --edit` machte aus `{ lib }:` ein `{ }:` und zerlegte alle Aufrufer.
In einem gemeinsamen Commit waere das im Rauschen untergegangen.

**`nixfmt`, nicht `nixfmt-rfc-style`** — letzteres ist seit 2025-07-14 nur noch
ein Alias mit Warnung. `nixfmt-classic` ist entfernt, `nixpkgs-fmt` ist Community
und nicht das, was nixpkgs selbst fahrt.

## Chirurgisch bleiben

> Jede geaenderte Zeile muss sich direkt auf die Aufgabe zurueckfuehren lassen.

- Angrenzenden Code nicht „verbessern", nicht umformatieren, nicht refaktorieren
- Bestehenden Stil uebernehmen, auch wenn du es anders machen wuerdest
- Toten Code, den du findest, **erwaehnen** — nicht loeschen
- Nur aufraeumen, was **deine** Aenderung verwaist hat

## Der Nachweis gehoert dazu

Eine Aenderung ist nicht fertig, wenn sie gebaut hat, sondern wenn du zeigen
kannst, dass sie das Behauptete tut:

| Behauptung | Nachweis |
|---|---|
| „rein kosmetisch" | Store-Pfad vorher/nachher — bitgleich |
| „diese Zeile war die Ursache" | Zeile entfernen, Fehler muss zurueckkommen |
| „der Dienst ist erreichbar" | `curl` von aussen, nicht `127.0.0.1` |
| „der Dienst laeuft" | `is-active` **und** `NRestarts` **und** der Port |

```bash
nix eval .#nixosConfigurations.check.config.system.build.toplevel.drvPath
```

Gleicher Pfad = kein Verhalten geaendert. Das ist ein Beweis, keine Behauptung.
