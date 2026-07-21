---
description: Pflichtpruefung, bevor eine Aussage ueber ein Nix-Paket, eine services.*-Option oder ein NixOS-Modul faellt. Nutzen, sobald behauptet werden soll, dass es etwas gibt oder nicht gibt, dass etwas paketiert werden muesste, oder dass eine Option so heisst.
---

# Nix-Recherche

**Ohne Aufforderung durchzufuehren.** Voraussetzung fuer jede Aussage der Form
„das gibt es (nicht)", „das muesste man paketieren", „dafuer gibt es kein Modul".

## Warum das eine eigene Regel ist

Bei Feishin wurde dreimal hintereinander falsch geurteilt — „Desktop-App",
„muesste man paketieren", „drei Wege mit Aufwand". Alle drei aus einer
*unvollstaendigen Pruefung* aufs Ganze verallgemeinert. Der Mensch musste
dreimal widersprechen und am Ende selbst die Links liefern.

Die untauglichen Befehle waren:

```bash
nix eval nixpkgs#nixosModules | grep NAME   # falsches Attribut
nix eval nixpkgs#NAME.version               # nur EINE Namensvariante
```

## Der Ablauf — vier Schritte, 90 Sekunden

```bash
# 1. Paket + uebliche Varianten
for v in "" -web -server -cli -unwrapped -bin; do
  nix eval --raw "nixpkgs#NAME$v.version" 2>/dev/null && echo "  -> NAME$v"
done

# 2. Volltextsuche -- findet abweichende Namen
nix search nixpkgs NAME

# 3. NixOS-MODUL? Andere Datenbank als Pakete!
NP=$(nix eval --raw nixpkgs#path)
find "$NP/nixos/modules" -iname "*NAME*"

# 4. WAS liefert das Paket? Beschreibungen luegen, Inhalte nicht.
P=$(nix build nixpkgs#NAME --no-link --print-out-paths)
find "$P" -maxdepth 3 | head -20
```

**Schritt 4 entscheidet.** „Music Player" stand bei `feishin` *und*
`feishin-web`. Erst der Inhalt zeigte den Unterschied: `feishin.desktop` +
`resources.pak` beim einen, `index.html` beim anderen — also Desktop-App gegen
statische Web-Dateien.

## Wenn kein Nix zur Hand ist

Dann die MCPs: `nixos` fuer Pakete und `services.*`, Noogle fuer `lib.*` und
`builtins.*`, Context7 fuer externe Bibliotheken, GitHub-MCP fuer Fehler aus
Fremdpaketen. Aber: **lokales `nix` schlaegt jeden MCP**, weil es aus dem Kanal
antwortet, der wirklich laeuft, statt aus einem Suchindex.

## Merksatz

> Findet eine Pruefung nichts, ist die erste Frage nicht „gibt es das nicht?",
> sondern **„habe ich richtig gesucht?"** Ein negatives Ergebnis aus einem
> untauglichen Befehl ist kein Ergebnis.
