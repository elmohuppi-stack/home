.PHONY: help generate build serve open dev deploy

PORT ?= 8080
DEPLOY_HOST ?= elmarhepp
DEPLOY_PATH ?= /var/www/elmarhepp-root

help:
	@echo "╔══════════════════════════════════════════════════════╗"
	@echo "║  elmarhepp.de – Makefile                            ║"
	@echo "╠══════════════════════════════════════════════════════╣"
	@echo "║                                                      ║"
	@echo "║  make build    – Statische Dateien bereitstellen     ║"
	@echo "║  make serve    – Lokalen Server starten (Port $(PORT))       ║"
	@echo "║  make open     – http://localhost:$(PORT) im Browser öffnen  ║"
	@echo "║  make dev      – Server + Browser automatisch        ║"
	@echo "║  make deploy   – Auf Server hochladen (rsync)        ║"
	@echo "║                                                      ║"
	@echo "║  Variablen:                                          ║"
	@echo "║    PORT=8080         – Lokaler Port                  ║"
	@echo "║    DEPLOY_HOST=elmarhepp – SSH-Host (aus ~/.ssh/config) ║"
	@echo "║    DEPLOY_PATH=...   – Zielverzeichnis auf Server   ║"
	@echo "║                                                      ║"
	@echo "║  Hinweis: Dies ist ein Sonderfall (statische Seite). ║"
	@echo "║  Für Apps mit Backend/API/DB siehe das Repo          ║"
	@echo "║  'platform' – NEUE-APP.md und DEPLOYMENT.md.         ║"
	@echo "║                                                      ║"
	@echo "╚══════════════════════════════════════════════════════╝"

generate:
	bash scripts/generate-legal-config.sh

build: generate
	@echo "Build abgeschlossen – alle statischen Dateien sind bereit."
	@echo "  index.html, styles.css, impressum.html, datenschutz.html, app.js, favicon.svg"
	@echo ""
	@echo "Zum lokalen Testen:  make serve   (oder make dev für Server + Browser)"
	@echo "Zum Deployen:        make deploy  (DEPLOY_HOST muss gesetzt sein)"

serve: generate
	@echo "Starte lokalen Server unter http://localhost:$(PORT) ..."
	cd /Users/elmarhepp/workspace/home && python3 -m http.server $(PORT)

open:
	open http://localhost:$(PORT)

dev: generate
	@cd /Users/elmarhepp/workspace/home && \
	python3 -m http.server $(PORT) >/tmp/elmarhepp-home-server.log 2>&1 & \
	server_pid=$$!; \
	trap 'kill $$server_pid 2>/dev/null || true' INT TERM EXIT; \
	for attempt in 1 2 3 4 5 6 7 8 9 10; do \
		if curl -sSf http://localhost:$(PORT) >/dev/null 2>&1; then \
			break; \
		fi; \
		sleep 0.2; \
	done; \
	if ! curl -sSf http://localhost:$(PORT) >/dev/null 2>&1; then \
		echo "Lokaler Server konnte nicht auf http://localhost:$(PORT) gestartet werden."; \
		exit 1; \
	fi; \
	echo "Website wird unter http://localhost:$(PORT) bereitgestellt"; \
	open http://localhost:$(PORT); \
	wait $$server_pid

# Kein 'generate' als Voraussetzung: legal-config.js wird auf dem Server aus
# /etc/elmarhepp/legal.env erzeugt, nicht hier hochgeladen. Die lokale .env ist
# nur zum Entwickeln da und darf die maßgebliche Fassung nicht überschreiben.
deploy:
	@echo "Deploye statische Seite zu $(DEPLOY_HOST):$(DEPLOY_PATH) ..."
	rsync -av --delete \
		--exclude '.git/' \
		--exclude '.env' \
		--exclude '.env.example' \
		--exclude '.gitignore' \
		--exclude '.vscode/' \
		--exclude 'docs/' \
		--exclude 'Makefile' \
		--exclude 'README.md' \
		--exclude 'legal-config.js' \
		./ "$(DEPLOY_HOST):$(DEPLOY_PATH)/"
	@echo ""
	@echo "Betreiberangaben auf dem Server neu erzeugen ..."
	ssh "$(DEPLOY_HOST)" 'cd $(DEPLOY_PATH) && bash scripts/generate-legal-config.sh'
	@echo ""
	@echo "✅ Upload abgeschlossen: $(DEPLOY_HOST):$(DEPLOY_PATH)"
	@echo "   https://elmarhepp.de/ sollte jetzt aktualisiert sein."
