#!/bin/bash
set -e

echo "=== Civilization Node Deployment Verification ==="

# Function to check HTTP status
check_service() {
    local name=$1
    local url=$2
    local expected=$3
    
    echo -n "[*] Checking $name... "
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "$expected"; then
        echo "[OK] (HTTP $expected)"
    else
        echo "[FAIL] Service not responding correctly at $url"
        return 1
    fi
}

echo "[*] Checking Docker Container Status..."
docker compose ps

# 1. Ollama Check
echo ""
echo "--- Service: Ollama ---"
check_service "Ollama API" "http://localhost:11434/api/version" "200"

# Check GPU inside Ollama
echo -n "[*] Verifying GPU access inside Ollama container... "
if docker exec civ_ollama nvidia-smi &> /dev/null; then
    echo "[OK]"
else
    echo "[FAIL] Could not run nvidia-smi inside container"
fi

# 2. Open WebUI Check
echo ""
echo "--- Service: Open WebUI ---"
check_service "Open WebUI" "http://localhost:3000" "200"

# 3. Kiwix Check
echo ""
echo "--- Service: Kiwix Library ---"
# Kiwix might return 200 or 302 depending on content, or 404 if no ZIMs
# We accept 200 or 301/302 for now.
# Note: If no ZIM files are present, Kiwix might not serve anything or serve a directory listing.
echo -n "[*] Checking Kiwix... "
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080")
if [[ "$HTTP_CODE" =~ ^(200|301|302|404)$ ]]; then
     echo "[OK] responding with code $HTTP_CODE"
     if [ "$HTTP_CODE" == "404" ]; then
        echo "    (Note: 404 is expected if no ZIM files are currently in /opt/civilization/library/zims)"
     fi
else
     echo "[FAIL] Unexpected response $HTTP_CODE"
fi

echo ""
echo "=== Verification Complete ==="
