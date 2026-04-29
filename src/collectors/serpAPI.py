import os
import json
from serpapi import Client
from dotenv import load_dotenv

load_dotenv()

class ProfessionalEgyptHarvester:
    def __init__(self):
        self.api_key = os.getenv("SERPAPI_KEY")
        # Ensure the client is initialized correctly
        self.client = Client(api_key=self.api_key)
        
        # Site Map: Using base domains for easier string matching
        self.site_map = {
            "amazon.eg": "amazon",
            "noon.com": "noon",
            "rayashop.com": "rayashop",
            "btech.com": "btech"
        }
        
        # Invariants: Indicators of a Product Detail Page (PDP)
        self.pdp_patterns = ["/dp/", "/p/", ".html", "-p-", "/product/"]
        # Negative constraints: Keywords that suggest listing/search pages
        self.listing_indicators = ["/search", "/category", "/catalog", "query=", "?q=", "sort=", "filter"]

    def harvest(self, product_name):
        # Construct query using site: operator for targeted crawling
        site_queries = [f"site:{domain}" for domain in self.site_map.keys()]
        query = f'"{product_name}" (' + " OR ".join(site_queries) + ')'
        
        print(f"Executing Logic-Based Search: {query}")

        params = {
            "engine": "google",
            "q": query,
            "location": "Egypt",
            "google_domain": "google.com.eg",
            "gl": "eg",
            "hl": "en",
            "num": 50 
        }

        harvested_data = {}

        try:
            results = self.client.search(params)
            organic = results.get("organic_results", [])

            for res in organic:
                link = res.get("link", "")
                link_lower = link.lower()
                
                # Identify platform via domain check
                platform_name = None
                for domain, name in self.site_map.items():
                    if domain in link_lower:
                        platform_name = name
                        break
                
                # Logic: If platform matches and we don't have a link for it yet
                if platform_name and platform_name not in harvested_data:
                    
                    # Constraint check: Must look like a Product Page
                    is_pdp = any(pat in link_lower for pat in self.pdp_patterns)
                    # Constraint check: Must NOT be a listing/search aggregator
                    is_not_list = not any(x in link_lower for x in self.listing_indicators)
                    
                    if is_pdp and is_not_list:
                        harvested_data[platform_name] = {
                            "platform": platform_name,
                            "title": res.get("title"),
                            "url": link
                        }
                        print(f"Found valid PDP for {platform_name.upper()}")

                # Early Exit Invariant: Stop once all targets are found
                if len(harvested_data) == len(self.site_map):
                    break

            return harvested_data

        except Exception as e:
            print(f"API Error: {e}")
            return {}

if __name__ == "__main__":
    # Ensure data directory exists
    os.makedirs("data", exist_ok=True)
    
    harvester = ProfessionalEgyptHarvester()
    PRODUCT = "iPhone 17 Pro" 
    
    links = harvester.harvest(PRODUCT)
    
    output_path = "data/product_urls.json"
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(links, f, indent=4, ensure_ascii=False)
        
    print(f"\nCoverage: {len(links)}/{len(harvester.site_map)} sites found.")
    print(f"Results saved to: {output_path}")