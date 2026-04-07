#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "Fehler: .env wurde nicht gefunden." >&2
  exit 1
fi

set -a
source ./.env
set +a

python3 <<'PY'
import json
import os
from pathlib import Path

config = {
    "name": os.getenv("VITE_LEGAL_NAME", ""),
    "email": os.getenv("VITE_LEGAL_EMAIL", ""),
    "addressLine1": os.getenv("VITE_LEGAL_ADDRESS_LINE_1", ""),
    "addressLine2": os.getenv("VITE_LEGAL_ADDRESS_LINE_2", ""),
    "country": os.getenv("VITE_LEGAL_COUNTRY", ""),
    "contentResponsible": os.getenv("VITE_LEGAL_CONTENT_RESPONSIBLE", ""),
}

Path("legal-config.js").write_text(
    "window.LEGAL_CONFIG = " + json.dumps(config, ensure_ascii=False, indent=2) + ";\n",
    encoding="utf-8",
)

print("legal-config.js wurde aus .env erzeugt.")
PY
