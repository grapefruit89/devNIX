---
description: Wandelt einen erreichten Zustand in einen automatischen Test um, der fehlschlaegt, sobald man dahinter zurueckfaellt. Nutzen, wenn etwas repariert wurde und als erledigt gelten soll, oder wenn immer wieder derselbe Stand von Hand nachgeprueft wird.
---

# Ratsche

## Das Problem, gegen das dieser Skill existiert

> *„Ich drehe mich in der ersten Etage im Kreis, anstatt dass ich die Treppe nach
> oben finde. Und wenn ich diese finde, dann gehts 5 Stufen nach oben und dann
> wieder in den Keller."*

Ursache ist nicht mangelnde Disziplin. **Dokumentation ist Erinnerung, keine
Sperre.** Sie erklaert hinterher, was schiefging — sie verhindert es nicht. Ein
Stand, der nur in einer Markdown-Datei steht, geht still verloren.

## Die Regel

> **Ein Schritt gilt erst als gemacht, wenn ein automatischer Test fehlschlaegt,
> sobald man dahinter zurueckfaellt.**

Vor jeder Erledigt-Meldung:

```
Was bricht, wenn das hier morgen kaputtgeht?
  -> "nichts" ist die falsche Antwort. Dann ist es nicht erledigt.
```

## Aufgabe in prueffbares Ziel uebersetzen — VOR dem Umsetzen

| Aufgabe | Prueffbares Ziel |
|---|---|
| „Fix den Bug" | Test schreiben, der ihn reproduziert -> dann gruen machen |
| „Haerte den Dienst" | Dienst startet **und** die verbotene Syscall-Klasse ist blockiert |
| „Refactoring" | Store-Pfad vor und nach der Aenderung bitgleich |
| „Mach es aufgeraeumter" | Kein Ziel. Nachfragen, was konkret stoert |

Bei mehreren Schritten den Plan vorher hinschreiben, jeder Schritt mit Pruefung:

```
1. Seeds erst nach Erststart      -> verify: frischer Start, 0 Restarts
2. Marker auf data/jellyfin.db    -> verify: zweiter Start, Port = 5410
3. Downgrade entfernen            -> verify: Version 10.11.11, immer noch gruen
```

## Das Werkzeug: nixosTest

Eine VM, die hochfaehrt und die Behauptungen prueft:

```nix
pkgs.nixosTest {
  name = "medinix-dienste";
  nodes.machine = { ... }: {
    imports = [ ./. ];
    grapefruitMedia.enable = true;
  };
  testScript = ''
    machine.wait_for_unit("jellyfin.service")
    machine.succeed("test $(systemctl show jellyfin -p NRestarts --value) -eq 0")
    machine.wait_for_open_port(5410)          # Registry-Port, nicht 8096
    machine.succeed("curl -sf http://localhost:5410 -o /dev/null")
  '';
}
```

Jede dieser vier Zeilen entspricht einem Fehler, der real passiert ist und
manuell wiedergefunden werden musste.

## Die zweite Ursache: zu viele halbe Fronten

Fuenf Stufen hoch in einer Front fuehlen sich wie Rueckschritt an, wenn vier
andere offen stehen. **Hoechstens eine Sache gleichzeitig im Zustand
„angefangen".** Faengt der Mensch mitten in einer Front etwas Neues an, ist es
deine Aufgabe, das auszusprechen:

> „Wir haben X noch offen (konkret: …). Soll ich das erst zumachen, oder legen
> wir es bewusst beiseite?"

Nicht widersprechen — sichtbar machen. Die Entscheidung trifft der Mensch.

## Diese Regel wirkt, wenn

- Nach jeder Sitzung **mehr Tests** existieren als davor
- Kein erreichter Stand zweimal erarbeitet werden muss
- Rueckfragen **vor** der Umsetzung kommen, nicht nach dem Fehlschlag
