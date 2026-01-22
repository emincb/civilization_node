import requests
from bs4 import BeautifulSoup

KIWIX_HOST = "http://localhost:8080"

def _resolve_book_id(partial_name):
    print(f"DEBUG: Resolving book ID for '{partial_name}'")
    try:
        url = f"{KIWIX_HOST}/catalog/v2/entries"
        print(f"Fetching {url}...")
        r = requests.get(url, timeout=2)
        print(f"Status: {r.status_code}")
        
        if r.status_code != 200:
            return None
        
        soup = BeautifulSoup(r.content, 'xml')
        
        for entry in soup.find_all('entry'):
            title = entry.find('title').text if entry.find('title') else ""
            print(f"  - Found Title: {title}")
            
            if partial_name.lower() in title.lower():
                link = entry.find('link', type="text/html")
                if link and link.get('href'):
                    raw_id = link['href'].split('/content/')[-1]
                    print(f"  -> MATCH! ID: {raw_id}")
                    return raw_id
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == "__main__":
    print("Testing identification of 'wikipedia'...")
    _resolve_book_id("wikipedia")
