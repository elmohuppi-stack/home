# Deployment: `elmarhepp.de`

> **Sonderfall — kein Docker.** Für sieben statische Dateien einen Container zu
> starten wäre Aufwand ohne Gegenwert. Die Seite wird per `rsync` in ein
> Verzeichnis kopiert und vom Host-`nginx` über die `root`-Directive
> ausgeliefert. **Alle anderen Apps** folgen dem Standard im Repo `platform`
> (`NEUE-APP.md`, `ARCHITEKTUR.md`, `DEPLOYMENT.md`) — dieses Dokument
> beschreibt ausdrücklich nur die Ausnahme.

## Server

| | |
|---|---|
| Host | **nuernberg-16gb** bei netcup, SSH-Alias `elmarhepp` |
| Webserver | Host-`nginx` als Router für alle Subdomains |
| TLS | Let's Encrypt / certbot, Erneuerung per `certbot.timer` |
| Deploy-Pfad | `/var/www/elmarhepp-root` |

> **Bis zum 15. August 2026 lief das auf einem Hetzner-Server.** Der Umzug ist in
> `platform/UMZUG-NETCUP.md` protokolliert. Pfade wie `/etc/hetzner/` gibt es
> seitdem nicht mehr; die Betreiberangaben liegen in `/etc/elmarhepp/legal.env`.

## Domains

- `https://elmarhepp.de/` — die Seite
- `https://www.elmarhepp.de/` — 301 auf die Hauptdomain
- `http://…` — 301 auf HTTPS

Zertifikat unter `/etc/letsencrypt/live/elmarhepp.de/`, ausgestellt für beide
Namen.

## Redeploy

```bash
cd /Users/elmarhepp/workspace/home
make deploy
```

`DEPLOY_HOST=elmarhepp` und `DEPLOY_PATH=/var/www/elmarhepp-root` sind im
`Makefile` vorgegeben; beide müssen im Normalfall nicht gesetzt werden. Das Ziel
lädt per `rsync --delete` hoch und ruft danach auf dem Server
`scripts/generate-legal-config.sh` auf.

Ein Neustart ist nicht nötig. `nginx` wird nur neu geladen, wenn sich die
Server-Konfiguration selbst ändert.

## Was der Webroot nicht enthalten darf

`/var/www/elmarhepp-root` **ist** der öffentliche Webroot: jede Datei darin ist
unter `https://elmarhepp.de/<pfad>` abrufbar. Bis zum 16. August 2026 lagen dort
`README.md`, das `Makefile` und `docs/` — inklusive dieser Datei und einer Kopie
der nginx-Site — und waren mit `200` abrufbar. Sie stammten aus einem Upload,
bevor der `rsync` seine `--exclude`-Liste bekam; da `--exclude` eine Datei
zugleich vor `--delete` schützt, wären sie von allein nie verschwunden.

Zwei Maßnahmen, die zusammengehören:

- Der `rsync` in `deploy` schließt `Makefile`, `README.md` und `docs/` aus.
- Die nginx-Site sperrt `/scripts/` und alles, was mit einem Punkt beginnt.
  `scripts/` **muss** hochgeladen werden — der Server erzeugt damit
  `legal-config.js` —, darf aber nicht ausgeliefert werden.

Eine Ausnahme in die andere Richtung: `legal-config.js` wird **nicht**
hochgeladen. Es entsteht auf dem Server aus `/etc/elmarhepp/legal.env`; ein
Upload aus der lokalen `.env` könnte das Impressum stillschweigend auf einen
alten Stand zurücksetzen.

## Zwei Zeilen in der nginx-Site, die man kennen muss

```nginx
try_files $uri $uri.html $uri/ /index.html;
```

Das `$uri.html` ist seit dem 9. August 2026 nötig. Ohne es liefert `/impressum`
die Startseite aus, weil der SPA-Fallback greift — und genau auf diese beiden
Pfade zeigen die Fußzeilen **aller** Apps unter `elmarhepp.de`
(`platform/DEPLOYMENT.md`, Abschnitt 9).

```nginx
location ~ ^/(scripts|\.) { return 404; }
```

Die Sperre aus dem Abschnitt oben.

Sicherung der Konfiguration vor der Impressum-Änderung:
`/etc/nginx/sites-available/elmarhepp-root.conf.bak-2026-08-09`.

## Prüfung nach einem Deploy

```bash
curl -I https://elmarhepp.de/                     # 200
curl -I http://www.elmarhepp.de/                  # 301
curl -sI https://elmarhepp.de/impressum | head -1 # 200, nicht die Startseite
curl -sI https://elmarhepp.de/scripts/generate-legal-config.sh | head -1  # 404
curl -s  https://elmarhepp.de/legal-config.js | head -3                   # echte Werte
```
