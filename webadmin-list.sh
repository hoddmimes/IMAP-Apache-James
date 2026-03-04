#!/bin/bash
# WebAdmin list commands for Apache James IMAP server
# Requires: ADMIN_PASSWORD env var, or pass as first argument

BASE="http://localhost:8000"
USER="admin"
PASS="${1:-${ADMIN_PASSWORD:-admin}}"
AUTH="$USER:$PASS"

run() {
    local label="$1"
    local url="$2"
    echo "=== $label ==="
    curl -s -u "$AUTH" "$url" | python3 -m json.tool 2>/dev/null || curl -s -u "$AUTH" "$url"
    echo
}

run "Tasks"              "$BASE/tasks"
run "Health checks"      "$BASE/healthcheck/checks"
run "Users"              "$BASE/users"
run "Domains"            "$BASE/domains"
run "Address aliases"    "$BASE/address/aliases"
run "Forwards"           "$BASE/address/forwards"
run "Groups"             "$BASE/address/groups"
run "All mappings"       "$BASE/mappings"
run "Domain mappings"    "$BASE/domainMappings"
