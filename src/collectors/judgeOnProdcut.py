import os
import json
import re
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()

class DeepDiveAnalyzer:
    def __init__(self):
        self.client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))
        self.model_id = "gemini-2.5-flash" 
        
        # This instruction is more detailed to handle history and social sentiment
        self.system_instruction = (
            "You are a Senior Product Research Agent for the Egyptian market. "
            "For the given product name, you must perform the following invariants: "
            "1. Search Amazon.eg, Noon.eg, and B.TECH for the current lowest price. "
            "2. Search Kanbkam.com or Pricena.com/eg to find the price history for the past 6 months. "
            "3. Search Reddit (r/Egypt, r/technology) and social media reviews for real user sentiment. "
            "4. Return a JSON object with: 'name', 'rating', 'current_price_egp', 'lowest_ever_price', "
            "'price_history_6m' (a month-by-month list), 'pros', 'cons', 'sentiment_summary', 'links', 'lowest_price_link'. "
            "Ensure the sentiment_summary is based on actual comments/posts found."
        )

    def analyze_product(self, product_name):
        print(f"Deep-diving into: {product_name}...")

        search_tool = types.Tool(
            google_search=types.GoogleSearch()
        )

        config = types.GenerateContentConfig(
            system_instruction=self.system_instruction,
            tools=[search_tool]
        )

        try:
            response = self.client.models.generate_content(
                model=self.model_id,
                contents=f"Analyze this product: {product_name}",
                config=config
            )

            # Robust JSON extraction logic (as discussed)
            raw_text = response.text
            json_match = re.search(r'\{.*\}', raw_text, re.DOTALL)
            
            if json_match:
                return json.loads(json_match.group(0))
            else:
                return {"error": "Could not parse data from AI response"}

        except Exception as e:
            print(f"Analysis Failed: {e}")
            return {"error": str(e)}

# --- EXECUTION ---
if __name__ == "__main__":
    analyzer = DeepDiveAnalyzer()
    
    # Example: Deep dive into a popular Egyptian tech item
    product_to_check = "Samsung Galaxy S24 Ultra 256GB"
    
    report = analyzer.analyze_product(product_to_check)
    
    # Save the detailed report to your data folder
    output_path = "data/product_deep_dive_test.json"
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=4, ensure_ascii=False)

    print(f"Deep-dive complete. Report saved to: {output_path}")