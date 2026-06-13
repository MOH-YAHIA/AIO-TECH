from src.models.product import ProductAnalysis
from sqlalchemy.orm import Session
from src.services.embedding_service import VectorEmbedding


class SearchWorkflowManager:
    def __init__(self):
          self.embedding_generator = VectorEmbedding()

    def recommend_on_description(self,db: Session, user_intent: str, limit: int = 3):
            """
            Takes a raw user description (e.g., 'A laptop for a CS student doing ML') 
            and calculates Cosine Distance against all stored product embeddings.
            """
            print(f"Calculating semantic proximity for intent: '{user_intent}'")
            
            # 1. Convert the user's messy request into a vector
            intent_vector = self.embedding_generator.generate_embedding(user_intent)
            
            if not intent_vector.any():
                raise ValueError("Failed to map user intent.")

            # 2. Query PostgreSQL to find the nearest mathematical neighbors
            # The <=> operator calculates Cosine Distance (closer to 0 is better)
            nearest_products = (
                db.query(ProductAnalysis)
                .filter(ProductAnalysis.embedding != None) # Safety check
                .order_by(ProductAnalysis.embedding.cosine_distance(intent_vector))
                .limit(limit)
                .all()
            )

            # 3. Format the response for the frontend
            recommendations = []
            for product in nearest_products:
                recommendations.append({
                        "id": product.id,
                        "name": product.name,
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