---
description: Das Nummern- und Ordnerschema jedes Nix-Projekts — vier feste Anker über alle Ebenen (Dezimalrahmen, das erste Gebot). Nutzen, sobald ein Ordner oder eine Nummer vergeben wird, wenn gefragt wird wo etwas hingehört, bei jeder Struktur- oder Umnummerierungsfrage, oder wenn ein neues Projekt beginnt.
---

# Struktur — der Dezimalrahmen

> **Das erste Gebot.** Geht dieses Schema verloren, verliert das Projekt die
> Orientierung und verkrautet. Volle Autorität: `devNIX/docs/adr/8000-dezimalrahmen.md`.
> Diese Kurzform trägt die Essenz mit — falls die ADR mal nicht zur Hand ist.

## Vier Anker — überall gleich, auf jeder Ebene

```
_0  FUNDAMENT     Wissen der Domäne: CLAUDE.md, default.nix, docs, registry
_1  ZUGANG        wie kommt man rein: Reverse-Proxy, mDNS, Routing, Auth
_2  SICHERHEIT    wie geschützt: Firewall, TLS, VPN-Confinement
_3…_8  DOMÄNEN    der projekteigene Stoff, frei, in logischer Reihenfolge
_9  LEITPLANKEN   was alles einhält: Assertions, Verbote, Invarianten
```

Wer `_2` sieht, weiß Sicherheit — im System-Root (`20`), in mediNix (`520`),
überall. `_0` hält **Wissen, keine Dienste**.

## Fraktal und graduierend

Dieselbe Bedeutung auf jeder Tiefe:

```
Ebene 1  /modules/     2-stellig   00 · 10 · 20 · … · 90
Ebene 2  /50-media/    3-stellig   500 · 510 · … · 590
```

Eine Ebene bleibt **flach** (Dateien), bis sie zu groß wird — dann graduiert sie
in eine weitere Stelle. So wurde `50-media` → mediNix (5xx), `80-agents` → devNIX (8xx).

Innerhalb einer Dekade: **`N0` = Block-ID, `N1`–`N9` = Dienste** (ADR-5042).

## Bevor du eine Nummer oder einen Ordner vergibst

1. Welcher Anker oder welche Domäne? `_0`/`_1`/`_2`/`_9` sind fest, `_3`–`_8` frei.
2. Ist die Ebene schon 3-stellig (graduiert) oder noch flach?
3. Nächste freie Nummer in der Dekade, keine Lücken.
4. **Ableitungen** aus der Nummer:
   - Port = Nummer × 10   (532 → 5320)
   - UID  = Projekt × 1000 + Rest (532 → 5032; Rest = Dekade+Dienst)
   - GID  = **Projekt × 1000** — pro PROJEKT geteilt, nicht pro Dienst
            (mediNix 5 → 5000, devNIX 8 → 8000)
   Drei Regeln, weil jeder Namensraum eigene Grenzen hat. Sinnvolle Isomorphie:
   alles aus der einen Nummer, jede Groesse passend transformiert.

## Was verworfen wurde — nicht erneut vorschlagen

- **Drei Anker** (Sicherheit als Domäne): Sicherheit kehrt überall wieder → fester Slot.
- **Sicherheit auf `_1`**: `_1` ist überall „Zugang" → bräche die Isomorphie.
- **`_9` = Sicherheit**: `_9` ist Leitplanken (Assertions), Sicherheits-Mechanik ist `_2`.
- **Verschachtelte Ordner** `510/511-x.nix`: bricht den flachen Auto-Import.
- **`_0` mit Dienst-Code**: `_0` ist Wissen; Dienste in die Mitte.

Begründungen vollständig in ADR-8000.
