#!/bin/bash
set -e

# Civilization Node - Master System Validation
# Version 1.0

echo "=== Civilization Node Master Check ==="
echo "Date: $(date)"

FAILURES=0

report_pass() {
    echo "    [PASS] $1"
}

report_fail() {
    echo "    [FAIL] $1"
    FAILURES=$((FAILURES + 1))
}

# 1. Container Status
echo "[*] Checking Docker Containers..."
REQUIRED_CONTAINERS=("civ_ollama" "civ_webui" "civ_library")
for container in "${REQUIRED_CONTAINERS[@]}"; do
    if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        report_pass "$container is RUNNING"
    else
        report_fail "$container is DOWN"
    fi
done

# 2. GPU Availability
echo "[*] Checking GPU Access..."
if docker exec civ_ollama nvidia-smi &> /dev/null; then
    report_pass "GPU visible inside civ_ollama"
else
    report_fail "GPU NOT visible inside civ_ollama"
fi

# 3. Service Connectivity
echo "[*] Checking Service Responses..."

# Kiwix (Library)
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200\|301\|302"; then
    report_pass "Kiwix Library (Port 8080) responding"
else
    report_fail "Kiwix Library (Port 8080) unresponsive"
fi

# Open WebUI
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200"; then
    report_pass "Open WebUI (Port 3000) responding"
else
    report_fail "Open WebUI (Port 3000) unresponsive"
fi

# 4. Storage Checks
echo "[*] Checking Storage..."
# Check /opt/civilization disk usage
DISK_USAGE=$(df -h /opt/civilization | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USAGE" -lt 90 ]; then
     report_pass "Disk Usage OK ($DISK_USAGE%)"
else
     report_fail "Disk Usage CRITICAL ($DISK_USAGE%)"
fi

# Check Vector DB perms
if [ -w "/opt/civilization/openwebui" ]; then
    report_pass "Vector DB directory writable"
else
    report_fail "Vector DB directory permissions issue"
fi

echo ""
if [ $FAILURES -eq 0 ]; then
    echo "=== ALL SYSTEMS OPERATIONAL ==="
    exit 0
else
    echo "=== SYSTEM DEGRADED ($FAILURES checks failed) ==="
    exit 1
fi
