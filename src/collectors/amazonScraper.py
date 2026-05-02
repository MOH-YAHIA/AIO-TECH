import requests
import json
import os
from dotenv import load_dotenv

load_dotenv()

def fetch_all_amazon_reviews(asin, output_filename="amazon_reviews2.json"):
    api_key = os.getenv("SERPAPI_KEY")
    if not api_key:
        print("❌ Error: SERPAPI_KEY missing.")
        return

    all_reviews = []
    page = 1
    
    print(f"🚀 Starting pagination for ASIN: {asin}")

    # Invariant: Loop continues as long as valid reviews are returned and a "Next" page exists
    while True:
        # 1. CRITICAL: Engine is now 'amazon_reviews'
        params = {
            "engine": "amazon_reviews",
            "asin": asin,
            "amazon_domain": "amazon.eg",
            "api_key": api_key,
            "page": page
        }
        
        print(f"📄 Fetching page {page}...")
        response = requests.get('https://serpapi.com/search', params=params)
        
        if response.status_code != 200:
            print(f"❌ API Error {response.status_code}: {response.text}")
            break
            
        results = response.json()
        
        # 2. Extract reviews (Data structure is different for this engine)
        current_page_reviews = results.get("reviews", [])
        
        # Break condition 1: API returns empty reviews array
        if not current_page_reviews:
            print("🛑 No more reviews found on this page.")
            break
            
        # Append current page reviews to the master list
        all_reviews.extend(current_page_reviews)
        
        # Break condition 2: No 'next' link in the pagination metadata
        pagination = results.get("pagination", {})
        if "next" not in pagination:
            print("🛑 Reached the final page.")
            break
            
        # Increment for the next loop iteration
        page += 1

    # 3. Save aggregated data to file
    with open(output_filename, 'w', encoding='utf-8') as f:
        json.dump(all_reviews, f, ensure_ascii=False, indent=2)

    print(f"✅ Successfully saved {len(all_reviews)} total reviews to '{output_filename}'")

# Execute
fetch_all_amazon_reviews('B0FQFH7JVK')