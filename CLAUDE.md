# CLAUDE.md — devNIX

Werkzeugsammlung als NixOS-Modul, plus das Plugin, das die Arbeitsweise erzwingt.
Dieses Repo beschreibt **wie gearbeitet wird**. Es ist damit die einzige Stelle,
an der ein Fehler sich auf alle anderen Projekte überträgt — entsprechend
vorsichtig.

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
