#!/usr/bin/env python3
import requests
import re
import os
import subprocess
import hashlib
import sys
from urllib.parse import urljoin

# Config
BASE_URL = "https://download.kiwix.org/zim/"
INCOMING_DIR = "/opt/civilization/incoming"
LIBRARY_DIR = "/opt/civilization/library/zims"

# The 29-Item Manifest
# Format: (CategoryDirectory, FilePattern, Description)
MANIFEST = [
    # 1. Critical Core
    ("wikipedia/", "wikipedia_en_all_nopic_2025", "Wikipedia English (Text Only)"),
    ("wikipedia/", "wikipedia_tr_all_maxi_2025", "Wikipedia Turkish (Full)"),
    ("wikipedia/", "wikipedia_en_medicine_maxi", "WikiMed Medical"),
    ("ifixit/", "ifixit_en_all_2025", "iFixit Repair"),
    ("other/", "appropedia_en_all_maxi", "Appropedia Sustainability"),
    ("wikivoyage/", "wikivoyage_en_all_maxi_2025", "Wikivoyage Global"),
    ("other/", "openstreetmap-wiki_en_all_maxi", "OpenStreetMap Wiki"),
    ("phet/", "phet_en_all", "PhET Simulations"),
    ("other/", "wikispecies_en_all_maxi", "Wikispecies Taxonomy"),
    
    # 2. Engineering & Dev
    ("stack_exchange/", "stackoverflow.com_en_all", "StackOverflow"),
    ("stack_exchange/", "superuser.com_en_all", "SuperUser SysAdmin"),
    ("stack_exchange/", "askubuntu.com_en_all", "AskUbuntu"),
    ("other/", "mdn_en_all", "MDN Web Docs"),
    ("other/", "archlinux_en_all", "ArchLinux Wiki"),
    ("stack_exchange/", "raspberrypi.stackexchange.com_en_all", "Raspberry Pi Q&A"),
    
    # 3. Dev Pack
    ("other/", "python_en_docs", "Python Docs"),
    ("other/", "rust_en_all", "Rust Docs"),
    ("stack_exchange/", "devops.stackexchange.com_en_all", "Docker/DevOps"),
    ("other/", "bash_en_all", "Bash Docs"),
    ("other/", "git_en_all", "Git Docs"),
    ("other/", "postgresql_en_all", "Postgres Docs"),
    ("other/", "arduino_en_all", "Arduino Docs"),
    ("stack_exchange/", "electronics.stackexchange.com_en_all", "Electronics Q&A"),
    
    # 4. Education & Culture
    ("gutenberg/", "gutenberg_en_all_2023", "Project Gutenberg (2023 Archive)"),
    ("wikibooks/", "wikibooks_en_all_maxi", "Wikibooks"),
    ("wikisource/", "wikisource_en_all_maxi", "Wikisource"),
    ("wikipedia/", "wikipedia_en_top_maxi", "Wikipedia Top Articles (Images)"),
    ("other/", "rationalwiki_en_all", "RationalWiki"),
    ("ted/", "ted_en_playlists", "TED Talks"),
]

def find_latest_file(category, pattern):
    url = urljoin(BASE_URL, category)
    try:
        r = requests.get(url, timeout=10)
    except Exception as e:
        print(f"[!] Error accessing {url}: {e}")
        return None, 0

    best_match = None
    best_match_size = "?"
    
    try:
        lines = r.text.splitlines()
        for line in lines:
            if pattern in line:
                m = re.search(r'href="([^"]+)"', line)
                if m:
                    filename = m.group(1)
                    if not filename.endswith(".zim"):
                        continue
                        
                    s_m = re.search(r'</a>\s+[\d-]+\s+[\d:]+\s+([0-9.]+[GMK]?)', line)
                    size_str = s_m.group(1) if s_m else "0M"
                    
                    if best_match is None or filename > best_match:
                        best_match = filename
                        best_match_size = size_str
    except:
        pass
                        
    if best_match:
        return urljoin(url, best_match), best_match_size
    return None, 0

def parse_size_to_gb(size_str):
    try:
        s = size_str.upper().strip()
        if s.endswith("G"):
            return float(s[:-1])
        elif s.endswith("M"):
            return float(s[:-1]) / 1024.0
        elif s.endswith("K"):
            return float(s[:-1]) / (1024.0 * 1024.0)
        elif s.replace('.','',1).isdigit():
             return float(s) / (1024.0 * 1024.0 * 1024.0) # Assume bytes? unlikely
        return 0.0
    except:
        return 0.0

def verify_sha256(filepath, expected_hash):
    print(f"    [*] Verifying SHA256 checksum for {os.path.basename(filepath)}...")
    sha256_hash = hashlib.sha256()
    file_size = os.path.getsize(filepath)
    processed = 0
    
    with open(filepath, "rb") as f:
        while True:
            # Read in 16MB chunks for speed
            chunk = f.read(16 * 1024 * 1024)
            if not chunk:
                break
            sha256_hash.update(chunk)
            processed += len(chunk)
            
            # Update progress bar
            percent = (processed / file_size) * 100
            bar_length = 40
            filled_length = int(bar_length * processed // file_size)
            bar = '=' * filled_length + '-' * (bar_length - filled_length)
            sys.stdout.write(f'\r    [{bar}] {percent:.1f}%')
            sys.stdout.flush()
    
    print() # New line after verify
    
    calculated = sha256_hash.hexdigest()
    if calculated == expected_hash:
        print("    [PASS] Integrity Verified.")
        return True
    else:
        print(f"    [FAIL] Checksum Mismatch!")
        return False

def get_remote_sha256(url):
    try:
        r = requests.get(url + ".sha256", timeout=5)
        if r.status_code == 200:
            parts = r.text.split()
            if len(parts) >= 1:
                return parts[0]
    except:
        pass
    return None

def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Don't download, just list")
    args = parser.parse_args()

    print("=== Civilization Node: Manifest Downloader (Secure) ===")
    
    if not os.path.exists(INCOMING_DIR):
        os.makedirs(INCOMING_DIR)

    total_gb = 0.0

    for category, pattern, description in MANIFEST:
        print(f"\n[*] Searching for: {description} ({pattern})...")
        url, size_str = find_latest_file(category, pattern)
        
        if not url:
            print(f"    [!] NOT FOUND in {category}")
            continue
            
        filename = url.split("/")[-1]
        
        # Calculate Size
        gb = parse_size_to_gb(size_str)
        total_gb += gb
        
        print(f"    Found: {filename} ({size_str}) -> {gb:.2f} GB")
        
        if args.dry_run:
            continue
            
        # ... (Download logic omitted for dry run focus, but strictly needs to remain for real run)
        # I am rewriting the whole file, so I need to put the download logic back in!
        
        dest_path = os.path.join(INCOMING_DIR, filename)
        lib_path = os.path.join(LIBRARY_DIR, filename)

        if os.path.exists(lib_path):
             print("    [!] File exists in library/ (Skipping)")
             continue
             
        expected_hash = get_remote_sha256(url)
        if not expected_hash:
            print("    [!] WARNING: No remote SHA256 found.")
            # Verify if user wants to strict fail here? 
            # For now, let's proceed but warn.
            
        if os.path.exists(dest_path):
             print(f"    [!] File exists in incoming. Verifying...")
             if expected_hash and verify_sha256(dest_path, expected_hash):
                 print("    [OK] File good.")
                 continue
             else:
                 print("    [!] Checksum failed/missing. Re-downloading...")
                 os.remove(dest_path)

        print(f"    [+] Downloading to {INCOMING_DIR}...")
        try:
            subprocess.run(["wget", "-c", "--show-progress", "-O", dest_path, url], check=True)
            if expected_hash:
                if not verify_sha256(dest_path, expected_hash):
                    print("    [!!!] CORRUPTION DETECTED. DELETING.")
                    os.remove(dest_path)
                    sys.exit(1)
        except Exception as e:
            print(f"    [!] Failed: {e}")

    print("-" * 40)
    print(f"TOTAL MANIFEST SIZE: {total_gb:.2f} GB")
    print("-" * 40)

if __name__ == "__main__":
    main()
