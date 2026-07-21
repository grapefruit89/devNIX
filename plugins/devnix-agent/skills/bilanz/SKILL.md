---
description: Zeigt, ob die Werkzeuge tatsaechlich benutzt wurden -- Strichliste ueber Recherchen, Nachweise, Lint und Schreibvorgaenge. Nutzen, wenn gefragt wird ob sich etwas verbessert, oder am Ende einer Sitzung.
---

# Bilanz

```bash
devnix-bilanz          # letzte 7 Tage
devnix-bilanz 30       # letzte 30 Tage
devnix-bilanz --heute
devnix-bilanz --sperren
```

## Die eine Zahl, auf die es ankommt

**Recherchen je .nix-Schreibvorgang.**

| Wert | Bedeutung |
|---|---|
| unter 0.5 | Deutlich mehr geschrieben als nachgeschlagen. Das ist das Muster, aus dem Behauptungen aus dem Gedaechtnis entstehen |
| 0.5 – 1.0 | Brauchbar, geht besser |
| ueber 1.0 | Mehr nachgeschlagen als geschrieben |

Zweite Warnung: **null Nachweise bei Schreibvorgaengen**. Dann wurde nichts
gegengeprueft -- kein `curl` von aussen, kein `NRestarts`, kein Store-Pfad-
Vergleich. Der Code kann trotzdem falsch sein und niemand wuerde es merken.

## Wie du die Zahlen liest

Ein einzelner Lauf sagt nichts. Der Sinn ist der **Verlauf ueber Sitzungen**:
verbessert sich die Quote, oder steht dieselbe Korrektur zum vierten Mal an?

Wenn die Bilanz schlecht aussieht, ist die richtige Reaktion nicht, sich mehr
Muehe zu geben -- sondern die betreffende Regel aus einem Skill in einen **Hook**
zu verschieben. Skills sind Kontext und koennen ignoriert werden. Hooks nicht.

## Grenzen dieser Zahlen

Sie messen **Haeufigkeit**, nicht Qualitaet. Zehn sinnlose `nix eval` heben die
Quote genauso wie zehn richtige. Sie sind ein Rauchmelder, kein Urteil --
brauchbar um zu sehen, dass etwas fehlt, nicht um zu beweisen, dass alles gut ist.
