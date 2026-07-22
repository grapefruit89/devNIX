# ---
# id: 8000
# title: "Dezimalrahmen — die Verfassung des Nummernschemas"
# status: "accepted"
# note: "VERFASSUNG — gilt für jedes Projekt, niemals löschen"
# date: "2026-07-21"
# related: [5042, 5043]
# tags: ["dezimalrahmen", "verfassung", "numbering", "isomorphie", "fraktal", "anker", "konvention"]
# error_pattern: "dezimalrahmen|verfassung|vier anker|nummernschema|_0|_1|_2|_9|fraktal|fundament|leitplanken|graduier|ableitung|port.*10|1000.*nummer|gid.*1000|uid"
# ---

> # ⚠ VERFASSUNG — dieses Dokument darf niemals verlorengehen
> **Es regiert das Nummernschema jedes Projekts in diesem Kosmos** — Nix-Grok,
> mediNix, devNIX und alles Künftige. Es wird nicht gelöscht, nicht ersetzt,
> nur ergänzt. Erweist sich ein Teil als falsch: `status` auf `superseded`
> und den Grund dazuschreiben — aber stehen lassen.
>
> **Verankert in:** `AGENTS.md` (mediNix), `CLAUDE.md` (devNIX), beide READMEs.
> Wer eine dieser Dateien liest, wird hierher geführt.

# ADR-8000 — Der Dezimalrahmen

Ein Nummernschema, das auf **jeder Ebene dasselbe bedeutet** — vom System-Root
bis in einen einzelnen Modulordner.

## Warum das die wichtigste Entscheidung ist

Sie ist die einzige, die **projektübergreifend** gilt. Alle anderen ADRs regeln
*ein* Projekt; diese regelt die Grammatik *aller*. Wer sie kennt, findet sich in
jedem Repo zurecht, ohne es gelesen zu haben. Das ist der ganze Sinn: **eine
Sprache, überall.**

## Die Grundidee: fraktal und isomorph

Wiederkehrende Themen tauchen in **jedem** Projekt auf — egal ob Medien,
Dokumente, Netzwerk oder Agenten. Jedes braucht eine Grundlage, einen Zugang,
Sicherheit und Regeln. Also bekommen genau diese Themen **feste Slots**, die
überall dasselbe bedeuten.

Die führende Stelle einer Ebene ist der **Namensraum**, die letzte Stelle trägt
die **Rolle**.

```
Ebene 1   /modules/         zweistellig    00 · 10 · 20 · … · 90
Ebene 2   /50-media/        dreistellig    500 · 510 · … · 590
Ebene 3   (bei Bedarf)      vierstellig    5000 · 5010 · …
```

Eine Ebene bleibt **flach** (Dateien), bis sie zu groß wird — dann **graduiert**
sie in eine eigene Tiefe mit einer weiteren Stelle. `50-media` tat das und wurde
mediNix (500–590). `80-agents` tat das und wurde devNIX (800–890).

## Die Entscheidung: vier Anker, überall gleich

| Slot | Rolle | Frage | Beispiel-Inhalt |
|---|---|---|---|
| **`_0`** | **Fundament** | Womit arbeiten wir? | `CLAUDE.md`, `default.nix`, `docs/`, `registry` — **Wissen, keine Dienste** |
| **`_1`** | **Zugang** | Wie kommt man rein? | Reverse-Proxy, mDNS, Routing, Auth-Eingang |
| **`_2`** | **Sicherheit** | Wie geschützt? | Firewall, TLS, VPN-Confinement, Auth-Mechanik |
| **`_9`** | **Leitplanken** | Was muss alles einhalten? | Assertions, Verbote, globale Invarianten |

Die vier stehen fest. Wer `_2` sieht, weiß: Sicherheit — im System-Root (`20`),
in mediNix (`520`), in einem Dokumenten-Projekt (`420`). Immer.

**`_0` ist Wissen, nicht Code.** Der Fundament-Slot hält die `CLAUDE.md` der
Domäne, ihr aggregierendes `default.nix`, ihre Doku und die `registry`. Er wird
**nicht** mit Dienst-Modulen vollgepackt — die wohnen in den mittleren Slots.

Ein Projekt **populiert nur die Anker, die es hat**. devNIX etwa hat keinen
eigenen Ingress — sein `_1` bleibt leer. Ein leerer Anker ist reserviert, kein
Fehler.

## Die freie Mitte — `_3` bis `_8`

Sechs Slots gehören der Domäne selbst, in ihrer logischen Reihenfolge. Hier gibt
es **keine** projektübergreifende Bedeutung — `_5` heißt im System-Root „Medien",
in mediNix „Wiedergabe", anderswo etwas Drittes. Das ist Absicht: die Mitte ist
der Ort für das, was ein Projekt **einzigartig** macht.

Innerhalb einer Dekade gilt ADR-5042: **`N0` ist die Block-ID, `N1`–`N9` sind
Dienste.**

## Ableitungen — was aus der Nummer folgt

Die Nummer ist die einzige Wahrheit. Alles, was sonst eine **willkürliche Zahl**
wäre, wird aus ihr abgeleitet — jede Größe nach einer Regel, die zu ihrem
Namensraum passt.

| Größe | Regel | Beispiel `sonarr` (532) | Was die führende Stelle verrät |
|---|---|---|---|
| **Port** | Nummer × 10 | `5320` | Tausender = Projekt (`5` = media) |
| **UID** | 1000 + Nummer | `1532` | `1` + Nummer, im User-Bereich |
| **GID** | **Projekt × 1000** | `5000` | die geteilte Projekt-Gruppe |

Port (`5320`) und GID (`5000`) tragen das Projekt **vorne**. Die UID (`1532`)
muss die 1000-Grenze zum Systembereich überschreiten — daher `1` + Nummer statt
Nummer voran. Alle drei enthalten die Nummer sichtbar; keine ist geraten.

### GID ist pro PROJEKT, nicht pro Dienst

```
mediNix  (Namensraum 5)  →  GID 5000    alle Dienste teilen sie
devNIX   (Namensraum 8)  →  GID 8000
documents (Namensraum 4) →  GID 4000
```

Der Sinn: **gemeinsamer Dateizugriff innerhalb eines Projekts** — bei mediNix die
Medien-Bibliothek. Deshalb `Projekt × 1000` und nicht `1000 + Nummer`: eine
eigene GID pro Dienst würde jeden isolieren, und Jellyfin könnte Sonarrs Dateien
nicht lesen (`Permission denied`). Das ist der klassische Docker-PUID/PGID-Fehler
in Nix-Form.

`5 × 1000 = 5000` validiert im Nachhinein die GID, die mediNix schon trägt — sie
war nie willkürlich, sondern der Namensraum × 1000.

### Warum drei Regeln und nicht eine

Weil jeder Namensraum eigene Grenzen hat:

- **Ports** müssen 1024–65535 sein → Nummer × 10 legt jedes Projekt in sein
  eigenes Tausender-Band (media 5xxx, devNIX 8xxx). Nie privilegiert, nie kollidierend.
- **UIDs** müssen > 1000 sein, sonst Systembereich → 1000 + Nummer.
- **GIDs** sind projektweit geteilt → Projekt × 1000, oberhalb des
  System-Automaten (400–999 abwärts) und der abgeleiteten UIDs.

Eine einzige Formel würde eine dieser Grenzen verletzen. Isomorphie heißt hier
**nicht** „alle Zahlen gleich", sondern: *alles aus der einen Nummer, jede Größe
passend transformiert*. Das ist **sinnvolle Isomorphie** — ableiten, wo eine Zahl
willkürlich wäre, aber die Grenzen des Zielraums achten. (ADR-5042.)

### Unix-Sockets — vorerst nicht vergeben

Falls je gebraucht: `/run/{projekt}/{nummer}.sock`. Derzeit unterstützt **kein**
Dienst HTTP-über-Unix-Socket (auf q958 geprüft: die *arr binden ausschließlich
TCP, `bindaddress` ist eine IP, kein Pfad). Also keine Socket-Ableitung — die
Regel steht bereit, wird aber nicht angewandt, bis ein Dienst sie braucht.

## Das System-Root folgt dem Rahmen bereits

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

## Beispiel: ein Dokumenten-Projekt (`_4`)

Zur Veranschaulichung, **nicht** als Bauauftrag:

```
40-documents/  → (graduiert zu einem Repo, 4xx)
  400  Fundament    CLAUDE.md, registry, docs      womit arbeiten wir
  410  Zugang       Reverse-Proxy, SSO             wie kommt man rein
  420  Sicherheit   Zugriffsschutz                 wie geschützt
  430  Erfassung    paperless-ngx                  was rein
  440  Ablage       nextcloud, opencloud           wo liegt es
  490  Leitplanken  Assertions                     was einhalten
```

Wer mediNix kennt, liest das ohne Anleitung.

## Abgelehnt

| Vorschlag | Grund |
|---|---|
| **Drei Anker** (`_0`, `_1`, `_9`), Sicherheit als Domäne | Sicherheit kehrt in *jedem* Projekt wieder — sie verdient einen festen Slot wie Fundament und Zugang. Ohne wäre ihr Ort projektabhängig, also nicht wiedererkennbar |
| Sicherheit auf `_1` | `_1` ist schon überall „Zugang" (10-network, 510-ingress). Sicherheit dorthin zu legen bräche die Isomorphie, die der ganze Rahmen aufbaut |
| `_9` = Sicherheit statt Leitplanken | `20-security` (Mechanik) und `90-policy` (Assertions/Verbote) sind **zwei verschiedene** Dinge. `_9` ist die Verfassung, `_2` die Mechanik |
| Verschachtelte Ordner `510/511-x.nix` | Der Auto-Import scannt flach und importiert `folder/default.nix`. Verschachteln bräche ihn und zerlegte funktionierende Fabriken |
| `_0` mit Dienst-`.nix` füllen | `_0` ist Wissen, nicht Code. Dienste wohnen in der Mitte |

## Konsequenzen

- **Wiedererkennung ohne Nachschlagen** — `_2` ist Sicherheit, überall.
- **Neue Projekte starten mit Skelett** — vier Anker vorgegeben, nur die Mitte füllen.
- **Wissen ist übertragbar** — eine Grammatik über alle Repos.
- **Preis:** bestehende Projekte, die den Rahmen annehmen, müssen umnummerieren
  (mediNix: ADR-5043). In der Entwicklungsphase billig, später teuer.

## Herkunft

Aus einer Brainstorm-Reihe des Repo-Eigentümers (Juli 2026), Slot für Slot gegen
die Wirklichkeit auf q958 geprüft. Der Vier-Anker-Schluss fiel, als sichtbar
wurde, dass `20-security` und `90-policy` zwei verschiedene Dinge sind — und
beide, plus Fundament und Zugang, in jedem Projekt wiederkehren.
