#!/bin/bash
#
# Deploy the Minimal IMAP Server (James) to vraket
# Skips the lib directory (use deploy-all.sh for a full deploy including dependencies)
#

set -euo pipefail

TARGET_HOST="vraket"
TARGET_DIR="/usr/local/ice-imap"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JAR="$SCRIPT_DIR/build-release/release/ice-imap-app.jar"

if [ ! -f "$JAR" ]; then
    echo "ERROR: $JAR not found. Run the Maven build first."
    exit 1
fi

echo "Deploying to $TARGET_HOST:$TARGET_DIR ..."

ssh "$TARGET_HOST" "mkdir -p $TARGET_DIR"
scp "$JAR" "$TARGET_HOST:$TARGET_DIR/"

echo "Done. Deployed to $TARGET_HOST:$TARGET_DIR"
