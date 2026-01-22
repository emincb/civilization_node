#!/bin/bash
# Wrapper to launch the python downloader
echo "=== Content Acquisition Tool ==="
echo "Repo: https://download.kiwix.org/zim/"
echo ""

# Resolve Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

python3 "$REPO_ROOT/download_content.py"
