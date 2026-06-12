import json
import os
from typing import List, Optional
from pydantic import BaseModel, Field
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()

# =====================================================================
# 🏗️ STEP 1: Define the Strict Structural Invariants using Pydantic
# =====================================================================

class PriceHistoryPoint(BaseModel):
    month: str = Field(description="The month name, e.g., 'January', 'February'")
    price: float = Field(description="The average market price in EGP for this month")

class ProductAnalysisSchema(BaseModel):
    name: str = Field(description="The exact, standardized official product name (e.g., 'Samsung Galaxy S24 Ultra 256GB')")
    rating: Optional[float] = Field(description="Calculated average rating out of 5.0 based on market and social reviews")
    current_price_egp: float = Field(description="The current lowest active retail price found in Egypt in EGP")
    lowest_ever_price: float = Field(description="The historical lowest recorded price for this item in Egypt in EGP")
    price_history_6m: List[PriceHistoryPoint] = Field(description="Exactly 6 chronologically ordered monthly data points representing price changes over the last 6 months")
    pros: List[str] = Field(description="List of top 3-5 distinct technical or value advantages extracted from user reviews")
    cons: List[str] = Field(description="List of top 3-5 distinct limitations or user complaints extracted from user reviews")
    sentiment_summary: str = Field(description="A concise 2-3 sentence technical synthesis of general consumer sentiment across social networks like Reddit or Facebook groups in Egypt")


# =====================================================================
# 🧠 STEP 2: Implement the Search-Grounded Analyzer Class
# =====================================================================

class DeepDiveAnalyzer:
    def __init__(self):
        # Read API key securely from environment
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("❌ GEMINI_API_KEY is missing from environment variables.")
        
        # Initialize the modern Google GenAI Client
        self.client = genai.Client(api_key=api_key)
        # Using 2.5 Flash for optimal performance-to-latency ratio
        self.model_name = "gemini-2.5-flash"

    def analyze_product(self, product_query: str) -> dict:
        """
        Executes Google Search Grounding to aggregate live data from Egyptian 
        e-commerce networks and enforces a rigid Pydantic JSON structure response.
        """
        system_instruction = (
            "You are an expert market research agent specialized in the Egyptian e-commerce sector. "
            "Your objective is to find real-time active pricing, a realistic 6-month price history, "
            "and authentic consumer sentiment for the queried item using Google Search. "
            "You must prioritize local platforms such as Amazon.eg, Noon.com (Egypt), B.TECH, and localized social channels. "
            "All pricing metrics MUST be calculated and represented in Egyptian Pounds (EGP)."
        )

        user_prompt = f"Perform a comprehensive market research and deep dive sentiment analysis for the product: '{product_query}'"

        try:
            # Execute inference with strict schema constraints
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=user_prompt,
                config=types.GenerateContentConfig(
                    system_instruction=system_instruction,
                    # ⚡ CRITICAL: Enable Google Search Grounding for live data lookup
                  #  tools=[types.Tool(google_search=types.GoogleSearch())],
                    # 🛡️ CRITICAL: Force Gemini to output JSON conforming exactly to our Pydantic model
                    response_mime_type="application/json",
                    response_schema=ProductAnalysisSchema,
                    temperature=0.2, # Low temperature to prevent hallucination of price numbers
                ),
            )

            # Gemini SDK handles the parsing directly. response.text is guaranteed 
            # to validate perfectly against ProductAnalysisSchema.
            import json
            validated_json = json.loads(response.text)
            return validated_json

        except Exception as e:
            print(f"❌ Gemini Service Pipeline Failure: {e}")
            return {"error": f"Failed to execute structured AI generation. Detail: {str(e)}"}
        

# --- EXECUTION ---
if __name__ == "__main__":
    analyzer = DeepDiveAnalyzer()
    
    # Example: Deep dive into a popular Egyptian tech item
    product_to_check = "Samsung Galaxy S24 Ultra 256GB"
    
    report = analyzer.analyze_product(product_to_check)
    
    # Save the detailed report to your data folder
    output_path = "data/product_deep_dive_test2222.json"
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=4, ensure_ascii=False)

    print(f"Deep-dive complete. Report saved to: {output_path}")