import requests
import sys

# Since we run this from the HOST, we use localhost:8080
# Inside Docker (Open WebUI), it uses civ_library:8080
KIWIX_URL = "http://localhost:8080"

def test_connection():
    try:
        print(f"[*] Connecting to {KIWIX_URL}...")
        resp = requests.get(KIWIX_URL, timeout=5)
        print(f"    [OK] Status Code: {resp.status_code}")
        
        if "library" in resp.text.lower() or "kiwix" in resp.text.lower():
             print("    [OK] Content looks like Kiwix.")
        else:
             print("    [WARN] Content does not match expected Kiwix signature.")
             
    except Exception as e:
        print(f"    [FAIL] Could not connect: {e}")
        return False
    return True

if __name__ == "__main__":
    if test_connection():
        print("\nTest Passed: Kiwix is accessible from host.")
        print("Note: If 'kiwix_tool.py' fails inside Docker, check network aliases.")
    else:
        print("\nTest Failed.")
        sys.exit(1)
