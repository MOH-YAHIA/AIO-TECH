import json
import os
from typing import List
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from google import genai
from google.genai import types
from dotenv import load_dotenv

# Import the deep-dive manager to fetch the data directly inside this service
from src.services.product_service import ProductWorkflowManager


# =====================================================================
#  STRICT COMPARISON SCHEMAS
# =====================================================================
class CategoryComparison(BaseModel):
    category_name: str = Field(
        description="The specific dimension being compared (e.g., 'Performance', 'Camera', 'Value for Money', 'Battery Life')."
    )
    product_a_details: str = Field(
        description="A short, punchy summary of Product A's capabilities in this category."
    )
    product_b_details: str = Field(
        description="A short, punchy summary of Product B's capabilities in this category."
    )
    category_winner: str = Field(
        description="The exact name of the product that wins this category, or 'Tie' if they are equal."
    )

class ProductComparisonSchema(BaseModel):
    overall_winner: str = Field(
        description="The exact name of the overall best product, or 'Depends on User Needs' if it's highly subjective."
    )
    executive_summary: str = Field(
        description="A 2-3 sentence decisive summary of how these two products compare, especially noting the price gap in EGP."
    )
    buy_product_a_if: List[str] = Field(
        description="2-3 highly specific scenarios or user needs where Product A is the absolute right choice."
    )
    buy_product_b_if: List[str] = Field(
        description="2-3 highly specific scenarios or user needs where Product B is the absolute right choice."
    )
    feature_breakdowns: List[CategoryComparison] = Field(
        description="A list of 3 to 5 key comparison categories (e.g., Display, Hardware, Price/Value)."
    )

# =====================================================================
#  THE COMPARISON ENGINE
# =====================================================================
class ComparisonWorkflowManager:
    def __init__(self):
        load_dotenv(override=True)

        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("GEMINI_API_KEY is missing from environment variables.")
        
        self.client = genai.Client(api_key=api_key)
        self.model_name = "gemini-3.1-flash-lite"
        
        # Instantiate the Product Manager to handle database/fetching duties
        self.product_manager = ProductWorkflowManager()

    def generate_comparison(self, db: Session, product_a_query: str, product_b_query: str, user_id: int) -> dict:
        """
        Orchestrates the entire comparison flow: Fetches deep-dive data for both products 
        (hitting the cache or APIs), and then synthesizes a head-to-head AI comparison.
        """

        # 1. Fetch or generate the structured data for Product A
        print(f"[Comparison Engine] Fetching data for Product A: '{product_a_query}'")
        res_a = self.product_manager.process_deep_dive(db=db, user_query=product_a_query, user_id=user_id)
        if "error" in res_a:
            raise ValueError(f"Failed to retrieve Product A: {res_a['error']}")
        product_a_data = res_a["data"]

        # 2. Fetch or generate the structured data for Product B
        print(f"[Comparison Engine] Fetching data for Product B: '{product_b_query}'")
        res_b = self.product_manager.process_deep_dive(db=db, user_query=product_b_query, user_id=user_id)
        if "error" in res_b:
            raise ValueError(f"Failed to retrieve Product B: {res_b['error']}")
        product_b_data = res_b["data"]

        # 3. Execute AI Comparison Reasoning
        product_a_name = product_a_data.get("name", "Product A")
        product_b_name = product_b_data.get("name", "Product B")
        print(f"[Comparison Engine] Compiling AI head-to-head: '{product_a_name}' vs '{product_b_name}'...")

        comparison_prompt = f"""
        You are an elite, highly objective consumer electronics analyst. 
        Your task is to provide a decisive, head-to-head comparison between two products based STRICTLY on the JSON data provided below.
        
        **Product A Data:**
        {json.dumps(product_a_data, indent=2)}

        **Product B Data:**
        {json.dumps(product_b_data, indent=2)}

        **CRITICAL INSTRUCTIONS:**
        1. **Contextual Reality:** Focus heavily on the EGP price difference, the local Egyptian sentiment, and the specific pros/cons provided in the data. Do NOT invent specifications that are not mentioned in the text.
        2. **Decisiveness:** Do not be overly neutral. If one phone is drastically overpriced for what it offers compared to the other, state that clearly.
        3. **Audience:** Write for a consumer trying to make a difficult purchasing decision. Keep insights sharp, scannable, and highly practical.
        """

        structuring_instruction = (
            "You are a strict data formatter. Parse the product comparison into the provided JSON schema. "
            "Output ONLY valid JSON. No markdown wrappers, no conversational text."
        )

        try:
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=comparison_prompt,
                config=types.GenerateContentConfig(
                    system_instruction=structuring_instruction,
                    response_mime_type="application/json",
                    response_schema=ProductComparisonSchema,
                    temperature=0.1, 
                ),
            )
            
            ai_comparison_result = json.loads(response.text)

            # 4. Return the complete package back to the API
            return {
                "status" : "valid",
                "products": {
                    "product_a": product_a_data,
                    "product_b": product_b_data
                },
                "ai_comparison": ai_comparison_result
            }

        except Exception as e:
            print(f"[-] Comparison Engine Failure: {e}")
            raise ValueError(f"Failed to generate comparison: {str(e)}")
        

if __name__ == "__main__":
    # Quick local test (requires a valid DB session and environment setup)
    from src.core.database import SessionLocal
    db = SessionLocal()
    comparator = ComparisonWorkflowManager()
    result = comparator.generate_comparison(db, "iPhoe 14 Pro Max", "Samsung Galxy S23 Ultra")
    with open("data/comparison_output.json", "w") as f:
        json.dump(result, f, indent=4)