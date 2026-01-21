#!/bin/bash
set -e

# Civilization Node - Content Update Helper

echo "=== Content Update Routine ==="

# 1. Batch Move (Bypassing interactive civ_ingest.sh for mass update)
echo "[*] Moving files from Incoming to Library..."
if [ -n "$(ls -A /opt/civilization/incoming/*.zim 2>/dev/null)" ]; then
    mkdir -p /opt/civilization/library/zims
    mv /opt/civilization/incoming/*.zim /opt/civilization/library/zims/
    echo "    [OK] ZIM files moved."
else
    echo "    [!] No ZIM files found in incoming/."
fi

# 2. Reload Services if needed
echo ""
echo "[*] Restarting affected services..."
echo "    Restarting Kiwix (civ_library) to load new ZIMs..."
docker restart civ_library

# 3. Check Status
echo "[*] Verifying Service Health..."
sleep 5
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|301\|302"; then
    echo "    [OK] Kiwix is back online."
else
    echo "    [FAIL] Kiwix did not respond after restart."
fi

echo "=== Update Complete ==="
