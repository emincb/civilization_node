#!/usr/bin/env python3
import requests
import re
from urllib.parse import urljoin

BASE = "https://download.kiwix.org/zim/"

# High Value Targets
TARGETS = [
    # (Category, NameFilter, Label)
    ("wikipedia/", "wikipedia_en_all_nopic_2025", "Wikipedia (Full, No Pic)"),
    ("wikipedia/", "wikipedia_en_top_maxi_2025", "Wikipedia (Top Articles, Images)"),
    ("wikipedia/", "wikimed_en_all_maxi_2025", "WikiMed (Medical Encylopedia)"),
    ("stack_exchange/", "stackoverflow.com_en_all_2025", "StackOverflow (Coding)"),
    ("stack_exchange/", "math.stackexchange.com_en_all_2025", "Math StackExchange"),
    ("stack_exchange/", "physics.stackexchange.com_en_all_2025", "Physics StackExchange"),
    ("stack_exchange/", "chemistry.stackexchange.com_en_all_2025", "Chemistry StackExchange"),
    ("stack_exchange/", "engineering.stackexchange.com_en_all_2025", "Engineering StackExchange"),
    ("stack_exchange/", "diy.stackexchange.com_en_all_2025", "Home Improv. StackExchange"),
    ("ifixit/", "ifixit_en_all_2025", "iFixit (Repair Guides)"),
    ("phet/", "phet_en_2025", "PhET (Science Simulations)"),
    ("gutenberg/", "gutenberg_en_all_2025", "Project Gutenberg (Books)"),
    ("ted/", "ted_en_playlist-technology_2025", "TED Tech (Videos)"),
]

def get_latest_size(category, pattern):
    url = urljoin(BASE, category)
    try:
        r = requests.get(url, timeout=10)
    except:
        return "Error", "0"

    # Regex to find files matching pattern and capture size
    # Pattern might match multiple (dates), we want the last one usually (latest)
    # Line fmt: <a href="file.zim">file.zim</a> date size
    matches = []
    for line in r.text.splitlines():
        if pattern in line:
            # Extract Size: Last item usually.
            # Example: ... 2025-01-01 12:00  50G
            # Regex to capture size at end of line (ignoring tags)
            m = re.search(r'([0-9.]+[GMK])\s*$', line) # Simple checking end of line
            # Or better, look for the 'href' to ensure it's the right file, then grab the size column
            
            # Robust extraction:
            file_m = re.search(r'href="([^"]+)"', line)
            if file_m and pattern in file_m.group(1):
                filename = file_m.group(1)
                # Find size in the raw text after the link
                # </a>            2026-01-06 23:51   40M
                size_m = re.search(r'</a>\s+[\d-]+\s+[\d:]+\s+([0-9.]+[GMK])', line)
                if size_m:
                    matches.append((filename, size_m.group(1)))
    
    if not matches:
        return "Not Found", "0"
        
    # Sort by filename (dates are usually in filename or increasing)
    matches.sort()
    return matches[-1] # Return latest

print(f"{'DATASET':<35} | {'FILENAME':<40} | {'SIZE':<10}")
print("-" * 90)

total_est = 0

for cat, pat, label in TARGETS:
    fname, size = get_latest_size(cat, pat)
    print(f"{label:<35} | {fname:<40} | {size:<10}")

print("-" * 90)
print("NOTE: '2025' was used as a filter. If files are older/newer (2026), script might miss them.")
print("      Modify script to widen search if 'Not Found'.")
