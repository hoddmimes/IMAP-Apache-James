#!/bin/bash
#
# Deploy the Minimal IMAP Server (James) to vraket
#

set -euo pipefail

TARGET_HOST="vraket"
TARGET_DIR="/usr/local/imap-james"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$SCRIPT_DIR/server/apps/imap-app/target"

JAR="$APP_DIR/james-server-imap-app.jar"
LIB_DIR="$APP_DIR/james-server-imap-app.lib"
CONFIG="$SCRIPT_DIR/imap-server-*.json"
KEYSTORE="$SCRIPT_DIR/keystore.p12"
LOGBACK="$SCRIPT_DIR/logback.xml"
RUN_SCRIPT="$SCRIPT_DIR/imap-server-run.sh"

# Verify all artifacts exist
for f in "$JAR" "$KEYSTORE" "$LOGBACK" "$RUN_SCRIPT"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: $f not found"
        exit 1
    fi
done
if ! ls $CONFIG 2>/dev/null | grep -q .; then
    echo "ERROR: No config files matching imap-server-*.json found"
    exit 1
fi
if [ ! -d "$LIB_DIR" ]; then
    echo "ERROR: $LIB_DIR not found. Build first."
    exit 1
fi

echo "Deploying to $TARGET_HOST:$TARGET_DIR ..."

ssh "$TARGET_HOST" "mkdir -p $TARGET_DIR"

scp "$JAR" $CONFIG "$LOGBACK" "$RUN_SCRIPT" "$TARGET_HOST:$TARGET_DIR/"
scp -r "$LIB_DIR" "$TARGET_HOST:$TARGET_DIR/"

echo "Done. Deployed to $TARGET_HOST:$TARGET_DIR"
