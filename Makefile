m.PHONY: generate serve open dev deploy

PORT ?= 8080
DEPLOY_HOST ?= root@your-hetzner-server
DEPLOY_PATH ?= /var/www/elmarhepp-root

generate:
	bash scripts/generate-legal-config.sh

serve: generate
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

deploy: generate
	@if [ "$(DEPLOY_HOST)" = "root@your-hetzner-server" ]; then \
		echo "Bitte DEPLOY_HOST setzen, z. B. make deploy DEPLOY_HOST=root@1.2.3.4 DEPLOY_PATH=$(DEPLOY_PATH)"; \
		exit 1; \
	fi
	rsync -av --delete \
		--exclude '.git/' \
		--exclude '.env' \
		./ "$(DEPLOY_HOST):$(DEPLOY_PATH)/"
	@echo "Upload abgeschlossen: $(DEPLOY_HOST):$(DEPLOY_PATH)"
