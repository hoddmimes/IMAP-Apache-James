#!/bin/bash
#
# Build the Minimal IMAP Server (James) and deploy to vraket.
#
# Usage:
#   ./build.sh        -- build and deploy only ice-imap-app.jar
#   ./build.sh all    -- build and deploy ice-imap-app.jar + all lib dependencies
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEPLOY_ALL="${1:-}"

TARGET_HOST="vraket"
TARGET_DIR="/usr/local/ice-imap"
RELEASE_DIR="$SCRIPT_DIR/build-release/release"
JAR_SRC="$SCRIPT_DIR/server/apps/imap-app/target/james-server-imap-app.jar"
JAR_DST="$RELEASE_DIR/ice-imap-app.jar"
LIB_DIR="$RELEASE_DIR/ice-imap-app.lib"

echo "Building IMAP server..."

export JAVA_HOME=/usr/lib/jvm/java-11
mvn install -DskipTests -Dcheckstyle.skip=true -pl server/apps/imap-app -am -f "$SCRIPT_DIR/pom.xml"

echo "Copying artifact to release dir..."
cp "$JAR_SRC" "$JAR_DST"

echo "Deploying $JAR_DST to $TARGET_HOST:$TARGET_DIR ..."
ssh "$TARGET_HOST" "mkdir -p $TARGET_DIR"
scp "$JAR_DST" "$TARGET_HOST:$TARGET_DIR/"

if [ "$DEPLOY_ALL" = "all" ]; then
    echo "Deploying lib dependencies to $TARGET_HOST:$TARGET_DIR/ice-imap-app.lib ..."
    scp -r "$LIB_DIR" "$TARGET_HOST:$TARGET_DIR/"
    echo "Done. JAR + libs deployed to $TARGET_HOST:$TARGET_DIR"
else
    echo "Done. JAR deployed to $TARGET_HOST:$TARGET_DIR (use './build.sh all' to also deploy libs)"
fi
