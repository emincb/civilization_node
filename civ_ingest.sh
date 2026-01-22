#!/bin/bash
set -e

# Civilization Node - Content Ingestion Script
# Version 1.0

# Load Environment Variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

CIV_ROOT="${CIV_ROOT:-/opt/civilization}"
INCOMING_DIR="${CIV_ROOT}/incoming"
LIBRARY_DIR="${CIV_ROOT}/library"

echo "=== Civilization Node Content Ingestion ==="
echo "Scanning $INCOMING_DIR..."

# Check if incoming is empty
if [ -z "$(ls -A $INCOMING_DIR)" ]; then
    echo "[!] No files found in $INCOMING_DIR."
    echo "    Please copy files there first."
    exit 0
fi

# Select file to process
PS3="Select a file to ingest (or 0 to quit): "
select FILE in "$INCOMING_DIR"/*; do
    if [ -z "$FILE" ]; then
        echo "Exiting."
        exit 0
    fi
    
    FILENAME=$(basename "$FILE")
    echo "Processing: $FILENAME"
    break
done

echo ""
echo "Select Content Type:"
echo "1) ZIM File (Kiwix)"
echo "2) PDF Document"
read -p "Choice [1-2]: " TYPE_CHOICE

if [ "$TYPE_CHOICE" == "1" ]; then
    # ZIM Workflow
    DEST_BASE="$LIBRARY_DIR/zims"
    echo ""
    echo "--- ZIM Metadata ---"
    read -p "Source (e.g. wikipedia, stackoverflow): " SOURCE
    read -p "Language (e.g. en, fr): " LANG
    read -p "Topic (e.g. all, python, math): " TOPIC
    read -p "Date (YYYY-MM): " DATE
    
    NEW_NAME="${SOURCE}_${LANG}_${TOPIC}_${DATE}.zim"
    
    # Sub-category selection
    echo ""
    echo "Select ZIM Category:"
    echo "1) Encyclopedia"
    echo "2) Tech/Coding"
    echo "3) Books"
    echo "4) Other"
    read -p "Choice [1-4]: " CAT_CHOICE
    case $CAT_CHOICE in
        1) SUBCAT="encyclopedia";;
        2) SUBCAT="tech";;
        3) SUBCAT="books";;
        *) SUBCAT="other";;
    esac
    
    FINAL_PATH="$DEST_BASE/$SUBCAT/$NEW_NAME"

elif [ "$TYPE_CHOICE" == "2" ]; then
    # PDF Workflow
    DEST_BASE="$LIBRARY_DIR/pdfs"
    echo ""
    echo "--- PDF Metadata ---"
    echo "Please use lowercase and no spaces."
    read -p "Author/Org (e.g. intel, tolkien): " AUTHOR
    read -p "Title Slug (e.g. datasheet_i9, lord_of_rings): " TITLE
    read -p "Year (YYYY): " YEAR
    
    # Sub-category selection
    echo ""
    echo "Select PDF Category:"
    echo "1) Manuals"
    echo "2) Research/Papers"
    echo "3) Books"
    echo "4) Uncategorized"
    read -p "Choice [1-4]: " CAT_CHOICE
    case $CAT_CHOICE in
        1) SUBCAT="manuals";;
        2) SUBCAT="research";;
        3) SUBCAT="books";;
        *) SUBCAT="uncategorized";;
    esac
    
    NEW_NAME="${SUBCAT}_${AUTHOR}_${TITLE}_${YEAR}.pdf"
    FINAL_PATH="$DEST_BASE/$SUBCAT/$NEW_NAME"

else
    echo "Invalid choice."
    exit 1
fi

echo ""
echo "--- Confirmation ---"
echo "Source: $FILE"
echo "Dest:   $FINAL_PATH"
echo ""

if [ -f "$FINAL_PATH" ]; then
    echo "[!] WARNING: Destination file already exists!"
    read -p "Overwrite? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
fi

read -p "Proceed with move? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Ensure dest dir exists (requires sudo if user doesn't own it, but per setup_env they should)
    mkdir -p "$(dirname "$FINAL_PATH")"
    mv "$FILE" "$FINAL_PATH"
    chmod 644 "$FINAL_PATH"
    echo "[OK] File moved successfully."
else
    echo "Cancelled."
fi
