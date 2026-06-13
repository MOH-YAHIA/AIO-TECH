import os
import json
import requests
from dotenv import load_dotenv

load_dotenv()

class GlobalProductDetailsExtractor:
    def __init__(self):
        self.api_key = os.getenv("SERPAPI_API_KEY")
        if not self.api_key:
            raise ValueError("SERPAPI_API_KEY is missing from environment variables.")
        
    def get_product_details_json(self, product_name: str) -> str:
        """
        Queries SerpApi Google Shopping Light to find a product and returns a 
        valid JSON string containing:
        - product_name
        - image_url
        - price_usd
        - global_rating
        """
        params = {
            "engine": "google_shopping_light",
            "q": product_name,
            "api_key": self.api_key,
            "gl": "us",       # Target US market for USD pricing
            "hl": "en"        # Language set to English
        }
        
        try:
            response = requests.get("https://serpapi.com/search.json", params=params, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            shopping_results = data.get("shopping_results", [])
            
            if shopping_results:
                # Extract fields from the top matched product
                first_product = shopping_results[0]
                
                # Extract numeric price or fallback to raw string
                price_usd = first_product.get("price")
                image_url = first_product.get("thumbnail")
                global_rating = first_product.get("rating")
                
                output_data = {
                    "product_name": first_product.get("title"),
                    "image_url": image_url if image_url else "No image found",
                    "price_usd": price_usd if price_usd else "No price found",
                    "global_rating": global_rating if global_rating else "No rating found"
                }
                
                # Serialize the dictionary into a valid JSON formatted string
                return json.dumps(output_data, indent=4, ensure_ascii=False)
                    
            return json.dumps({"error": "No product matches found."})
            
        except requests.exceptions.RequestException as e:
            return json.dumps({"error": f"Request failed: {str(e)}"})

# --- Example ---
if __name__ == "__main__":
    # Querying the asset
    serp_service = GlobalProductDetailsExtractor()
    json_report = serp_service.get_product_details_json("samsung galaxy s24 ultra 256gb")
    
    print("--- Formatted JSON String Output ---")
    print(json_report)