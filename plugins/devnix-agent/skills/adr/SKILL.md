---
description: Legt ein ADR im Format dieses Repos an oder prüft eine Entscheidung. Nutzen, wenn eine Architekturentscheidung ansteht, wenn gefragt wird warum etwas so gebaut ist, oder wenn eine getroffene Entscheidung sich als falsch erweist.
argument-hint: "<Entscheidung oder System>"
---

# ADR anlegen

Erzeugt ein ADR, das **in dieses Repo passt** — nicht daneben.

> Der generische `/engineering:architecture` erzeugt ein anderes Format:
> englische Überschriften, ein Feld `Deciders`, und **kein `error_pattern`**.
> Ein so erzeugtes ADR ist über das Runbook nicht auffindbar. Diesen Befehl
> hier benutzen, nicht jenen.

---

## Vorher — nicht überspringen

**Gibt es die Entscheidung schon?** ADRs widersprechen sich sonst still.

```bash
ls docs/adr/
grep -rl "<stichwort>" docs/adr/
```

Findest du ein bestehendes ADR zum Thema: **nicht** ein zweites anlegen.
Entweder ergänzen, oder das alte auf `superseded` setzen und im neuen
begründen, warum.

**Nummer wählen.** Sie folgt dem Modulblock, zu dem die Entscheidung gehört:

| Bereich | Nummernkreis | Beispiel |
|---|---|---|
| Ingress, Caddy, mDNS | 5000–5009 | |
| *arr, Download | 5010–5029 | |
| Provisionierung | 5030–5039 | 5035, 5036, 5037 |
| Übergreifend (Härtung, Isomorphie) | 5040–5049 | 5040, 5042 |

Die nächste freie Nummer im passenden Kreis, keine Lücken lassen.

---

## Das Format — verbindlich

```markdown
# ---
# id: 5043
# title: "Kurzer Satz, der die Entscheidung nennt"
# status: "accepted"
# note: "Entwurf, noch nicht gebaut"
# date: "2026-07-21"
# related: [5040, 5042]
# tags: ["registry", "ports", "ssot"]
# error_pattern: "registry|isomorph|port.*ableit"
# ---

# ADR-5043 — Kurztitel

## Kontext

[Welche Lage, welche Kräfte? Was tut weh?]

## Entscheidung

[Was ändert sich? Ein Satz, dann die Begründung.]

## Abgelehnt

| Vorschlag | Grund |
|---|---|
| [Alternative] | [warum nicht] |

## Konsequenzen

- [Was wird leichter]
- [Was wird schwerer]
- [Was später nochmal angesehen werden muss]

## Nachweis

[Womit belegt? Store-Pfad-Vergleich, Gegentest, Messung auf q958.]
```

### Die Felder im Einzelnen

| Feld | Pflicht | Bedeutung |
|---|---|---|
| `id` | ja | gleich der Dateinummer |
| `title` | ja | vollständiger Satz, nicht nur Schlagwort |
| `status` | ja | `accepted` · `superseded` · `rejected` |
| `note` | nein | Vorbehalt, den `status` nicht ausdrückt („Entwurf, noch nicht gebaut") |
| `date` | ja | ISO |
| `related` | ja | Nummern verwandter ADRs, leer als `[]` |
| `tags` | ja | Kleinbuchstaben, für Themensuche |
| `error_pattern` | **ja** | **regex**, siehe unten |

### `error_pattern` — der Teil, der am häufigsten schlecht gemacht wird

Ein Agent nimmt eine Fehlerzeile aus `journalctl` und matcht sie dagegen, um
das passende ADR zu finden. Das Muster gehört also auf **Begriffe, die im
Fehlerfall auf dem Bildschirm stehen** — nicht auf die schöne Überschrift.

| schlecht | gut | warum |
|---|---|---|
| `"architektur"` | `"registry\|isomorph\|port.*ableit"` | steht nie in einem Fehler |
| `"haertung"` | `"SystemCallFilter\|226/NAMESPACE\|SIGSYS"` | so sieht der Fehler wirklich aus |
| `".*"` | — | matcht alles, also nichts |

Prüfen, bevor du es einträgst:

```bash
grep -riE "<dein_pattern>" docs/ *.md | head
```

Trifft es nichts oder alles, taugt es nicht.

---

## Inhaltliche Regeln

**Ein ADR hält fest WARUM, nicht WAS.** Das Was steht im Code. Ein ADR, das nur
den Code nacherzählt, ist wertlos.

**Der Abschnitt „Abgelehnt" ist der wertvollste.** Er verhindert, dass in sechs
Monaten jemand denselben verworfenen Weg noch einmal vorschlägt. Mindestens eine
echte Alternative, mit echtem Grund — nicht „war schlechter".

**Widerlegtes bleibt stehen.** Erweist sich eine Entscheidung als falsch, wird
das ADR **nicht gelöscht**: `status: "superseded"`, und der Grund kommt dazu.
Ein gelöschtes ADR lädt ein, denselben Fehler nochmal zu machen.

Beispiel aus diesem Repo: die Annahme, Nix-Imports seien reihenfolgeabhängig,
stand in einem Brainstorm. Empirisch widerlegt — beide Reihenfolgen ergaben
denselben Konflikt. Das steht heute **als Widerlegung** in ADR-5042 und schützt
den nächsten Leser.

**Der Abschnitt „Nachweis" trennt Entscheidung von Meinung.** Was belegt, dass
es funktioniert? Store-Pfad-Vergleich, Gegentest, eine Messung auf q958. Steht
dort nichts Prüfbares, ist es ein Vorschlag, kein ADR.

---

## Danach

```bash
grep -c "error_pattern" docs/adr/*.md    # jedes ADR muss 1 haben
```

Und im Wegweiser eintragen, falls die Entscheidung eine Wahrheitsquelle
verschiebt: `AGENTS.md`, `docs/ARCHITEKTUR.md` Abschnitt 7.

Ein ADR, das eine SSoT ändert, ohne dass die Wegweiser mitgezogen werden,
erzeugt genau den Widerspruch, den es beseitigen sollte — am 2026-07-21 real
passiert: `AGENTS.md` zeigte noch auf ein überholtes Dokument, während die
Registry längst entschieden hatte.
