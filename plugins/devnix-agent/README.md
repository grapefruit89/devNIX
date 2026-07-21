# devnix-agent

Ein Claude-Code-Plugin fuer die Arbeit an Nix-Projekten. Es buendelt die
Nix-MCPs, vier Skills und — der eigentliche Punkt — **Hooks, die harte Grenzen
erzwingen statt sie zu erbitten**.

## Warum Hooks

Anweisungen in `CLAUDE.md` formen Verhalten, sind aber keine Durchsetzungsebene.
Ein Hook laeuft als Shell-Befehl an einem festen Punkt im Ablauf, unabhaengig
davon, wozu das Modell sich gerade entscheidet.

Das ist der Unterschied zwischen **Erinnerung** und **Sperre** — und damit
zwischen einem Projekt, das zurueckfaellt, und einem, das nur nach oben geht.

## Inhalt

```
.mcp.json     nixos (inkl. Noogle) · context7 · github
skills/       lage · nix-recherche · aendern · ratsche
agents/       verifizierer
hooks/        auto-nixfmt + vier Sperren
setup.md      Bootstrap-Anweisung fuer einen frischen Agenten
```

## Die Sperren

| Was | Warum |
|---|---|
| `git checkout -b`, `git switch -c` | Ein Branch: `main`. Mehrere erzeugen Verwirrung, die teurer ist als ihr Nutzen |
| Schreiben in `Nix-Grok` | Stillgelegtes Repo, soll nicht weiter kaputtgehen |
| `rm` auf `/data/media`, `/etc/nixos` | Die einzigen zwei Pfade, die nicht Wegwerf sind |
| `systemd-run` + `nixos-rebuild` | Minimaler PATH -> `[Errno 2] ... 'test'`, und der Switch gilt faelschlich als erfolgreich |

## Herkunft

Die Skills verdichten drei Quellen und die Erfahrung aus einem realen NixOS-Server:

- **Karpathys Leitlinien** — prueffbare Ziele statt vager Auftraege, chirurgische
  Aenderungen, Verwirrung nicht verstecken
- **Cloudflares `agent-setup/prompt.md`** — Bootstrap unter stabiler URL,
  Handlungspflicht statt Vorschlag, benannte Anti-Muster, definierter Abschluss
- **Die Claude-Code-Doku** zu Hooks, Skills und Plugins
- **`LEARNINGS.md` aus mediNix** — sieben Fehler, die echte Zeit gekostet haben

## Installieren

Siehe `setup.md`. Kurzform:

```
claude plugin marketplace add grapefruit89/devNIX
claude plugin install devnix-agent@devnix
```

Braucht `jq` und `nix` im PATH.
