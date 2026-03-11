#!/bin/bash
#
# ICEMail IMAP Server (Apache James) Installer
#

set -euo pipefail

REQUIRED_JAVA_VERSION=17

# ─── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RELEASE_DIR="$SCRIPT_DIR"

echo ""
echo "============================================"
echo "  ICEMail IMAP Server (James) Installer"
echo "============================================"
echo ""

# ─── 1. Check prerequisites ───────────────────────────────────────────────────
info "Checking prerequisites..."

if ! command -v java &>/dev/null; then
    error "Java is not installed or not on PATH."
    error "Please install Java $REQUIRED_JAVA_VERSION or later and re-run this installer."
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | awk -F'"' '/version/ {print $2}' | awk -F'.' '{print $1}')
if [ "$JAVA_VERSION" = "1" ]; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F'"' '/version/ {print $2}' | awk -F'.' '{print $2}')
fi
if [ "$JAVA_VERSION" -lt "$REQUIRED_JAVA_VERSION" ] 2>/dev/null; then
    error "Java $JAVA_VERSION found, but Java $REQUIRED_JAVA_VERSION or later is required."
    exit 1
fi
info "Java $JAVA_VERSION found — OK"
echo ""

# ─── 2. Choose install directory ──────────────────────────────────────────────
DEFAULT_INSTALL_DIR="/usr/local/ice-imap"

read -rp "Install directory [${DEFAULT_INSTALL_DIR}]: " INSTALL_DIR
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

echo ""
info "Installing to: $INSTALL_DIR"
echo ""

read -rp "Proceed? [y/N]: " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# ─── 3. Create directory and copy files ───────────────────────────────────────
mkdir -p "$INSTALL_DIR"

info "Installing James IMAP server..."
cp "$RELEASE_DIR/ice-imap-app.jar"  "$INSTALL_DIR/"
cp -r "$RELEASE_DIR/ice-imap-app.lib" "$INSTALL_DIR/"
chmod 755 "$INSTALL_DIR/ice-imap-app.lib/"*
cp "$RELEASE_DIR/logback.xml"       "$INSTALL_DIR/"
sed "s|#INSTALL_DIR#|${INSTALL_DIR}|g" \
    "$RELEASE_DIR/ice-imap-run.sh" > "$INSTALL_DIR/ice-imap-run.sh"
chmod +x "$INSTALL_DIR/ice-imap-run.sh"

# ─── 4. Generate config from template ─────────────────────────────────────────
CONFIG_FILE="$INSTALL_DIR/ice-imap.json"

if [ ! -f "$CONFIG_FILE" ]; then
    echo ""
    info "IMAP server configuration — please provide the following:"
    echo ""

    read -rp "  Mail domain handled by this server         : " MAIL_DOMAIN
    while [ -z "$MAIL_DOMAIN" ]; do
        warn "Cannot be empty."; read -rp "  Mail domain handled by this server         : " MAIL_DOMAIN
    done

    read -rp "  Hostname or IP of the ICEMail server       : " ICE_SERVER_HOST
    while [ -z "$ICE_SERVER_HOST" ]; do
        warn "Cannot be empty."; read -rp "  Hostname or IP of the ICEMail server       : " ICE_SERVER_HOST
    done

    sed \
      -e "s|#MAIL_DOMAIN#|${MAIL_DOMAIN}|g" \
      -e "s|#ICE_SERVER_HOST#|${ICE_SERVER_HOST}|g" \
      -e "s|#INSTALL_DIR#|${INSTALL_DIR}|g" \
      "$RELEASE_DIR/ice-imap-template.json" > "$CONFIG_FILE"

    info "Installed config: $CONFIG_FILE"
else
    warn "Existing config $CONFIG_FILE found, not overwritten."
fi

# ─── 5. Generate keystore (PKCS12, self-signed, 99999 days, no password) ──────
KEYSTORE="$INSTALL_DIR/keystore.p12"
if [ ! -f "$KEYSTORE" ]; then
    info "Generating self-signed TLS keystore..."
    keytool -genkeypair \
      -alias james \
      -keyalg RSA \
      -keysize 4096 \
      -validity 99999 \
      -storetype PKCS12 \
      -keystore "$KEYSTORE" \
      -storepass changeit \
      -keypass changeit \
      -dname "CN=$(hostname)" \
      2>/dev/null
    info "Keystore generated: $KEYSTORE"
else
    warn "Existing keystore found, not overwritten."
fi

# ─── 6. Systemd service file ──────────────────────────────────────────────────
if command -v systemctl &>/dev/null; then
    info "Installing systemd service file..."
    sed "s|#INSTALL_DIR#|${INSTALL_DIR}|g" \
        "$SCRIPT_DIR/ice-imap.service" > /etc/systemd/system/ice-imap.service
    chmod 755 /etc/systemd/system/ice-imap.service
    systemctl daemon-reload
    info "Service file installed: /etc/systemd/system/ice-imap.service"
else
    warn "systemctl not found — skipping service file installation."
fi

# ─── 7. Next steps ────────────────────────────────────────────────────────────
echo ""
sed "s|#INSTALL_DIR#|${INSTALL_DIR}|g" "$RELEASE_DIR/next_steps.txt"
echo ""
