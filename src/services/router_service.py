import json
import ollama
from pydantic import BaseModel, Field
from typing import Literal

# Define a strict structural invariant for the LLM output
class RoutingSchema(BaseModel):
    intent_type: Literal["recommendation", "specific_product", "unrelated"]
    cleaned_query: str = Field(description="The core product name (if specific_product) or the core descriptive features (if recommendation). Remove conversational fluff.")

class IntentRouterEngine:
    def __init__(self):
        self.model_name = 'llama3.2'

    def classify_intent(self, raw_query: str) -> dict:
        """
        Communicates with local Ollama service to categorize user intent.
        Enforces uppercase transformations on specific hardware models.
        """
        prompt = f"""
        You are an elite intent-routing microservice for an e-commerce database.
        Analyze this raw query: "{raw_query}"

        CLASSIFICATION RULES:
        1. 'recommendation': The user is describing features, use-cases, or needs (e.g., "gaming laptop that doesn't heat up fast", "cheap phone for photography").
        2. 'specific_product': The user explicitly names a specific, identifiable hardware model (e.g., "iPhone 14 Pro Max", "MSI GF63", "Samsung S24 Ultra").
        3. 'unrelated': The text is gibberish, empty, or completely unrelated to buying electronics.

        """

        try:
            # Clean native wrapper call with built-in JSON format targeting
            response = ollama.chat(
                model=self.model_name,
                messages=[{'role': 'user', 'content': prompt}],
                format=RoutingSchema.model_json_schema(),
                options={'temperature': 0.0} # Eliminates stochastic drift
            )
            
            # Parse response content safely
            data = json.loads(response['message']['content'])
            return data
            
        except Exception as e:
            raise RuntimeError(f"Intent classification failed using {self.model_name}: {str(e)}")
        
if __name__ == "__main__":
    # Quick local test harness
    router = IntentRouterEngine()
    test_queries = [
        "Looking for a gaming laptop that doesn't heat up fast",
        "iPhne 14 bro Max",
        "where can i buy tommatoes"
    ]
    
    for query in test_queries:
        result = router.classify_intent(query)
        print(f"Input: {query}\nOutput: {result}\n")