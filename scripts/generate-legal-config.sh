#!/usr/bin/env bash
#
# Erzeugt legal-config.js aus den Betreiberangaben.
#
# Die Datei ist ein Generat und liegt deshalb nicht im Repository — sie enthält
# die ladungsfähige Anschrift. Bis zum 9. August 2026 war sie versioniert; das
# war der Weg, auf dem die Anschrift in ein öffentliches Repository geriet.
#
# Zwei Quellen, in dieser Reihenfolge:
#
#   1. /etc/elmarhepp/legal.env — auf dem Server die maßgebliche Fassung. Sie liegt
#      außerhalb jedes App-Verzeichnisses, damit kein Deploy sie überschreibt und
#      kein Repository sie erfasst. Variablen ohne Präfix (LEGAL_NAME, ...).
#   2. ./.env                  — lokal zum Entwickeln. Variablen mit VITE_-Präfix,
#      wie in .env.example gezeigt.
#
# Wird keine der beiden gefunden, bricht das Skript ab, statt eine Seite mit
# leeren Feldern zu erzeugen. Ein unvollständiges Impressum soll auffallen.
set -euo pipefail

cd "$(dirname "$0")/.."

ZENTRAL=/etc/elmarhepp/legal.env
QUELLE=""

if [[ -r $ZENTRAL ]]; then
  QUELLE=$ZENTRAL
elif [[ -r .env ]]; then
  QUELLE=.env
else
  echo "Fehler: weder $ZENTRAL noch ./.env lesbar." >&2
  echo "Auf dem Server als root ausführen, lokal eine .env nach .env.example anlegen." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$QUELLE"
set +a

echo "Quelle: $QUELLE"

QUELLE="$QUELLE" python3 <<'PY'
import json
import os
import sys
from pathlib import Path


def wert(name: str) -> str:
    """Nimmt LEGAL_NAME oder VITE_LEGAL_NAME — je nachdem, welche Quelle geladen wurde."""
    return (os.getenv(name) or os.getenv(f"VITE_{name}") or "").strip()


config = {
    "name": wert("LEGAL_NAME"),
    "email": wert("LEGAL_EMAIL"),
    "addressLine1": wert("LEGAL_ADDRESS_LINE_1"),
    "addressLine2": wert("LEGAL_ADDRESS_LINE_2"),
    "country": wert("LEGAL_COUNTRY") or "Deutschland",
    "contentResponsible": wert("LEGAL_CONTENT_RESPONSIBLE") or wert("LEGAL_NAME"),
}

fehlend = [k for k in ("name", "email", "addressLine1", "addressLine2") if not config[k]]
if fehlend:
    quelle = os.environ["QUELLE"]
    print(f"Fehler: diese Pflichtangaben fehlen in {quelle}: {', '.join(fehlend)}", file=sys.stderr)
    print("legal-config.js wurde NICHT geschrieben.", file=sys.stderr)
    sys.exit(1)

Path("legal-config.js").write_text(
    "// Erzeugt von scripts/generate-legal-config.sh — nicht von Hand ändern,\n"
    "// nicht versionieren. Quelle der Werte: /etc/elmarhepp/legal.env\n"
    "window.LEGAL_CONFIG = " + json.dumps(config, ensure_ascii=False, indent=2) + ";\n",
    encoding="utf-8",
)

print("legal-config.js geschrieben.")
PY
