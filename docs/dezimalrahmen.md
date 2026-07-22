# Der Dezimalrahmen

Ein Nummernschema, das auf **jeder Ebene dasselbe bedeutet** — vom System-Root
bis in einen einzelnen Modulordner. Gilt für jedes Nix-Projekt in diesem
Kosmos: Nix-Grok, mediNix, devNIX und alles Künftige.

> Dieses Dokument beschreibt eine **Konvention**, keinen Code. Es fasst kein
> bestehendes Repo schreibend an — es sagt nur, wie neue Struktur entsteht und
> wohin bestehende sich bewegt, wenn sie angefasst wird.

---

## Die Grundidee: fraktal und isomorph

Dieselben wiederkehrenden Themen tauchen in **jedem** Projekt auf — egal ob
Medien, Dokumente, Netzwerk oder Agenten. Jedes Projekt braucht eine Grundlage,
einen Zugang, Sicherheit und Regeln. Also bekommen genau diese Themen **feste
Slots**, die überall dasselbe bedeuten.

Die Hunderterstelle (oder bei zweistelligen Ebenen die Zehnerstelle) ist der
**Namensraum** einer Ebene. Die letzte Stelle trägt die **Rolle**.

```
Ebene 1   /modules/         zweistellig    00 · 10 · 20 · … · 90
Ebene 2   /50-media/        dreistellig    500 · 510 · … · 590
Ebene 3   (bei Bedarf)      vierstellig    5000 · 5010 · …
```

Eine Ebene bleibt **flach** (Dateien), bis sie zu groß wird — dann **graduiert**
sie in eine eigene Tiefe mit einer weiteren Stelle. `50-media` hat das getan und
wurde zu mediNix (500–590). `80-agents` hat das getan und wurde zu devNIX.

---

## Die vier Anker — überall gleich

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

---

## Die freie Mitte — `_3` bis `_8`

Sechs Slots gehören der Domäne selbst, in ihrer logischen Reihenfolge. Hier gibt
es **keine** projektübergreifende Bedeutung — `_5` heißt im System-Root „Medien",
in mediNix „Wiedergabe", in einem anderen Projekt etwas Drittes. Das ist Absicht:
die Mitte ist der Ort für das, was ein Projekt **einzigartig** macht.

Innerhalb einer Dekade gilt weiter ADR-5042: **`N0` ist die Block-ID, `N1`–`N9`
sind Dienste.**

---

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

Vier Anker, sechs Domänen. Das war die Bestätigung, dass der Rahmen keine
Erfindung ist, sondern die schon vorhandene Ordnung — nur explizit gemacht.

---

## Beispiel: ein Dokumenten-Projekt (`_4`)

Zur Veranschaulichung, dass der Rahmen generalisiert — **nicht** als Bauauftrag:

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

---

## Warum das den Aufwand wert ist

- **Wiedererkennung ohne Nachschlagen.** `_2` ist Sicherheit, überall.
- **Neue Projekte starten mit Skelett.** Die vier Anker sind vorgegeben, nur die
  Mitte ist zu füllen.
- **Wissen ist übertragbar.** Wer sich in einem Projekt zurechtfindet, findet
  sich in allen zurecht — dieselbe Grammatik.

---

## Herkunft

Aus einer Brainstorm-Reihe des Repo-Eigentümers (Juli 2026), Slot für Slot gegen
die Wirklichkeit auf q958 geprüft. Der Vier-Anker-Schluss fiel, als sichtbar
wurde, dass `20-security` (Mechanik) und `90-policy` (Leitplanken) **zwei
verschiedene** Dinge sind — und beide, plus Fundament und Zugang, in jedem
Projekt wiederkehren.

Verwandt: mediNix `docs/adr/5042-pfadisomorphie.md` (Port/UID-Ableitung) und
`5043-dezimalrahmen.md` (die konkrete mediNix-Abbildung).
