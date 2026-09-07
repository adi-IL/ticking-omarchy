#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OMARCHY_CONFIG_DIR="${HOME}/.config/omarchy"
MODULES_DIR="${OMARCHY_CONFIG_DIR}/bar/modules"

echo "==> Installing Ticking Bar Widget for Omarchy..."

mkdir -p "${MODULES_DIR}"

# Create a clean symlink in Omarchy modules directory
ln -sfn "${SCRIPT_DIR}/TickingWidget.qml" "${MODULES_DIR}/ticking.qml"

echo "==> Linked TickingWidget.qml to ${MODULES_DIR}/ticking.qml"
echo ""
echo "To display the widget on your Omarchy bar, add this entry to bar.layout in ~/.config/omarchy/shell.json:"
echo ""
echo '  { "id": "ticking", "type": "qml", "source": "'"${SCRIPT_DIR}/TickingWidget.qml"'" }'
echo ""
echo "Then reload your shell configuration:"
echo "  omarchy-restart-shell"
echo "  # or: omarchy-shell shell reloadConfig"
