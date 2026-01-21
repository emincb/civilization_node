#!/bin/bash
set -e

# Civilization Node - Infrastructure Setup Script
# Version 1.0

echo "=== Civilization Node Pre-flight Checks ==="

# 1. Check for NVIDIA Driver / GPU
echo "[*] Checking NVIDIA GPU environment..."
if command -v nvidia-smi &> /dev/null; then
    echo "    [OK] nvidia-smi found."
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
else
    echo "    [ERROR] nvidia-smi not found! Ensure NVIDIA drivers are installed."
    exit 1
fi

# 2. Check for Docker
echo "[*] Checking Docker installation..."
if command -v docker &> /dev/null; then
    echo "    [OK] Docker found: $(docker --version)"
else
    echo "    [ERROR] Docker not found."
    exit 1
fi

# 3. Check for Docker Compose
echo "[*] Checking Docker Compose..."
if docker compose version &> /dev/null; then
    echo "    [OK] Docker Compose found."
else
    echo "    [ERROR] 'docker compose' command failed. Required for orchestration."
    exit 1
fi

# 4. Filesystem Preparation
BASE_DIR="/opt/civilization"
echo "[*] Verifying/Creating directory structure at $BASE_DIR..."

DIRS=(
    "$BASE_DIR/library/zims"
    "$BASE_DIR/library/pdfs"
    "$BASE_DIR/models"
    "$BASE_DIR/openwebui"
    "$BASE_DIR/incoming"
)

REQUIRED_SUDO=false

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        echo "    [PENDING] Directory missing: $dir"
        REQUIRED_SUDO=true
    else
        echo "    [OK] Directory exists: $dir"
    fi
done

if [ "$REQUIRED_SUDO" = true ]; then
    echo ""
    echo "[!] Some directories need to be created. This requires SUDO privileges."
    echo "[!] Please run the following command manually (or I can try to run it if you have sudo access configured):"
    echo ""
    echo "sudo mkdir -p $BASE_DIR/library/{zims,pdfs} $BASE_DIR/{models,openwebui,incoming}"
    echo "sudo chown -R $USER:$USER $BASE_DIR"
    echo ""
    read -p "Do you want to attempt running these commands with sudo now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo mkdir -p "$BASE_DIR/library/zims" "$BASE_DIR/library/pdfs" "$BASE_DIR/models" "$BASE_DIR/openwebui" "$BASE_DIR/incoming"
        sudo chown -R "$USER":"$USER" "$BASE_DIR"
        echo "    [OK] Directories created and ownership set to $USER."
    else
        echo "    [WARN] Skipping directory creation. Deployment may fail."
    fi
else
    echo "    [OK] All directories exist."
fi

echo ""
echo "=== Setup Complete ==="
