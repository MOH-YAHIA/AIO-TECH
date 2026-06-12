import os
from dotenv import load_dotenv
import requests
from typing import List, Dict, Any

load_dotenv()
class SerpLinkFetcher:
    def __init__(self):
        self.api_key = os.getenv("SERPAPI_API_KEY")
        self.endpoint = "https://serpapi.com/search"

    def discover_egyptian_market_links(self, clean_product_name: str) -> Dict[str, Any]:
        """
        Queries Google via SerpApi using a clean search query to protect image layouts,
        then extracts localized URLs and high-res image components.
        """
        if not self.api_key:
            print("⚠️ SERPAPI_API_KEY missing.")
            return {"links": {}, "image_url": None}

        # 🧠 Invariant: Keep the search terms clean to force Google to show product cards and knowledge graphs
        params = {
            "q": clean_product_name,
            "engine": "google",
            "gl": "eg",  # Target Egypt
            "hl": "en",
            "api_key": self.api_key
        }

        links_discovered = {"amazon": None, "noon": None, "btech": None}
        extracted_image_url = None

        try:
            response = requests.get(self.endpoint, params=params, timeout=6)
            if response.status_code == 200:
                results = response.json()
                
                # 🖼️ LAYER 1 IMAGE DETECTION: Check the structured Google Knowledge Graph first (Highest Quality)
                knowledge_graph = results.get("knowledge_graph", {})
                if knowledge_graph.get("header_images"):
                    extracted_image_url = knowledge_graph["header_images"][0].get("image")
                elif knowledge_graph.get("image"):
                    extracted_image_url = knowledge_graph.get("image")

                # Parse the regular web results rows
                organic_results = results.get("organic_results", [])
                for result in organic_results:
                    link = result.get("link", "").lower()
                    
                    # 🖼️ LAYER 2 IMAGE DETECTION FALLBACK: If Knowledge Graph is empty, steal the top web result thumbnail
                    if not extracted_image_url and result.get("thumbnail"):
                        extracted_image_url = result.get("thumbnail")
                    
                    # Sort links using sub-string matching boundaries
                    if "amazon.eg" in link and not links_discovered["amazon"]:
                        links_discovered["amazon"] = result.get("link")
                    elif "noon.com" in link and "egypt" in link and not links_discovered["noon"]:
                        links_discovered["noon"] = result.get("link")
                    elif "btech.com" in link and not links_discovered["btech"]:
                        links_discovered["btech"] = result.get("link")

        except Exception as err:
            print(f"❌ SerpApi Image/Link extraction error: {err}")
            
        return {
            "links": links_discovered,
            "image_url": extracted_image_url
        }
    
# --- TEST HARNESS ---
if __name__ == "__main__":
    fetcher = SerpLinkFetcher()
    product_to_check = "samsung galaxy s24 ultra 256gb"
    report = fetcher.discover_egyptian_market_links(product_to_check)
    print(report)