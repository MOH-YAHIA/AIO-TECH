import os
import json
import re
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()

class ProductRecommender:
    def __init__(self):
        self.client = genai.Client(api_key=os.getenv("GEMINI_API_KEY"))

        self.model_id = "gemini-2.5-flash" 
        
        self.system_instruction = (
            "You are an expert Product Recommendation Engine for the Egyptian market. "
            "Map user needs to 3 real products available in Egypt. "
            "1. Use Google Search to find real, current products and prices in EGP. "
            "2. Analyze sentiment from reviews and social media for each product. "
            "3. Return ONLY a valid JSON array of objects. "
            "Each object must have: 'name', 'price_egp', 'why_it_matches', 'pros', 'cons'. "
            "Do not include any conversational text before or after the JSON."
        )

    def get_recommendations(self, user_description):
        print(f"Searching and Analyzing: '{user_description}'...")

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
                contents=user_description,
                config=config
            )

            # --- ROBUST JSON EXTRACTION ---
            # This handles cases where the model puts markdown blocks around the JSON
            raw_content = response.text
            json_match = re.search(r'\[.*\]', raw_content, re.DOTALL)
            
            if json_match:
                clean_json = json_match.group(0)
                return json.loads(clean_json)
            else:
                # Fallback if the regex fails but text exists
                return json.loads(raw_content.strip())

        except Exception as e:
            print(f"Engineering Exception: {e}")
            return {"error": str(e)}

# --- TEST ---
if __name__ == "__main__":
    recommender = ProductRecommender()
    test_input = "CS student needs a laptop with 16GB RAM for Deep Learning, budget 50,000 EGP."
    results = recommender.get_recommendations(test_input)
    print(json.dumps(results, indent=4, ensure_ascii=False))
    # --- SAVE TO FILE ---
    output_file = "data/description_recommendations_test.json"

    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=4, ensure_ascii=False)

    print(f"Data successfully saved to {output_file}")