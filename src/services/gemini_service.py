import json
import os
from typing import List, Literal
from pydantic import BaseModel, Field
from google import genai
from google.genai import types
from dotenv import load_dotenv

load_dotenv()

# =====================================================================
# STEP 1: Define the Streamlined Structural Invariants 
# =====================================================================
CategoryLiteral = Literal[
    "smartphone", "laptop", "tablet", "smartwatch", 
    "headphones", "speaker", "gaming_console", "pc_component", 
    "camera", "smart_home", "tv_monitor", "networking", "accessory"
]
    
class ProductAnalysisSchema(BaseModel):
    name: str = Field(
        description="The exact, standardized official product name exculding specific storage/variant formatting (e.g., 'Samsung Galaxy S24 Ultra 256GB')."
    )
    category: CategoryLiteral = Field(
        description="The product category. Must exactly match one of the allowed literal strings."
    )
    brand: str = Field(
        description="The product brand (e.g., 'samsung', 'apple', 'google')."
    )
    description: str = Field(
        description="A robust, highly accurate technical summary of the product's primary specifications, key chipsets, hardware metrics, and primary intended market use-case."
    )
    current_price_egp: float = Field(
        description="High-confidence current active retail price in Egyptian Pounds (EGP). Must represent a realistic, verifiable price from an established local vendor, skipping obvious marketplace outliers, used units, or accessory pricing scams."
    )
    pros: List[str] = Field(
        description="List of top 3-5 hyper-specific technical or value advantages explicitly voiced by actual consumers and reviewers within the local Egyptian ecosystem."
    )
    cons: List[str] = Field(
        description="List of top 3-5 unvarnished technical drawbacks, localized issues (such as local warranty service complaints, heat performance in summer climates, or lack of regional features) cited directly by Egyptian users."
    )
    sentiment_summary: str = Field(
        description="A highly accurate 2-3 sentence technical synthesis of general consumer sentiment across organic local social network layers like Reddit (r/Egypt), Facebook community groups, and specialized tech forums."
    )


# =====================================================================
# STEP 2: Implement the Streamlined Two-Stage Analyzer
# =====================================================================

class DeepDiveAnalyzer:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY is missing from environment variables.")
        
        self.client = genai.Client(api_key=api_key)
        self.model_name = "gemini-2.5-flash"

    def analyze_product(self, product_query: str) -> dict:
        """
        Executes a high-fidelity two-stage pipeline:
        Stage 1: Gathers unvarnished localized consumer data and live retail pricing using Google Search Grounding.
        Stage 2: Compiles the generated textual insight into a rigid, structured JSON payload.
        """
        # -----------------------------------------------------------------
        # STAGE 1: High-Intensity Search Grounding (Targeting Egypt & Social Layers)
        # -----------------------------------------------------------------
        print(f"[+] Stage 1: Executing Grounded Market Search for '{product_query}'...")
        
        search_prompt = (
            f"Perform an exhaustive, deep-dive market evaluation and organic user sentiment analysis for the product: '{product_query}' inside Egypt.\n\n"
            "CRITICAL SEARCH BOUNDARIES & MANDATES:\n"
            "1. HIGH-CONFIDENCE DOMESTIC PRICING: Find the exact current active market price for a brand-new retail unit in Egypt. "
            "Isolate values from major localized merchants (Amazon.eg, Noon.com Egypt, B.TECH, Rayasg, 2B). Verify that the price is "
            "specifically for the real item variant in EGP—not a random accessory, used/refurbished unit, or obvious pricing error.\n"
            "2. SOCIAL COMMUNITY SCRAPING: Actively cross-reference organic web sentiment layers. Scrutinize specific community networks "
            "by evaluating entries corresponding to 'site:reddit.com/r/Egypt', localized tech subreddits, Facebook groups, and Egyptian hardware forums. "
            "Extract unvarnished, raw feedback detailing distinct pros and real-world cons (e.g., local agent/warranty problems, heating under local climate "
            "conditions, charging limitations during load-shedding, or extreme currency-driven price-to-performance gaps).\n"
            "3. DETAILED SPECIFICATION BLURB: Identify the official underlying hardware configuration (chipset, screen, primary engineering selling points) "
            "to construct a strong technical overview statement.\n\n"
            "Compile all validated data points into a thorough, extensive research summary text block focusing strictly on Price, Description, Pros, Cons, and Social Sentiment."
        )

        try:
            search_response = self.client.models.generate_content(
                model=self.model_name,
                contents=search_prompt,
                config=types.GenerateContentConfig(
                    tools=[types.Tool(google_search=types.GoogleSearch())],
                    temperature=0.2,  
                ),
            )
            raw_research_text = search_response.text
            
        except Exception as e:
            print(f"[-] Stage 1 (Search) Failure: {e}")
            return {"error": f"Search grounding failed: {str(e)}"}

        # -----------------------------------------------------------------
        # STAGE 2: Parse and Restructure into Strict JSON Schema
        # -----------------------------------------------------------------
        print("[+] Stage 2: Compiling raw text matrix into deterministic JSON Schema...")
        
        structuring_instruction = (
            "You are an elite automated data formatting engine. Your absolute purpose is to parse the provided raw "
            "Egyptian market research summary and structure it seamlessly to fit the strict JSON schema provided.\n\n"
            "RIGID EXECUTION RULES:\n"
            "- 'current_price_egp' MUST be extracted solely as a pure numerical float value (e.g., 42500.0). Completely strip any currency symbols or commas.\n"
            "- 'pros' and 'cons' arrays must contain distinct, concrete sentences highlighting physical user experiences, not vague generic words.\n"
            "- The entire response output must contain absolutely NO markdown blocks, NO backticks (```json), and NO extra conversational text. "
            "Generate raw, structurally valid JSON matching the schema parameters perfectly."
        )

        try:
            structuring_response = self.client.models.generate_content(
                model=self.model_name,
                contents=f"Raw Research Data:\n{raw_research_text}",
                config=types.GenerateContentConfig(
                    system_instruction=structuring_instruction,
                    response_mime_type="application/json",
                    response_schema=ProductAnalysisSchema,
                    temperature=0.1,  
                ),
            )
            
            validated_json = json.loads(structuring_response.text)
            return validated_json

        except Exception as e:
            print(f"[-] Stage 2 (Structuring) Failure: {e}")
            return {"error": f"JSON structural compilation failed: {str(e)}"}


# --- EXECUTION ---
if __name__ == "__main__":
    analyzer = DeepDiveAnalyzer()
    
    product_to_check = "Samsung Galaxy S24 Ultra"
    report = analyzer.analyze_product(product_to_check)
    
    os.makedirs("data", exist_ok=True)
    output_path = "data/product_deep_dive_clean.json"
    
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=4, ensure_ascii=False)

    print(f"\n[+] Pipeline Complete. Clean JSON report saved to: {output_path}")