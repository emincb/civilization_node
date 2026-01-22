#!/bin/bash
set -e

# Civilization Node - Backup System

# Resolve Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Load Environment Variables
if [ -f "$REPO_ROOT/.env" ]; then
    export $(grep -v '^#' "$REPO_ROOT/.env" | xargs)
fi

CIV_ROOT="${CIV_ROOT:-/opt/civilization}"
BACKUP_ROOT="${CIV_ROOT}/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/$TIMESTAMP"
RETENTION_COUNT=5

echo "=== System Backup Procedure ==="
echo "Target: $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"

# 1. Backup Configuration
echo "[*] Backing up configuration..."
cp "$REPO_ROOT/docker-compose.yml" "$BACKUP_DIR/"
cp "$REPO_ROOT/.env" "$BACKUP_DIR/" 2>/dev/null || true

# 2. Backup Open WebUI Data (Hot Backup Warning: Ideally stop service first)
echo "[*] Backing up Open WebUI Data (DB/Vectors)..."
# We exclude huge caches if possible, but tar is simple.
# Using --warning=no-file-changed to suppress errors if files change during read
tar --warning=no-file-changed -czf "$BACKUP_DIR/openwebui_data.tar.gz" -C "$CIV_ROOT" openwebui

# 3. Retention Policy
echo "[*] Enforcing retention policy (Keep last $RETENTION_COUNT)..."
ls -dt "$BACKUP_ROOT"/* | tail -n +$((RETENTION_COUNT + 1)) | xargs -r rm -rf

echo "    [OK] Backup Complete. Size: $(du -sh "$BACKUP_DIR" | cut -f1)"
