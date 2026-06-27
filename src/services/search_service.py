import json
from typing import Literal
from dotenv import load_dotenv
import os 
from sqlalchemy import func
from sqlalchemy.orm import Session
from google import genai  # Replaced ollama with the official Google GenAI SDK
from pydantic import BaseModel, Field

from src.models.product import ProductAnalysis
from src.services.embedding_service import VectorEmbedding


load_dotenv()


CategoryLiteral = Literal[
    "smartphone", "laptop", "tablet", "smartwatch", 
    "headphones", "speaker", "gaming_console", "pc_component", 
    "camera", "smart_home", "tv_monitor", "networking", "accessory", "none"
]

class SearchExtractionSchema(BaseModel):
    category: CategoryLiteral = Field(
        ..., 
        description="The product category. Must exactly match one of the allowed literal strings. If not explicitly mentioned or inferred, return 'none'."
    )
    brand: str = Field(
        ..., 
        description="The company/brand name in lowercase (e.g., 'apple', 'msi', 'samsung'). If not mentioned, return 'none'."
    )
    features: str = Field(
        ..., 
        description="The remaining descriptive adjectives, constraints, or fuzzy requirements (e.g., 'low price, good screen, not heat up fast')."
    )

class SearchWorkflowManager:
    def __init__(self):
        # The genai SDK automatically reads your GEMINI_API_KEY environment variable
        self.client = genai.Client(api_key=os.getenv("GEMINI_API_KEY_2"))
        self.model_name = 'gemini-2.5-flash'
        self.embedding_model = VectorEmbedding()

    def _extract_query_metadata(self, raw_user_query: str) -> dict:
        """
        Uses Gemini 2.5 Flash structured decoding to parse unstructured text 
        into highly rigid, filterable search metadata tokens.
        """
        system_prompt = """
        You are a high-performance data extraction subsystem for an electronics database.
        Your job is to parse the user's raw query and extract three distinct parts:
        1. category: 'laptop', 'phone', 'smartwatch', 'headphones', etc. (or 'none')
        2. brand: 'apple', 'msi', 'samsung', 'asus', etc. (or 'none')
        3. features: everything else related to behavior, performance, or price.
        
        Examples:
        - "iphone with low price" -> category="phone", brand="apple", features="low price"
        - "gaming laptop msi under 1000" -> category="laptop", brand="msi", features="gaming under 1000"
        """

        try:
            # Clean native SDK call with built-in Pydantic schema targeting
            response = self.client.models.generate_content(
                model=self.model_name,
                contents=f"Parse: {raw_user_query}",
                config={
                    "system_instruction": system_prompt,
                    "response_mime_type": "application/json",
                    "response_schema": SearchExtractionSchema,
                    "temperature": 0.0  # Pure determinism
                }
            )
            
            # The SDK automatically handles the JSON parsing and validation into your Pydantic model
            if response.parsed:
                return response.parsed.model_dump()
            
            # Safe structural fallback parsing just in case
            return json.loads(response.text)
        
        except Exception as e:
            raise RuntimeError(f"[Extraction Error] Failed to parse query metadata using {self.model_name}: {str(e)}")

    def recommend_on_description(self, db: Session, user_intent: str, limit: int = 3):
        """
        Executes hybrid querying pipeline: 
        Metadata Extraction -> SQL Hard Boundary Filtering -> Vector Space Neighbor Scan.
        """
        # 1. Extract structured requirements from raw text using local LLM
        extracted = self._extract_query_metadata(user_intent)
        print(f"[Hybrid Search] Category: {extracted['category']} | Brand: {extracted['brand']} | Features: {extracted['features']}")

        # 2. Initialize baseline SQLAlchemy query sequence
        query = db.query(ProductAnalysis)

        # 3. Apply Hard Category Constraints if present
        if extracted['category'] != "none":
            query = query.filter(func.lower(ProductAnalysis.category) == extracted['category'].strip())

        # 4. Apply Hard Brand Constraints if present
        if extracted['brand'] != "none":
            query = query.filter(func.lower(ProductAnalysis.brand) == extracted['brand'].strip())

        try:
            # 5. Generate mathematical vector representation of fuzzy features
            # If features string is empty, fall back to parsing the original intent string
            search_features = extracted['features'] if extracted['features'].strip() else user_intent
            query_vector = self.embedding_model.generate_embedding(search_features)

            # 6. Execute vector sorting on the highly constrained, pre-filtered row subset
            # Uses pgvector cosine distance operator '<->'
            results = (
                query
                .order_by(ProductAnalysis.embedding.cosine_distance(query_vector))
                .limit(limit)
                .all()
            )
            nearest_products = results

        except Exception as vector_err:
            raise RuntimeError(f"[Vector Search Error] Failed to execute vector search using {self.embedding_model.name} and query database: {str(vector_err)}")

        # Format the response for the frontend
        recommendations = []
        for product in nearest_products:
            recommendations.append({
                    "id": product.id,
                    "name": product.name,
                    "category": product.category,
                    "brand": product.brand,
                    "description": product.description,
                    "current_price_egp": product.current_price_egp,
                    "pros": product.pros,
                    "cons": product.cons,
                    "sentiment_summary": product.sentiment_summary,
                    
                    # Flattened SerpApi Data
                    "image_url": product.image_url,
                    "global_rating": product.global_rating,
                    "global_usd_price": product.global_usd_price,
                    
                    "last_ai_update": product.last_ai_update.isoformat() if product.last_ai_update else None
                }
            )
                
        return recommendations

if __name__ == "__main__":
    from src.core.database import SessionLocal
    db = SessionLocal()
    user_query = "Looking for a budget-friendly smartphone with a great camera."
    search_service = SearchWorkflowManager()
    recs = search_service.recommend_on_description(db, user_query)
    print(recs)