#!/bin/bash
set -e

# Civilization Node - RAG Pipeline Setup
# Version 1.0

MODEL_NAME="nomic-embed-text"
CONTAINER_NAME="civ_ollama"

echo "=== RAG Pipeline Setup ==="

# 1. Check if Ollama is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "[!] Error: '$CONTAINER_NAME' container is not running."
    echo "    Please run: docker compose up -d"
    exit 1
fi

# 2. Check if model already exists
echo "[*] Checking available models..."
if docker exec "$CONTAINER_NAME" ollama list | grep -q "$MODEL_NAME"; then
    echo "    [OK] Model '$MODEL_NAME' is already installed."
else
    echo "    [*] Pulling '$MODEL_NAME'. This may take a moment..."
    docker exec "$CONTAINER_NAME" ollama pull "$MODEL_NAME"
    echo "    [OK] Model pulled successfully."
fi

echo ""
echo "=== Next Steps ==="
echo "1. Go to Open WebUI (http://localhost:3000)"
echo "2. Navigate to Admin Settings > Documents."
echo "3. Set 'Embedding Model' to '$MODEL_NAME'."
echo "4. Click Save."
