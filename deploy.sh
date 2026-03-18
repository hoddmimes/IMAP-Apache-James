#!/bin/bash
#
# Deploy the Minimal IMAP Server (James) to vraket
#
# Usage:
#   ./deploy.sh        -- deploy only ice-imap-app.jar
#   ./deploy.sh all    -- deploy ice-imap-app.jar + all lib dependencies
#

set -euo pipefail

TARGET_HOST="vraket"
TARGET_DIR="/usr/local/ice-imap"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JAR="$SCRIPT_DIR/build-release/release/ice-imap-app.jar"
LIB_DIR="$SCRIPT_DIR/build-release/release/ice-imap-app.lib"
DEPLOY_ALL="${1:-}"

if [ ! -f "$JAR" ]; then
    echo "ERROR: $JAR not found. Run the Maven build first."
    exit 1
fi

echo "Deploying to $TARGET_HOST:$TARGET_DIR ..."
ssh "$TARGET_HOST" "mkdir -p $TARGET_DIR"
scp "$JAR" "$TARGET_HOST:$TARGET_DIR/"

if [ "$DEPLOY_ALL" = "all" ]; then
    echo "Deploying lib dependencies to $TARGET_HOST:$TARGET_DIR/ice-imap-app.lib ..."
    scp -r "$LIB_DIR" "$TARGET_HOST:$TARGET_DIR/"
    echo "Done. JAR + libs deployed to $TARGET_HOST:$TARGET_DIR"
else
    echo "Done. Deployed to $TARGET_HOST:$TARGET_DIR (use './deploy.sh all' to also deploy libs)"
fi
