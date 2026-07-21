---
description: Ermittelt den echten Zustand des Systems, bevor irgendeine Aussage darueber faellt. Nutzen bei Sitzungsbeginn, nach einer Kontextverdichtung, oder wenn eine Behauptung ueber laufende Dienste, Git-Stand oder Bootfestigkeit im Raum steht.
---

# Lage

Erinnerte Zusammenfassungen sind **Hinweise, was zu pruefen ist** — nie
Wahrheitsstand. Fuehre das hier aus, bevor du irgendetwas ueber den Zustand sagst.

```bash
cd ~/mediNix && git log --oneline -5 && git status --short
systemctl --failed --no-pager
for s in jellyfin sonarr radarr readarr lidarr prowlarr sabnzbd navidrome \
         jellyseerr audiobookshelf feishin; do
  printf "%-16s %s\n" "$s" "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://$s.local)"
done
[ "$(readlink -f /run/current-system)" = "$(readlink -f /nix/var/nix/profiles/system)" ] \
  && echo "bootfest" || echo "NICHT bootfest -- switch faellig"
```

## Ein laufender Dienst kann unerreichbar sein

`is-active` allein beweist nichts. Jellyfin war `active` mit 0 Neustarts — und
lauschte auf dem falschen Port, weil seine Vorgaben nie griffen. Caddy lieferte
502. Drei Dinge gehoeren zusammen:

```bash
systemctl is-active <dienst>
systemctl show <dienst> -p NRestarts --value      # muss 0 sein
sudo ss -tlnp | grep <dienst>                     # Port pruefen
```

Und `curl` **von aussen** ueber `.local` — `127.0.0.1` prueft weder mDNS noch
den Reverse-Proxy.

## Bei Widerspruch

Widerspricht das Ergebnis einer erinnerten Zusammenfassung, **haben die Befehle
recht**. Sag das dem Menschen ausdruecklich, bevor du weitermachst — nicht
stillschweigend korrigieren.
