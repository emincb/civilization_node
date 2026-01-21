#!/bin/bash
set -e

LIBRARY_DIR="/opt/civilization/library"
INCOMING_DIR="/opt/civilization/incoming"

echo "=== Civilization Node Maintenance ==="

# 1. Disk Usage Stats
echo ""
echo "[*] Storage Statistics:"
du -sh "$LIBRARY_DIR/zims" "$LIBRARY_DIR/pdfs" "$INCOMING_DIR" | sed 's/\/opt\/civilization\///'

# 2. Incoming Audit
echo ""
echo "[*] Checking Incoming Queue..."
FILE_COUNT=$(find "$INCOMING_DIR" -type f | wc -l)
if [ "$FILE_COUNT" -gt 0 ]; then
    echo "    [WARN] $FILE_COUNT file(s) waiting in incoming. Run civ_ingest.sh."
else
    echo "    [OK] Incoming queue empty."
fi

# 3. Naming Convention Audit (Simple heuristic)
echo ""
echo "[*] Auditing Naming Conventions (Sample check)..."

# Check for spaces in filenames (bad practice)
BAD_NAMES=$(find "$LIBRARY_DIR" -name "* *" | head -n 5)
if [ -n "$BAD_NAMES" ]; then
    echo "    [WARN] Found files with spaces in names (showing first 5):"
    echo "$BAD_NAMES"
    echo "    Recommendation: Rename to use underscores."
else
    echo "    [OK] No spaces detected in filenames."
fi

# 4. Empty Directory Cleanup
echo ""
echo "[*] Cleaning empty directories..."
find "$LIBRARY_DIR" -type d -empty -delete -print 2>/dev/null | awk '{print "    [REMOVED] " $0}' || echo "    [OK] No empty directories found."

echo ""
echo "=== Maintenance Complete ==="
