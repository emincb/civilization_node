"""
title: Kiwix Knowledge Retrieval
author: Civilization Node Operator
description: Search offline ZIM archives (Wikipedia, StackOverflow, iFixit) and return ACTUAL CONTENT to the LLM.
"""

import requests
from bs4 import BeautifulSoup
import urllib.parse
import re

class Tools:
    def __init__(self):
        self.kiwix_host = "http://civ_library:8080"
        self.valves = self.Valves()

    class Valves:
        default_zim: str = "wikipedia"

    """
    title: Kiwix Knowledge Retrieval
    author: Civilization Node Operator
    description: Search offline ZIM archives. You MUST provide a 'query'.
    """

    def search_knowledge_base(self, query: str, context: str = "general") -> str:
        """
        Search for a topic in the offline library.
        :param query: The specific search terms (e.g. "Python list comprehension", "Paris population"). CANNOT BE EMPTY.
        :param context: Choose one of: "general" (Wikipedia), "code" (StackOverflow), "repair" (iFixit), "medical" (WikiMed), "chemistry", "books".
        :return: The content of the article or an error message.
        """
        if not query or not query.strip():
            return "Error: You called the search tool with an empty query. Please call it again with specific keywords."

        # Map context to partial names/keywords in Title
        zim_map = {
            "general": "wikipedia",
            "code": "stack overflow",   # Fixed: 'stackoverflow' -> 'stack overflow' (space)
            "repair": "ifixit",
            "medical": "medical",       # Fixed: 'medicine' -> 'medical'
            "linux": "arch",            # Fixed: 'archlinux' -> 'arch' (broader match)
            "science": "phet",
            "books": "gutenberg"
        }
        
        # 1. Try to find a specific match in the map, OR use the context itself as the keyword
        # e.g. "code" -> "stack overflow", but "gardening" -> "gardening"
        search_keyword = zim_map.get(context, context)
        
        # 2. Resolve to the EXACT Book ID from the Server
        target_id = _resolve_book_id(self.kiwix_host, search_keyword)
        
        # 3. Fallback: If specific library not found, default to Wikipedia main
        if not target_id and search_keyword != "wikipedia":
             print(f"DEBUG: Library for '{search_keyword}' not found, falling back to Wikipedia.")
             target_id = _resolve_book_id(self.kiwix_host, "wikipedia")

        if not target_id:
            available = _get_available_books(self.kiwix_host)
            return f"Error: No matching ZIM found for '{context}' or 'wikipedia'. Available: {available}"

        try:
            # 2. Search
            # Debug Print
            print(f"DEBUG: Searching for '{query}' in {target_id}")
            search_url = f"{self.kiwix_host}/search?content={target_id}&pattern={urllib.parse.quote(query)}"
            search_resp = requests.get(search_url, timeout=5)
            
            # 3. Parse and Re-Rank Links
            soup = BeautifulSoup(search_resp.content, 'html.parser')
            candidates = []
            
            query_terms = query.lower().split()

            for link in soup.find_all('a', href=True):
                href = link['href']
                # Basic validity check
                if target_id not in href or "search?" in href or "skin/" in href or ".css" in href:
                    continue
                
                # Scoring Logic
                score = 0
                href_lower = href.lower()
                
                # Criterion A: Query Term Match (The most important)
                # If searching "Honda Civic Headlight", a link with "Headlight" gets points.
                matches = sum(1 for term in query_terms if term in href_lower)
                score += (matches * 10) 
                
                # Criterion B: Content Type Preference
                if context == "repair":
                    if "/Guide/" in href: score += 50      # Guides are Gold
                    if "Replacement" in href: score += 20  # specific action
                    if "/Device/" in href: score -= 5      # Devices are just lists (backup only)
                
                # Criterion C: Exact Match / Shortness
                # Shorter URLs often mean main pages, not obscure sub-pages
                score -= len(href) * 0.1 

                candidates.append((score, href))

            if not candidates:
                 return f"No articles found for '{query}' in {target_id}."

            # Sort by score descending (Best first)
            candidates.sort(key=lambda x: x[0], reverse=True)
            first_result = candidates[0][1]
            
            if not first_result:
                return f"No articles found for '{query}' in {target_id}."

            # 4. Fetch Content
            article_url = f"{self.kiwix_host}{first_result}" if first_result.startswith("/") else f"{self.kiwix_host}/{first_result}"
            article_resp = requests.get(article_url, timeout=10)
            article_soup = BeautifulSoup(article_resp.content, 'html.parser')

            # 5. Clean Content
            for script in article_soup(["script", "style", "nav", "footer", "header", "form"]):
                script.decompose()

            text = article_soup.get_text(separator=' ', strip=True)
            
            # 6. Format
            return f"### SOURCE: {target_id}\n### CONTENT:\n{text[:6000]}..."

        except Exception as e:
            return f"System Error: {e}"

def _resolve_book_id(host: str, partial_name: str) -> str:
    print(f"DEBUG: Resolving book ID for '{partial_name}'")
    try:
        # Kiwix-serve returns an OPDS Atom feed (XML), not JSON
        r = requests.get(f"{host}/catalog/v2/entries", timeout=2)
        if r.status_code != 200:
            return None
        
        # Parse XML
        soup = BeautifulSoup(r.content, 'xml')
        
        for entry in soup.find_all('entry'):
            # Title often contains readable name: "Wikipedia English"
            title = entry.find('title').text if entry.find('title') else ""
            
            if partial_name.lower() in title.lower():
                # Extract ID from the <link type="text/html" href="/content/ID">
                # We search for the link that points to the content root
                link = entry.find('link', type="text/html")
                if link and link.get('href'):
                    # href is like "/content/wikipedia_en_all_nopic_2025-12"
                    # We need just the ID part
                    raw_id = link['href'].split('/content/')[-1]
                    return raw_id
        return None
    except:
        return None

def _get_available_books(host: str):
    try:
            r = requests.get(f"{host}/catalog/v2/entries", timeout=1)
            soup = BeautifulSoup(r.content, 'xml')
            titles = [e.find('title').text for e in soup.find_all('entry') if e.find('title')]
            return titles
    except:
            return "Unable to list (XML Parse Error)."
