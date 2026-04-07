# Deployment-Dokumentation: `elmarhepp.de`

Diese Datei dokumentiert den aktuellen Live-Stand der Landingpage auf dem Hetzner-Server.

## Ziel

Die statische Landingpage soll unter folgenden Domains erreichbar sein:

- `https://elmarhepp.de/`
- `https://www.elmarhepp.de/` → Redirect auf `https://elmarhepp.de/`

Dabei muss das bestehende **Multi-App-Setup** auf Hetzner erhalten bleiben, damit weitere Websites parallel über Subdomains betrieben werden können.

---

## Server-Setup

- **Host:** Hetzner-Server (`ssh elmarhepp`)
- **Webserver:** `nginx`
- **TLS:** Let's Encrypt / Certbot
- **Deploy-Pfad:** `/var/www/elmarhepp-root`

Die bereits laufenden Apps bleiben dabei unberührt, zum Beispiel:

- `finanzen.elmarhepp.de`
- `benzin.elmarhepp.de`
- `elmo-scanner.elmarhepp.de`

---

## Hochgeladene Dateien

Die Landingpage wurde als statische Website nach folgendem Ziel kopiert:

```text
/var/www/elmarhepp-root
```

Upload-Prinzip:

```bash
rsync -av --delete --exclude '.git/' --exclude '.env' --exclude '.vscode/' ./ elmarhepp:/var/www/elmarhepp-root/
```

---

## Nginx-Konfiguration

Verwendete Site-Datei:

```text
/etc/nginx/sites-available/elmarhepp-root.conf
```

Diese Konfiguration übernimmt:

1. HTTP → HTTPS Redirect für `elmarhepp.de`
2. Redirect von `www.elmarhepp.de` auf die Hauptdomain
3. Auslieferung der statischen Website aus `/var/www/elmarhepp-root`

Zusätzlich wurde die bisherige Platzhalter-Konfiguration so bereinigt, dass sie als generischer Default für weitere Apps dienen kann:

```text
/etc/nginx/sites-available/root-placeholder.conf
```

Dort bleibt bewusst nur ein generisches:

```nginx
server_name _;
```

Damit kollidiert die Root-Domain künftig nicht mit neuen Subdomain-Projekten.

---

## TLS / Zertifikate

Für die Root-Domain wurde ein eigenes Zertifikat erstellt:

```text
/etc/letsencrypt/live/elmarhepp.de/
```

Ausgestellt für:

- `elmarhepp.de`
- `www.elmarhepp.de`

Beispiel-Befehl:

```bash
certbot certonly --webroot -w /var/www/elmarhepp-root -d elmarhepp.de -d www.elmarhepp.de --non-interactive --agree-tos -m elmar.hepp@gmail.com --keep-until-expiring
```

---

## Verifikation

Der Live-Stand wurde geprüft mit:

```bash
curl -I -L https://elmarhepp.de/
curl -I http://www.elmarhepp.de/
curl -I https://finanzen.elmarhepp.de/
curl -I https://benzin.elmarhepp.de/
curl -I https://elmo-scanner.elmarhepp.de/
```

Ergebnis:

- `https://elmarhepp.de/` → `200 OK`
- `http://www.elmarhepp.de/` → `301 Moved Permanently`
- bestehende Subdomain-Seiten → weiterhin `200 OK`

Zusätzlich wurde geprüft, dass die Landingpage tatsächlich live ausgeliefert wird, u. a. über den Text:

```text
Der einfache Einstieg zu meinen Webprojekten.
```

---

## Hinweise für spätere Erweiterungen

Wenn weitere Apps hinzukommen, sollte das bestehende Muster beibehalten werden:

- jede App mit eigener Subdomain
- eigene Nginx-Site pro App
- keine App direkt auf Port `80/443`
- zentraler Host-`nginx` als Router
- TLS pro Domain bzw. Domain-Gruppe über Certbot

Die allgemeine Vorlage dafür liegt in:

```text
docs/hetzner-multi-app-template.md
```

---

## Empfohlener Redeploy

Wenn sich die Landingpage ändert:

```bash
cd /Users/elmarhepp/workspace/home
make generate
rsync -av --delete --exclude '.git/' --exclude '.env' --exclude '.vscode/' ./ elmarhepp:/var/www/elmarhepp-root/
```

Da es eine statische Seite ist, ist normalerweise **kein Neustart einer App** nötig. `nginx` muss nur dann neu geladen werden, wenn sich die Server-Konfiguration selbst ändert.
