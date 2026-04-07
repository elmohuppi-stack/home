.PHONY: generate serve open dev deploy

PORT ?= 8080
DEPLOY_HOST ?= root@your-hetzner-server
DEPLOY_PATH ?= /var/www/elmarhepp.de

generate:
	bash scripts/generate-legal-config.sh

serve: generate
	cd /Users/elmarhepp/workspace/home && python3 -m http.server $(PORT)

open:
	open http://localhost:$(PORT)

dev: generate
	@echo "Website wird unter http://localhost:$(PORT) bereitgestellt"
	@echo "Starte mit: make serve PORT=$(PORT)"

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
