#!/bin/bash
#
# Build the Minimal IMAP Server (James)
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Building IMAP server..."

export JAVA_HOME=/usr/lib/jvm/java-11
mvn install -DskipTests -Dcheckstyle.skip=true -pl server/apps/imap-app -am -f "$SCRIPT_DIR/pom.xml"

echo "Done. Artifact: $SCRIPT_DIR/server/apps/imap-app/target/james-server-imap-app.jar"
