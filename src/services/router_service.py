import os
import json
from google import genai
from pydantic import BaseModel, Field
from typing import Literal
from dotenv import load_dotenv

load_dotenv()

# Define a strict structural invariant for the LLM output
class RoutingSchema(BaseModel):
    intent_type: Literal["recommendation", "specific_product", "unrelated"]
    cleaned_query: str = Field(description="The core product name (if specific_product) or the core descriptive features (if recommendation). Remove conversational fluff.")

class IntentRouterEngine:
    def __init__(self):
        
        self.client = genai.Client(api_key=os.getenv("GEMINI_API_KEY_2"))
        self.model_name = 'gemini-2.5-flash-lite'

    def classify_intent(self, raw_query: str) -> dict:
        """
        Communicates with Gemini 2.5 Flash to categorize user intent.
        """
        prompt = f"""
        You are an elite intent-routing microservice for an e-commerce database.
        Analyze this raw query then classify it: "{raw_query}"

        CLASSIFICATION RULES:
        1. 'recommendation': The user is describing features, use-cases, or needs (e.g., "gaming laptop that doesn't heat up fast", "cheap phone for photography").
        2. 'specific_product': The user explicitly names a specific, identifiable hardware model (e.g., "iPhone 14 Pro Max", "MSI GF63", "Samsung S24 Ultra").
        3. 'unrelated': The text is gibberish, empty, or completely unrelated to buying electronics.

        """

        try:
            # Clean native SDK call with built-in Pydantic schema targeting
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=prompt,
                config={
                    "response_mime_type": "application/json",
                    "response_schema": RoutingSchema,
                    "temperature": 0.0 # Eliminates stochastic drift
                }
            )
            
            # The SDK automatically parses the JSON into your Pydantic object
            if response.parsed:
                return response.parsed.model_dump()
            
            # Safe fallback parsing just in case
            return json.loads(response.text)
            
        except Exception as e:
            raise RuntimeError(f"Intent classification failed using {self.model_name}: {str(e)}")
        
if __name__ == "__main__":
    # Quick local test harness (Ensure GEMINI_API_KEY is exported in your environment)
    router = IntentRouterEngine()
    test_queries = [
        #"Looking for a gaming laptop that doesn't heat up fast",
        "iPhne 14 bro Max",
        "where can i buy tommatoes"
    ]
    
    for query in test_queries:
        try:
            result = router.classify_intent(query)
            print(f"Input: {query}\nOutput: {result}\n")
        except Exception as err:
            print(f"Error executing query [{query}]: {err}\n")