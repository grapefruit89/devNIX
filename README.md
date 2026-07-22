> ⚖ **Erstes Gebot:** das Nummernschema in [`docs/adr/8000-dezimalrahmen.md`](docs/adr/8000-dezimalrahmen.md) regiert jedes Projekt. Niemals löschen.

# devNIX

Werkzeuge **und** Arbeitsweise für die Nix-Entwicklung, in einem Repo.

Es sind zwei Hälften, und keine kann die andere ersetzen:

| | NixOS-Modul (`800`–`820`) | Plugin (`plugins/devnix-agent`) |
|---|---|---|
| Installiert Binaries | ✅ deklarativ | ❌ kann keine Systempakete |
| Verdrahtet Claude mit MCPs | ❌ weiß nichts von Claude | ✅ `.mcp.json` |
| Erzwingt Verhalten | ❌ | ✅ Hooks |

---


> **Nummernschema:** Die projektübergreifende Konvention (vier Anker, fraktal)
> steht in [`docs/adr/8000-dezimalrahmen.md`](docs/adr/8000-dezimalrahmen.md) — die
> Verfassung, die Nix-Grok, mediNix und devNIX gemeinsam regiert.

## Installieren

**Die Werkzeuge** — in deiner `flake.nix`:

```nix
inputs.devNIX.url = "github:grapefruit89/devNIX";

# im nixosSystem:
modules = [
  devNIX.nixosModules.default
  { devNix.enable = true; }
];
```

**Die Arbeitsweise** — in Claude Code:

```bash
claude plugin marketplace add grapefruit89/devNIX
claude plugin install devnix-agent@devnix
```

Danach `/reload-plugins`.

---

## Was drin ist

### `800-agents` — Agenten und ihre MCP-Server

`claude-code` · `mcp-nixos` · `context7-mcp` · `github-mcp-server`

Als **Systempakete**, nicht per `nix run` bei jedem Aufruf. `nix run` braucht
jedes Mal eine Evaluation und unter Umständen Netzwerk; ein Paket im PATH
startet sofort und funktioniert offline.

`claude-code` ist unfree. Das Modul setzt **kein globales `allowUnfree`**,
sondern gibt genau dieses eine Paket frei — eine globale Freigabe ist eine
Entscheidung, die dem Betreiber gehört.

### `810-nix-tools` — Formatieren, Linten, Nachschlagen

| Werkzeug | Rolle | Beleg |
|---|---|---|
| `nixfmt` 1.4 | Formatierung | nixpkgs' eigene CI benutzt es (`ci/treefmt.nix`) |
| `nixf-diagnose` | Semantik | ebenfalls in `ci/treefmt.nix` |
| `statix` | Stil | Community, **nicht** in der nixpkgs-CI |
| `deadnix` | toter Code | Community, **nicht** in der nixpkgs-CI |
| `noogle-search` | `lib.*` / `builtins.*` nachschlagen | |
| `nixd` | Language-Server, wertet gegen die eigene Konfiguration aus | |

> **Nicht `nixfmt-rfc-style` schreiben.** Seit 2025-07-14 nur noch ein Alias:
> *„is now the same as `pkgs.nixfmt` which should be used instead"*
> (`pkgs/top-level/aliases.nix`). Store-Pfade sind bitgleich.
> `nixfmt-classic` ist entfernt, `nixpkgs-fmt` ist Community mit einem Maintainer.

Bringt den Alias `nixcheck` mit — die vollständige Kette in einem Wort.

### `820-shell` — die Werkzeuge, auf die sich die Anleitungen berufen

`jq` · `gh` · `ripgrep` · `fd` · `bat` · `eza` · `btop` · `dust` · `duf`

Das ist keine Geschmacksliste. Jedes davon wird in einer Anleitung oder einem
Hook namentlich aufgerufen — fehlt eines, bricht die Anleitung still.

**`jq` ist der wichtigste Eintrag:** die Plugin-Hooks lesen ihre Eingabe als
JSON von stdin. Ohne `jq` laufen sie ins Leere und *alle* Sperren sind
wirkungslos, ohne dass es auffällt.

### `plugins/devnix-agent` — die Arbeitsweise

Vier Skills, ein Prüf-Subagent, vier Hooks. Details in
[`plugins/devnix-agent/README.md`](plugins/devnix-agent/README.md).

Der Kern sind die **Hooks**. Anweisungen in `CLAUDE.md` formen Verhalten, sind
aber keine Durchsetzungsebene — ein Hook läuft als Shell-Befehl an einem festen
Punkt im Ablauf, unabhängig davon, wozu das Modell sich gerade entscheidet.

Das ist der Unterschied zwischen **Erinnerung** und **Sperre**, und damit
zwischen einem Projekt, das zurückfällt, und einem, das nur nach oben geht.

---

## Nummernschema

```
800  agents      Agenten und ihre MCP-Server
810  nix-tools   Formatierung, Linting, Nachschlagen
820  shell       Kommandozeilenwerkzeuge
```

`X0` ist Block-ID, `X1`–`X9` wären einzelne Dienste. Ordner mit dreistelliger
Nummer werden **automatisch** eingebunden — ein neuer Block ist ein neuer
Ordner, kein Eintrag in einer Liste.

Das ist gefahrlos, weil das NixOS-Modulsystem **reihenfolgeunabhängig** ist:
bei gleicher Priorität gibt es einen Konflikt, kein „letzter gewinnt".
Empirisch geprüft, nicht angenommen.

---

## Herkunft

Verdichtet aus drei Quellen und der Erfahrung an einem realen NixOS-Server:

- **[Karpathys Leitlinien](https://github.com/multica-ai/andrej-karpathy-skills)** —
  prüfbare Ziele statt vager Aufträge, chirurgische Änderungen, Verwirrung nicht
  verstecken
- **[Cloudflares `agent-setup/prompt.md`](https://developers.cloudflare.com/agent-setup/prompt.md)** —
  Bootstrap unter stabiler URL, Handlungspflicht statt Vorschlag, benannte
  Anti-Muster, definierter Abschlusszustand
- **Die Claude-Code-Doku** zu Hooks, Skills, Plugins und Speicher
- **`LEARNINGS.md` aus [mediNix](https://github.com/grapefruit89/mediNix)** —
  sieben Fehler, die echte Zeit gekostet haben

## Lizenz

MIT
