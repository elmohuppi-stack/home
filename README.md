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
- `https://knora.elmarhepp.de/`
- `bettina-wiki/index.html` (Bettina Wiki – portable Einzeldatei)
- `https://wandervogel.elmarhepp.de/` (Wandervogel – Wander- und Radtouren planen)
- `https://prowiki.elmarhepp.de/` (ProWiki – Nachfolger von Knora)

Die Reihenfolge hier folgt den Karten in `index.html`. Wer dort eine Karte
hinzufügt, ergänzt sie auch in dieser Liste.

## Dateien

- `index.html` – Startseite
- `styles.css` – Styling
- `impressum.html` – Impressum
- `datenschutz.html` – Datenschutz
- `.env` – rechtliche Kontaktdaten
- `legal-config.js` – erzeugte Laufzeit-Konfiguration aus `.env`
- `app.js` – bindet die Kontaktdaten in die Seiten ein
- `Makefile` – lokale Startbefehle und `make deploy`
- `docs/elmarhepp-root-deployment.md` – nginx, TLS und Deploy-Pfad dieser Seite
- `docs/elmarhepp-root.nginx.conf` – Kopie der Server-Konfiguration

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

Maßgeblich ist auf dem Server **eine** Datei, nicht diese `.env`:

```text
/etc/elmarhepp/legal.env        640 root:root
```

`make generate` bevorzugt sie, wenn sie lesbar ist, und fällt nur lokal auf
`./.env` zurück. Beim Deploy wird `legal-config.js` deshalb **nicht** hochgeladen,
sondern auf dem Server aus der zentralen Quelle neu erzeugt — sonst könnte eine
veraltete lokale `.env` das Impressum der Live-Seite überschreiben.

Die lokale `.env` enthält dieselben Angaben zum Entwickeln, mit den **echten**
Werten, und bleibt aus dem Repository heraus. Hier stehen deshalb nur
Platzhalter:

```env
VITE_LEGAL_NAME="Max Mustermann"
VITE_LEGAL_EMAIL="kontakt@example.com"
VITE_LEGAL_ADDRESS_LINE_1="Musterstraße 1"
VITE_LEGAL_ADDRESS_LINE_2="12345 Musterstadt"
VITE_LEGAL_COUNTRY="Deutschland"
VITE_LEGAL_CONTENT_RESPONSIBLE="Max Mustermann"
```

Auch die erzeugte `legal-config.js` ist nicht versioniert — sie enthält
dieselbe ladungsfähige Anschrift und gehört damit ebenso wenig in ein
öffentliches Repository wie die `.env` selbst.

Nach Änderungen bitte neu erzeugen:

```bash
make generate
```

## Deployment

Die Seite liegt auf **nuernberg-16gb** bei netcup und wird von dessen zentralem
`nginx` direkt aus dem Verzeichnis ausgeliefert — kein Docker, kein Container.
Sie ist damit der einzige Sonderfall unter den Apps; alle anderen folgen dem
Standard aus dem Repo `platform`.

| | |
|---|---|
| SSH-Alias | `elmarhepp` |
| Zielverzeichnis | `/var/www/elmarhepp-root` |
| nginx-Site | `/etc/nginx/sites-available/elmarhepp-root.conf` |

Beide Werte sind im `Makefile` bereits als Vorgabe gesetzt. Ein Redeploy ist
deshalb nur:

```bash
make deploy
```

Das lädt die Seite per `rsync` hoch und erzeugt danach `legal-config.js` auf dem
Server neu. Ein Neustart ist nicht nötig — `nginx` muss nur dann neu geladen
werden, wenn sich die Server-Konfiguration selbst ändert.

Details zu nginx, TLS und Erstaufsetzung in
[`docs/elmarhepp-root-deployment.md`](docs/elmarhepp-root-deployment.md).

### Was nicht auf den Server gehört

`Makefile`, `README.md` und `docs/` sind vom Upload ausgenommen: das
Zielverzeichnis ist der öffentliche Webroot, jede Datei darin ist über
`https://elmarhepp.de/<pfad>` abrufbar. `scripts/` wird zwar hochgeladen — der
Server braucht den Generator —, ist in der nginx-Site aber gesperrt.

## Der übrige Betrieb

Server, Datenbank, Sicherungen, Impressum-Mechanik und der Weg für neue Apps
stehen **nicht** hier, sondern einmalig im Repo `platform`:

- `NEUE-APP.md` – Weg von der Idee bis zur Live-Schaltung
- `DEPLOYMENT.md` – Nachschlagewerk pro App, Abschnitt 9 zu den Betreiberangaben
- `ARCHITEKTUR.md` – warum die Regeln so sind

## Hinweis

Vor einem öffentlichen Go-live sollten insbesondere `Impressum` und `Datenschutz` noch final geprüft werden.
