# elmarhepp.de Landingpage

Schlichte statische Landingpage für `elmarhepp.de` mit Verlinkungen zu:

- `https://finanzen.elmarhepp.de/`
- `https://benzin.elmarhepp.de/`
- `https://elmo-scanner.elmarhepp.de/`
- `https://wetter.elmarhepp.de/`
- `https://mathe-quiz.elmarhepp.de/`
- `https://pick-the-place.elmarhepp.de/`
- `https://mediathek.elmarhepp.de/`
- `https://sari.elmarhepp.de/`
- `https://umami.elmarhepp.de/`
- `bettina-wiki/index.html` (Bettina Wiki – portable Einzeldatei)
- `https://wandervogel.elmarhepp.de/` (Wandervogel – Wander- und Radtouren planen)

## Dateien

- `index.html` – Startseite
- `styles.css` – Styling
- `impressum.html` – Impressum
- `datenschutz.html` – Datenschutz
- `.env` – rechtliche Kontaktdaten
- `legal-config.js` – erzeugte Laufzeit-Konfiguration aus `.env`
- `app.js` – bindet die Kontaktdaten in die Seiten ein
- `Makefile` – lokale Startbefehle
- `docs/hetzner-multi-app-template.md` – allgemeine Vorlage für Multi-App-Deployment auf Hetzner
- `docs/elmarhepp-root-deployment.md` – aktueller Live-Stand für `elmarhepp.de`

## Lokal starten

Falls noch nicht vorhanden, zuerst die Beispiel-Datei kopieren:

```bash
cp .env.example .env
```

Dann die Konfigurationsdatei erzeugen:

```bash
make generate
```

Danach den lokalen Server starten:

```bash
make dev
```

Der Browser wird dabei automatisch geoeffnet. Alternativ kannst du den Server auch manuell starten:

```bash
make serve
```

Dann im Browser oeffnen:

```text
http://localhost:8080
```

Optional mit anderem Port:

```bash
make dev PORT=3000
```

## Rechtliche Daten

Die Daten für Name, E-Mail und Adresse liegen in `.env`:

```env
VITE_LEGAL_NAME="Elmar Hepp"
VITE_LEGAL_EMAIL="elmar.hepp@gmail.com"
VITE_LEGAL_ADDRESS_LINE_1="Richard-Wagner-Str. 25"
VITE_LEGAL_ADDRESS_LINE_2="76744 Wörth am Rhein"
VITE_LEGAL_COUNTRY="Deutschland"
VITE_LEGAL_CONTENT_RESPONSIBLE="Elmar Hepp"
```

Nach Änderungen bitte neu erzeugen:

```bash
make generate
```

## Deployment-Idee

Die Seite ist bewusst statisch gehalten und passt gut zu einem Deployment auf einem Hetzner-Server mit zentralem `nginx` und Subdomain-Routing.

Mit dem `Makefile` kannst du einen einfachen Upload vorbereiten:

```bash
make deploy DEPLOY_HOST=root@<hetzner-ip> DEPLOY_PATH=/var/www/elmarhepp.de
```

Die vorhandenen Deployment-Notizen findest du in:

```text
docs/hetzner-multi-app-template.md
docs/elmarhepp-root-deployment.md
```

## Hinweis

Vor einem öffentlichen Go-live sollten insbesondere `Impressum` und `Datenschutz` noch final geprüft werden.
