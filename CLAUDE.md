# CLAUDE.md — devNIX

> ## ⚖ ERSTES GEBOT — der Dezimalrahmen
> Vier feste Anker regieren Ordner und Nummern **jedes** Projekts, auf jeder Ebene:
> **`_0` Fundament · `_1` Zugang · `_2` Sicherheit · `_9` Leitplanken** — dazwischen
> (`_3`–`_8`) die freie, projekteigene Mitte. Port = Nummer × 10, UID = Projekt×1000+Rest, GID = Projekt×1000.
> **Volle Autorität und Begründung: `devNIX/docs/adr/8000-dezimalrahmen.md`.**
> Geht das verloren, verliert das Projekt die Orientierung. Niemals löschen.

> ## ⚠ Die Verfassung des Nummernschemas
> `docs/adr/8000-dezimalrahmen.md` regiert das Ordner- und Nummernschema **jedes**
> Projekts (Nix-Grok, mediNix, devNIX, künftige). Vier feste Anker — `_0` Fundament,
> `_1` Zugang, `_2` Sicherheit, `_9` Leitplanken —, freie Mitte `_3`–`_8`.
> **Niemals löschen.** Bei jeder Struktur-Frage zuerst dort nachsehen.

Werkzeugsammlung als NixOS-Modul, plus das Plugin, das die Arbeitsweise erzwingt.
Dieses Repo beschreibt **wie gearbeitet wird**. Es ist damit die einzige Stelle,
an der ein Fehler sich auf alle anderen Projekte überträgt — entsprechend
vorsichtig.


## Struktur nach ADR-8000 (Dezimalrahmen)

devNIX folgt seiner eigenen Verfassung — vier Anker, freie Mitte:

```
800  Fundament    flake.nix, default.nix, CLAUDE.md, docs/, README   (_0, Wissen, kein Ordner)
810  Zugang       — leer, reserviert (devNIX hat keinen Ingress)      (_1)
820  Sicherheit   — leer, reserviert (age/sops erst bei Bedarf)       (_2)
830  agents       claude-code · mcp-nixos · context7-mcp · github     Domäne
840  nix-tools    nixfmt · nixf-diagnose · statix · deadnix · noogle · shellcheck · shfmt · nixd · nixoscope · treefmt
850  deps         nix-tree · nix-diff · nix-du                        Domäne
860  build        nix-output-monitor · comma · nh                     Domäne
870  shell        jq · gh · rg · fd · bat · eza · btop · dust · duf   Domäne
890  Leitplanken  plugins/devnix-agent — die Hooks setzen durch       (_9)
```

`800` (Fundament) und `810`/`820` (Zugang/Sicherheit) sind **keine Ordner** —
Fundament ist die Wurzel (Wissen), die anderen leer und reserviert. Ein leerer
Anker ist kein Fehler (ADR-8000). Das Plugin unter `plugins/` ist konzeptionell
`_9` Leitplanken; es bleibt bei `plugins/`, weil der Marketplace diesen Pfad
erwartet.

## Du führst aus

Du läufst auf einer Maschine mit Nix. Prüfe selbst, statt Prüfungen
vorzuschlagen. Ausnahmen: `git push` nur nach Zustimmung im Chat, und Schreiben
im stillgelegten Repo `Nix-Grok` ist verboten.

## Kein Paketname ohne Prüfung

Dieses Repo besteht fast nur aus Paketnamen. Ein falscher Name bricht die
Konfiguration jedes Nutzers.

```bash
nix eval --raw nixpkgs#NAME.version
nix search nixpkgs NAME
```

**Vor jedem Commit**, der ein Paket hinzufügt oder umbenennt. „Ich weiß, dass es
das gibt" ist kein Grund — `nixfmt-rfc-style` gab es auch, und war seit einem
Jahr nur noch ein Alias mit Warnung.

## Änderungen prüfen

```bash
nix flake lock
nix eval .#nixosConfigurations.check.config.environment.systemPackages \
  --apply builtins.length
nixcheck   # nixfmt · nixf-diagnose · statix · deadnix
```

Die Prüfkonfiguration `check` evaluiert das Modul ohne Hardware. Sie muss nach
jeder Änderung durchlaufen.

## Neuen Werkzeugblock anlegen

Ein Ordner `NNN-name/` mit `default.nix`, dreistellige Nummer. Er wird
**automatisch** eingebunden — kein Eintrag in einer Liste, keine Import-Zeile.

Jeder Block braucht:

```nix
options.devNix.<name>.enable = lib.mkOption {
  type = lib.types.bool;
  default = config.devNix.enable;    # folgt dem Sammelschalter
  ...
};
```

Damit lässt sich alles gemeinsam einschalten und einzeln wieder abschalten.

## Grenzen dieses Moduls

| Erlaubt | Verboten |
|---|---|
| Pakete installieren | globales `nixpkgs.config.allowUnfree` setzen |
| Aliase als `mkDefault` | Aliase als `mkForce` |
| Eigene Optionen prüfen | die Umgebung des Betreibers beurteilen |
| Werkzeuge anbieten | Dienste starten, Ports belegen, Firewall ändern |

devNIX ist eine **Werkzeugkiste**, kein Betriebssystem-Umbau. Wer es importiert,
soll danach mehr Befehle haben — nicht ein anderes System.

Unfree-Pakete werden einzeln per `allowUnfreePredicate` freigegeben. Eine
globale Freigabe ist eine Entscheidung, die dem Betreiber gehört.

## Das Plugin unter `plugins/devnix-agent`

Ändert man dort etwas, gilt zusätzlich:

- **Hooks müssen mit `exit 2` blocken.** `exit 1` ist *nicht* blockend — die
  Aktion läuft trotzdem, obwohl 1 der übliche Unix-Fehlercode ist. Ein Hook mit
  `exit 1` sieht aus wie eine Sperre und ist keine.
- Hooks brauchen `jq`. Fehlt es, laufen sie still ins Leere.
- Nach jeder Hook-Änderung von Hand testen:

```bash
echo '{"tool_input":{"command":"git checkout -b x"}}' | ./hooks/grenzen-bash.sh
echo "exit=$?"   # muss 2 sein
echo '{"tool_input":{"command":"git status"}}' | ./hooks/grenzen-bash.sh
echo "exit=$?"   # muss 0 sein
```

Beide Richtungen prüfen. Ein Hook, der alles blockt, ist genauso kaputt wie
einer, der nichts blockt — nur fällt Ersteres schneller auf.

```bash
claude plugin validate plugins/devnix-agent
```
