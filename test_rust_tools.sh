#!/bin/bash
set -e

BIN_DIR="./bin"
TEST_DIR="./test_data"

echo "=== Testing Rust Tools ==="

# Cleanup previous tests
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"

# 1. Test Deduplication
echo "[*] Testing civ_dedup..."
echo "content" > "$TEST_DIR/fileA.txt"
echo "content" > "$TEST_DIR/fileB.txt" # Duplicate
echo "unique" > "$TEST_DIR/fileC.txt"

OUTPUT=$($BIN_DIR/civ_dedup "$TEST_DIR")
echo "$OUTPUT"

if echo "$OUTPUT" | grep -q "fileA.txt" && echo "$OUTPUT" | grep -q "fileB.txt"; then
    echo "    [PASS] Detects duplicates."
else
    echo "    [FAIL] Did not detect duplicates."
    exit 1
fi

# 2. Test Validation
echo ""
echo "[*] Testing civ_validate..."
# Create fake PDF
echo "%PDF-1.4 Fake Content" > "$TEST_DIR/good.pdf"
echo "Not A PDF" > "$TEST_DIR/bad.pdf"

OUTPUT=$($BIN_DIR/civ_validate "$TEST_DIR")
# We filter grep output to just show the status lines
echo "$OUTPUT" | grep "path" -A 1

if echo "$OUTPUT" | grep -q "good.pdf" && echo "$OUTPUT" | grep -q "valid"; then
    echo "    [PASS] Validates good PDF."
else
    echo "    [FAIL] Failed to validate good PDF."
    exit 1
fi

if echo "$OUTPUT" | grep -q "bad.pdf" && echo "$OUTPUT" | grep -q "invalid"; then
    echo "    [PASS] Catches bad PDF."
else
    echo "    [FAIL] Failed to catch bad PDF."
    exit 1
fi

echo ""
echo "=== All Tests Passed ==="
