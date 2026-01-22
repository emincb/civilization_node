#!/bin/bash
set -e

# Civilization Node - Infrastructure Setup Script
# Version 1.1

# Load Environment Variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Defaults
CIV_ROOT="${CIV_ROOT:-/opt/civilization}"
SKIP_GPU_CHECK="${SKIP_GPU_CHECK:-false}"

echo "=== Civilization Node Pre-flight Checks ==="
echo "Target Configuration:"
echo "  Root Directory: $CIV_ROOT"
echo "  Skip GPU Check: $SKIP_GPU_CHECK"
echo ""

# 1. Check for NVIDIA Driver / GPU
echo "[*] Checking NVIDIA GPU environment..."
if command -v nvidia-smi &> /dev/null; then
    echo "    [OK] nvidia-smi found."
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
elif [ "$SKIP_GPU_CHECK" = "true" ]; then
    echo "    [WARN] nvidia-smi not found, but SKIP_GPU_CHECK is enabled. Proceeding for CPU-only mode."
else
    echo "    [ERROR] nvidia-smi not found! Ensure NVIDIA drivers are installed."
    echo "            To run on CPU or non-NVIDIA hardware, set SKIP_GPU_CHECK=true in .env"
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
echo "[*] Verifying/Creating directory structure at $CIV_ROOT..."

DIRS=(
    "$CIV_ROOT/library/zims"
    "$CIV_ROOT/library/pdfs"
    "$CIV_ROOT/models"
    "$CIV_ROOT/openwebui"
    "$CIV_ROOT/incoming"
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
    echo "[!] Some directories need to be created. This might require SUDO privileges depending on the location."
    echo "[!] Target path: $CIV_ROOT"
    echo ""
    read -p "Do you want to attempt creating these directories now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Check write permission on parent dir of CIV_ROOT
        PARENT_DIR=$(dirname "$CIV_ROOT")
        if [ -w "$PARENT_DIR" ]; then
             mkdir -p "${DIRS[@]}"
             echo "    [OK] Directories created."
        else
             echo "    [INFO] Sudo required for $CIV_ROOT creation."
             sudo mkdir -p "${DIRS[@]}"
             sudo chown -R "$USER":"$USER" "$CIV_ROOT"
             echo "    [OK] Directories created with sudo and ownership set to $USER."
        fi
    else
        echo "    [WARN] Skipping directory creation. Deployment may fail."
    fi
else
    echo "    [OK] All directories exist."
fi

echo ""
echo "=== Setup Complete ==="
