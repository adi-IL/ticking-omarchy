#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_ID="adi.ticking"
PLUGINS_DIR="${HOME}/.config/omarchy/plugins"
TARGET_DIR="${PLUGINS_DIR}/${PLUGIN_ID}"

echo "==> Validating plugin manifest..."
if command -v omarchy-plugin-validate >/dev/null 2>&1; then
    omarchy-plugin-validate "${SCRIPT_DIR}"
elif command -v omarchy >/dev/null 2>&1; then
    omarchy plugin validate "${SCRIPT_DIR}"
fi

echo "==> Linking plugin to ${TARGET_DIR}..."
mkdir -p "${PLUGINS_DIR}"
ln -sfn "${SCRIPT_DIR}" "${TARGET_DIR}"

# Remove obsolete single-file symlink if present
OBSOLETE_MODULE="${HOME}/.config/omarchy/bar/modules/ticking.qml"
if [[ -L "${OBSOLETE_MODULE}" || -f "${OBSOLETE_MODULE}" ]]; then
    rm -f "${OBSOLETE_MODULE}"
fi

echo "==> Rescanning plugins in Omarchy shell..."
if command -v omarchy-shell >/dev/null 2>&1; then
    omarchy-shell shell rescanPlugins 2>/dev/null || true
fi

echo "==> Enabling plugin ${PLUGIN_ID}..."
if command -v omarchy-plugin-enable >/dev/null 2>&1; then
    omarchy-plugin-enable "${PLUGIN_ID}" 2>/dev/null || true
elif command -v omarchy >/dev/null 2>&1; then
    omarchy plugin enable "${PLUGIN_ID}" 2>/dev/null || true
fi

echo ""
echo "Ticking plugin installed successfully."
echo "If the widget does not appear automatically, enable it with:"
echo "  omarchy plugin enable ${PLUGIN_ID}"

