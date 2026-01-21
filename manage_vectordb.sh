#!/bin/bash
set -e

DATA_DIR="/opt/civilization/openwebui"
BACKUP_DIR="/opt/civilization/backups/vectordb"
CONTAINER_NAME="civ_webui"

COMMAND=$1

function show_usage {
    echo "Usage: $0 {status|backup|prune}"
    exit 1
}

if [ -z "$COMMAND" ]; then
    show_usage
fi

if [ "$COMMAND" == "status" ]; then
    echo "=== Vector DB Status ==="
    if [ -d "$DATA_DIR" ]; then
        SIZE=$(du -sh "$DATA_DIR" | cut -f1)
        echo "Location: $DATA_DIR"
        echo "Size:     $SIZE"
    else
        echo "[!] Data directory not found at $DATA_DIR"
    fi

elif [ "$COMMAND" == "backup" ]; then
    echo "=== Vector DB Backup ==="
    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/openwebui_data_$TIMESTAMP.tar.gz"
    
    echo "[*] Creating backup at $BACKUP_FILE..."
    # Warning: Ideally stick to hot backup or stop service. For simplicity, tar implementation.
    tar -czf "$BACKUP_FILE" -C "/opt/civilization" "openwebui"
    
    echo "    [OK] Backup created."
    ls -lh "$BACKUP_FILE"

elif [ "$COMMAND" == "prune" ]; then
    echo "=== Vector DB Prune ==="
    echo "[!] Not implemented safely yet. managing deletions via Open WebUI interface is recommended."

else
    show_usage
fi
