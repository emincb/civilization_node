#!/bin/bash
set -e

# Build Rust tools using Docker to avoid host dependencies
# Mounts the current ./tools directory into the container
# Outputs binaries to ./bin

echo "=== Building Rust Tools (Docker) ==="

mkdir -p bin

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "[!] Docker not found. Cannot build."
    exit 1
fi

echo "[*] Starting build container (rust:latest)..."
echo "    This may take a minute to pull the image and compile."

docker run --rm \
    -v "$(pwd)/tools":/usr/src/myapp \
    -w /usr/src/myapp \
    -e CARGO_GOME_DIR=/usr/src/myapp/.cargo \
    rust:latest \
    cargo build --release

echo "[*] Moving binaries..."
if [ -f "tools/target/release/civ_dedup" ]; then
    cp tools/target/release/civ_dedup bin/
    cp tools/target/release/civ_validate bin/
    echo "    [OK] Binaries installed to ./bin/"
    ls -l bin/
else
    echo "    [FAIL] Build output not found."
    exit 1
fi
