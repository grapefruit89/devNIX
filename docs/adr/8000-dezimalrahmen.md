# ---
# id: 8000
# title: "Dezimalrahmen — die Verfassung des Nummernschemas"
# status: "accepted"
# note: "VERFASSUNG — gilt für jedes Projekt, niemals löschen"
# date: "2026-07-21"
# related: [5042, 5043]
# tags: ["dezimalrahmen", "verfassung", "numbering", "isomorphie", "fraktal", "anker", "ableitung"]
# error_pattern: "dezimalrahmen|verfassung|vier anker|nummernschema|_0|_1|_2|_9|fraktal|fundament|leitplanken|graduier|ableitung|port.*10|uid|gid|projekt.*1000|welche nummer|wohin geh"
# ---

> # ⚠ VERFASSUNG — dieses Dokument darf niemals verlorengehen
> **Es regiert das Nummernschema jedes Projekts in diesem Kosmos** — Nix-Grok,
> mediNix, devNIX und alles Künftige. Nicht löschen, nicht ersetzen, nur
> ergänzen. Erweist sich ein Teil als falsch: `status` auf `superseded`, den
> Grund dazuschreiben — aber stehen lassen.
>
> **Verankert in:** `AGENTS.md` + `CLAUDE.md` (mediNix), `CLAUDE.md` + `README`
> (devNIX), Skill `/devnix-agent:struktur`. Wer eines davon anfasst, wird
> hierher geführt.

# ADR-8000 — Der Dezimalrahmen

Ein Nummernschema, das auf **jeder Ebene dasselbe bedeutet** — vom System-Root
bis in einen einzelnen Modulordner. Es ist die einzige Entscheidung, die
**projektübergreifend** gilt: alle anderen ADRs regeln *ein* Projekt, diese die
Grammatik *aller*. Wer sie kennt, findet sich in jedem Repo zurecht, ohne es
gelesen zu haben. **Eine Sprache, überall.**

---

## 1. Fraktal und isomorph

Wiederkehrende Themen tauchen in **jedem** Projekt auf — Medien, Dokumente,
Netzwerk, Agenten. Jedes braucht eine Grundlage, einen Zugang, Sicherheit und
Regeln. Genau diese Themen bekommen **feste Slots**, die überall dasselbe
bedeuten.

Die führende Stelle ist der **Namensraum**, die letzte Stelle die **Rolle**:

```
Ebene 1   /modules/      2-stellig   00 · 10 · 20 · … · 90
Ebene 2   /50-media/     3-stellig   500 · 510 · … · 590
Ebene 3   (bei Bedarf)   4-stellig   5000 · 5010 · …
```

Eine Ebene bleibt **flach** (Dateien), bis sie zu groß wird — dann **graduiert**
sie in eine weitere Stelle. So wurde `50-media` → mediNix (500–590) und
`80-agents` → devNIX (800–890).

---

## 2. Die vier Anker — überall gleich

| Slot | Rolle | Frage | Inhalt |
|---|---|---|---|
| **`_0`** | **Fundament** | Womit arbeiten wir? | `CLAUDE.md`, `default.nix`, `docs/`, `registry` — **Wissen, keine Dienste** |
| **`_1`** | **Zugang** | Wie kommt man rein? | Reverse-Proxy, mDNS, Routing, Auth-Eingang |
| **`_2`** | **Sicherheit** | Wie geschützt? | Firewall, TLS, VPN-Confinement, Auth-Mechanik |
| **`_9`** | **Leitplanken** | Was muss alles einhalten? | Assertions, Verbote, globale Invarianten |

Wer `_2` sieht, weiß Sicherheit — im System-Root (`20`), in mediNix (`520`),
überall. `_0` hält **Wissen, keine Dienst-`.nix`** — die Dienste wohnen in der
Mitte. Ein Projekt **populiert nur die Anker, die es hat**; ein leerer Anker ist
reserviert, kein Fehler.

---

## 3. Die freie Mitte — `_3` bis `_8`

Sechs Slots gehören der Domäne selbst, in logischer Reihenfolge. Hier gibt es
**keine** projektübergreifende Bedeutung: `_5` heißt im System-Root „Medien", in
mediNix „Wiedergabe", anderswo etwas Drittes. Das ist der Ort für das, was ein
Projekt einzigartig macht.

**Innerhalb einer Dekade:** `N0` ist die **Block-ID** (das Fundament der Dekade),
`N1`–`N9` sind **Dienste**. `N0` ist **nie ein Programm** — diese Regel trägt
später den Kollisionsschutz der IDs (Abschnitt 5).

---

## 4. Ableitungen — was aus der Nummer folgt

Die Nummer ist die einzige Wahrheit. Alles Weitere wird aus ihr abgeleitet, und
**alle Größen tragen die Projektziffer vorne** — man liest eine Zahl und weiß
sofort das Projekt.

| Größe | Regel | `sonarr` (532) | Band |
|---|---|---|---|
| **Port** | Nummer × 10 | `5320` | `5xx0` |
| **UID** | Projekt × 1000 + Rest | `5032` | `50xx` |
| **GID** | Projekt × 1000 | `5000` | `5000` |

„Rest" = die zwei Ziffern nach der Projektziffer (Dekade + Dienst): aus `532`
wird `32`. Alles an mediNix ist ein 5-er — Gruppe `5000`, Benutzer `50xx`, Ports
`5xx0`. Bei devNIX `8000` / `80xx` / `8xx0`.

**GID ist pro Projekt, UID pro Dienst.** Die Gruppe ist *geteilt* (alle Dienste
in `5000`, damit Jellyfin Sonarrs Dateien liest), die UID *einzeln* (`5011`,
`5032`, …) für Prozess-Isolation. Dieselbe führende Ziffer, aber **nie dieselbe
Zahl** — eine eigene GID pro Dienst wäre der Docker-PUID/PGID-Fehler
(`Permission denied`).

**Drei Transformationen, weil jeder Zielraum eigene Grenzen hat:** Ports müssen
1024–65535 sein (`× 10` legt jedes Projekt in sein Tausender-Band, nie
privilegiert); UIDs müssen `> 1000` sein (`× 1000 + Rest` liegt sicher darüber);
GIDs sind projektweit geteilt (`× 1000`, oberhalb des System-Automaten 400–999).
Isomorphie heißt **nicht** „alle Zahlen gleich", sondern: *alles aus der einen
Nummer, jede Größe passend transformiert, alle mit derselben führenden Ziffer.*
Das ist **sinnvolle Isomorphie** (ADR-5042).

---

## 5. Warum GID und UID nie kollidieren — durch die Verfassung selbst

Die GID ist `5000`. Kann ein Benutzer je die `5000` bekommen? **Strukturell
nein.** `5000` hieße „Rest = `00`", also Dekade 0, Dienst 0 — der Slot `N00`. Und
`N00` ist nach Abschnitt 3 **niemals ein Programm**, sondern die Block-ID. Kein
Dienst wohnt je auf `X00`, also bekommt kein Benutzer je die `X000`.

Der niedrigste mögliche Rest ist `11` → niedrigste UID `5011`. Die `5000` bleibt
der Gruppe **exklusiv, garantiert durch die Struktur, nicht durch Vorsicht.**
Eine Regel des Rahmens deckt die andere ab.

**Unix-Sockets:** falls je gebraucht, `/run/{projekt}/{nummer}.sock`. Derzeit
unterstützt kein Dienst HTTP-über-Unix-Socket (auf q958 geprüft: die *arr binden
nur TCP). Die Regel steht bereit, wird aber nicht angewandt.

---

## 6. Das System-Root folgt dem Rahmen bereits

Nix-Grok hat das Muster gebaut, bevor es benannt war:

```
00-core          _0  Fundament     ✓ Anker
10-network       _1  Zugang         ✓ Anker
20-security      _2  Sicherheit     ✓ Anker
30-storage       ┐
40-observability │
50-media  → mediNix   _3–_8  Domänen (frei)
60-apps          │
70-home-automation
80-agents → devNIX ┘
90-policy        _9  Leitplanken    ✓ Anker
```

Vier Anker, sechs Domänen. Der Rahmen ist keine Erfindung, sondern die schon
vorhandene Ordnung — nur explizit gemacht.

---

## 7. Beispiel: ein Dokumenten-Projekt (`_4`)

Zur Veranschaulichung, **nicht** als Bauauftrag:

```
40-documents/  → (graduiert zu einem Repo, 4xx)   GID 4000
  400  Fundament    CLAUDE.md, registry, docs      womit arbeiten wir
  410  Zugang       Reverse-Proxy, SSO             wie kommt man rein
  420  Sicherheit   Zugriffsschutz                 wie geschützt
  430  Erfassung    paperless-ngx                  was rein
  440  Ablage       nextcloud, opencloud           wo liegt es
  490  Leitplanken  Assertions                     was einhalten
```

Wer mediNix kennt, liest das ohne Anleitung.

---

## 8. Abgelehnt

| Vorschlag | Grund |
|---|---|
| **Drei Anker** (Sicherheit als Domäne) | Sicherheit kehrt in jedem Projekt wieder → fester Slot wie Fundament/Zugang |
| **Sicherheit auf `_1`** | `_1` ist überall „Zugang"; bräche die Isomorphie |
| **`_9` = Sicherheit statt Leitplanken** | `20-security` (Mechanik) und `90-policy` (Assertions) sind zwei Dinge; `_2` Mechanik, `_9` Verfassung |
| **UID = Port** (Nummer × 10) | Verwechslung; UID lebt bei Datei-Eigentum, Port im Netz — getrennt gehalten |
| **UID = 1000 + Nummer** | Führte mit `1` statt der Projektziffer; `× 1000 + Rest` ist durchgängig |
| **GID pro Dienst** (isomorph) | Zerstört den gemeinsamen Bibliothekszugriff — `Permission denied` |
| **Verschachtelte Ordner** `510/511-x.nix` | Bricht den flachen Auto-Import und zerlegt funktionierende Fabriken |
| **`_0` mit Dienst-Code füllen** | `_0` ist Wissen; Dienste in die Mitte |

---

## 9. Konsequenzen

- **Wiedererkennung ohne Nachschlagen** — `_2` ist Sicherheit, `5xxx` ist mediNix, überall.
- **Neue Projekte starten mit Skelett** — vier Anker vorgegeben, nur die Mitte füllen.
- **Wissen ist übertragbar** — eine Grammatik über alle Repos.
- **Preis:** bestehende Projekte, die den Rahmen annehmen, müssen umnummerieren
  (mediNix: ADR-5043). In der Entwicklungsphase billig, später teuer.

---

## 10. Herkunft

Aus einer Brainstorm-Reihe des Repo-Eigentümers (Juli 2026), Slot für Slot gegen
die Wirklichkeit auf q958 geprüft. Meilensteine: der Vier-Anker-Schluss (als
`20-security` und `90-policy` sich als zwei Dinge erwiesen), die GID-Regel
`Projekt × 1000`, und der Kollisionsbeweis über die `N00`-Regel — alle drei vom
Eigentümer, hier verifiziert und begründet.
