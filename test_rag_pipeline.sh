#!/bin/bash
set -e

echo "=== RAG Pipeline Diagnostic ==="

# 1. Check Ollama Model
echo -n "[*] Checking for embedding model... "
if docker exec civ_ollama ollama list | grep -q "nomic-embed-text"; then
    echo "[OK] (nomic-embed-text found)"
else
    echo "[FAIL] Model missing. Run ./rag_setup.sh"
fi

# 2. Check Vector DB storage permissions
echo -n "[*] Checking Vector DB Access... "
if [ -w "/opt/civilization/openwebui" ]; then
    echo "[OK] Write access confirmed."
else
    echo "[WARN] /opt/civilization/openwebui might not be writable by current user. (Docker handles this, usually OK)"
fi

# 3. Simulate GPU Load Check (Passive)
echo "[*] Current GPU State:"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv | grep "ollama" || echo "    (Ollama is idle or not using GPU right now)"
else
    echo "    [WARN] nvidia-smi not found."
fi

echo ""
echo "Diagnostic Complete."
