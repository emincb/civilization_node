#!/usr/bin/env python3
import os
import requests
import sys
import subprocess
import re
from urllib.parse import urljoin

# Config
BASE_URL = "https://download.kiwix.org/zim/"
CIV_ROOT = os.getenv("CIV_ROOT", "/opt/civilization")
INCOMING_DIR = os.path.join(CIV_ROOT, "incoming")

# Determine script location dynamically
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INGEST_SCRIPT = os.path.join(SCRIPT_DIR, "civ_ingest.sh")

# Safety Thresholds
WARN_SIZE_GB = 20.0
WARN_PERCENT_FREE = 0.10  # Warn if file takes > 10% of remaining space

def check_requirements():
    if not os.path.exists(INCOMING_DIR):
        print(f"[!] Incoming directory not found: {INCOMING_DIR}")
        sys.exit(1)
    if subprocess.call(["which", "wget"], stdout=subprocess.DEVNULL) != 0:
        print("[!] wget is not installed. Please install it.")
        sys.exit(1)

def transform_size_str(size_str):
    # Just for display, keep original
    return size_str.strip()

def get_items(url):
    try:
        r = requests.get(url, timeout=10)
        r.raise_for_status()
    except Exception as e:
        print(f"[!] HTTP Error: {e}")
        return [], []
    
    # Regex to find links and sizes.
    # Format: <a href="file.zim">file.zim</a>  YYYY-MM-DD HH:MM  SIZE
    # We capture group 1 (href) and group 2 (size, if present)
    # Directories might differ slightly or have "-" size.
    
    items = []
    
    # Generic link finder first
    # We look for lines containing hrefs to map them to sizes in that line
    lines = r.text.split('\n')
    
    dirs = []
    files = []
    
    for line in lines:
        # Check for directory
        dir_match = re.search(r'href="([^"]+/)"', line)
        if dir_match:
            d_name = dir_match.group(1)
            if not d_name.startswith("/") and not d_name.startswith("?"):
                dirs.append({'name': d_name, 'type': 'dir'})
                
        # Check for ZIM file
        file_match = re.search(r'href="([^"]+\.zim)"[^>]*>.*?</a>\s+[\d-]+\s+[\d:]+\s+([0-9.]+[GMK]?)', line)
        if file_match:
            f_name = file_match.group(1)
            f_size = file_match.group(2)
            files.append({'name': f_name, 'size_str': f_size, 'type': 'file'})
    
    return sorted(dirs, key=lambda x: x['name']), sorted(files, key=lambda x: x['name'])

def get_remote_file_size(url):
    try:
        r = requests.head(url, allow_redirects=True, timeout=5)
        if 'Content-Length' in r.headers:
            return int(r.headers['Content-Length'])
    except:
        pass
    return -1

def get_free_space_bytes(folder):
    s = os.statvfs(folder)
    return s.f_bavail * s.f_frsize

def browse_directory(current_url, path_history):
    print(f"\n=== Browsing: {current_url} ===")
    dirs, files = get_items(current_url)
    
    print(f"[{len(dirs)} Directories, {len(files)} ZIM Files]")
    
    options = []
    if path_history:
        options.append({'text': ".. (Go Back)", 'action': 'back'})
    
    for d in dirs:
        options.append({'text': f"DIR:  {d['name']}", 'action': 'dir', 'val': d['name']})
        
    for f in files:
        # Add size to display label
        options.append({'text': f"FILE: {f['name']} ({f['size_str']})", 'action': 'file', 'val': f['name']})
        
    # Pagination? For now list all, assuming terminal scrolls.
    # Wikipedia folder is huge, so we might want to filter eventually.
    
    for idx, opt in enumerate(options):
        print(f"{idx + 1}) {opt['text']}")
        
    print("0) Exit")
    
    try:
        choice_input = input("\nSelect option (or filter text): ")
        if choice_input.isdigit():
            choice = int(choice_input)
        else:
            # Simple filter
            print(f"\n--- Filtering for '{choice_input}' ---")
            filtered_indices = []
            for idx, opt in enumerate(options):
                if choice_input.lower() in opt['text'].lower():
                    print(f"{idx + 1}) {opt['text']}")
                    filtered_indices.append(idx + 1)
            
            if not filtered_indices:
                print("No matches.")
                return current_url
                
            choice = int(input("\nSelect filtered option: "))
            
    except ValueError:
        return current_url
        
    if choice == 0:
        sys.exit(0)
        
    selection_idx = choice - 1
    if selection_idx < 0 or selection_idx >= len(options):
        print("Invalid selection.")
        return current_url
        
    opt = options[selection_idx]
    
    if opt['action'] == 'back':
        return path_history.pop()
        
    if opt['action'] == 'dir':
        path_history.append(current_url)
        return urljoin(current_url, opt['val'])
        
    if opt['action'] == 'file':
        filename = opt['val']
        download_url = urljoin(current_url, filename)
        process_download(download_url, filename)
        return current_url
        
    return current_url

def process_download(url, filename):
    print(f"\n[*] Selected: {filename}")
    print("[*] Checking file size...")
    size_bytes = get_remote_file_size(url)
    size_gb = size_bytes / (1024**3)
    
    free_bytes = get_free_space_bytes(INCOMING_DIR)
    free_gb = free_bytes / (1024**3)
    
    print(f"    File Size:  {size_gb:.2f} GB")
    print(f"    Free Space: {free_gb:.2f} GB")
    
    # 1. HARD STOP
    if size_bytes > free_bytes:
        print("\n[!!!] ERROR: Not enough disk space!")
        print(f"       Required: {size_gb:.2f} GB")
        print(f"       Available: {free_gb:.2f} GB")
        input("Press Enter to continue...")
        return

    # 2. WARNING
    warnings = []
    if size_gb > WARN_SIZE_GB:
        warnings.append(f"File is huge via ({size_gb:.2f} GB).")
        
    if size_bytes > (free_bytes * WARN_PERCENT_FREE):
        warnings.append("File will take up >10% of remaining space.")
        
    if warnings:
        print("\n[!] WARNINGS:")
        for w in warnings:
            print(f"    - {w}")
        confirm = input("Are you SURE you want to download this? (yes/no): ")
        if confirm.lower() != "yes":
            print("Aborted.")
            return
    else:
        confirm = input(f"Download to {INCOMING_DIR}? (y/n): ")
        if confirm.lower() != 'y':
            return

    # Proceed
    dest_path = os.path.join(INCOMING_DIR, filename)
    print("\n[*] Starting Download...")
    try:
        subprocess.run(["wget", "-c", "--show-progress", "-O", dest_path, url], check=True)
        print("\n[OK] Download complete.")
        
        # Integration
        ingest = input("Run Ingestion Script now? (y/n): ")
        if ingest.lower() == 'y':
            subprocess.run([INGEST_SCRIPT])
            
    except Exception as e:
        print(f"\n[!] Error: {e}")

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Kiwix Content Downloader")
    parser.add_argument("--path", help="Start in specific subpath (e.g. 'ted/')", default="")
    args = parser.parse_args()

    check_requirements()
    
    # Construct start URL
    if args.path:
        # Ensure path ends with slash if it's a dir, or handle logic
        path = args.path.strip("/") + "/"
        current_url = urljoin(BASE_URL, path)
    else:
        current_url = BASE_URL
        
    history = []
    
    while True:
        try:
            current_url = browse_directory(current_url, history)
        except KeyboardInterrupt:
            print("\nExiting.")
            break

if __name__ == "__main__":
    main()
