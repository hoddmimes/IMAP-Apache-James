#!/bin/bash
#
# Build the ICEMail IMAP Server self-extracting installer using makeself.
# The jar and lib are copied to release/ by the Maven build (maven-antrun-plugin).
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

VERSION=$(python3 -c "import json; print(json.load(open('$SCRIPT_DIR/version.json'))['version'])")

if ! command -v makeself &>/dev/null; then
    echo "ERROR: makeself is not installed. Install it with: sudo apt install makeself"
    exit 1
fi

# Verify Maven build artifacts are present
if [ ! -f "$SCRIPT_DIR/release/ice-imap-app.jar" ]; then
    echo "ERROR: release/ice-imap-app.jar not found. Run the Maven build first."
    exit 1
fi
if [ ! -d "$SCRIPT_DIR/release/ice-imap-app.lib" ]; then
    echo "ERROR: release/ice-imap-app.lib not found. Run the Maven build first."
    exit 1
fi

# Copy installer into release dir
cp "$SCRIPT_DIR/install.sh" "$SCRIPT_DIR/release/"

makeself "$SCRIPT_DIR/release" \
         "$SCRIPT_DIR/ice-imap-installer-${VERSION}.run" \
         "ICEMail IMAP Server Installer" \
         ./install.sh

echo "Created: $SCRIPT_DIR/ice-imap-installer-${VERSION}.run"
