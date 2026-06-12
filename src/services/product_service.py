# Inside src/services/product_service.py
# (Make sure to import your new SerpLinkFetcher at the top)
from src.services.serp_service import SerpLinkFetcher
from src.services.gemini_service import DeepDiveAnalyzer
from src.models.product import ProductAnalysis
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from datetime import datetime, timedelta
from src.services.embedding_service import VectorEmbedding

class ProductWorkflowManager:
    def __init__(self):
        self.ai_analyzer = DeepDiveAnalyzer()
        self.link_fetcher = SerpLinkFetcher() # Mount our new search engine asset
        self.similarity_threshold = 0.4
        self.cache_expiration_hours = 24
        self.embedding_generator = VectorEmbedding()

    def process_deep_dive(self, db: Session, user_query: str):
        print(f"🔍 Analyzing product discovery request for string: '{user_query}'")
        
        # 1. Compute Trigram string matching score against names stored in database
        similarity_score = func.similarity(ProductAnalysis.name, user_query)
        
        cached_product = (
            db.query(ProductAnalysis)
            .filter(similarity_score > self.similarity_threshold)
            .order_by(desc(similarity_score))
            .first()
        )

        # 2. Check Cache Validity Conditions
        if cached_product:
            time_since_update = datetime.now() - cached_product.last_ai_update
            is_fresh = time_since_update < timedelta(hours=self.cache_expiration_hours)
            
            if is_fresh:
                print("🎯 Cache Hit! Serving fresh data immediately from PostgreSQL.")
                return {
                    "source": "database_cache",
                    "data": cached_product
                }
            print("⏳ Cache Stale! The data is older than 24 hours. Triggering refresh...")

        # --- CACHE MISS PATH ---
        print("⚡ Cache Miss. Invoking Gemini for structured analysis details...")
        ai_data = self.ai_analyzer.analyze_product(user_query)
        
        if "error" in ai_data:
            return {"error": "Failed to analyze product constraints using Gemini."}

        # 🚀 THE NEW STEP: Extract the official product name and query SerpApi for real URLs
        standardized_name = ai_data.get("name", user_query)
        print(f"🌐 Triggering SerpApi live indexing for: '{standardized_name}'...")
        serp_payload = self.link_fetcher.discover_egyptian_market_links(standardized_name)
        real_market_links = serp_payload["links"]
        discovered_image = serp_payload["image_url"] # 👈 Captured!
        
        
        # Build clean link arrays filtering out any stores that weren't found
        verified_url_list = [url for url in real_market_links.values() if url is not None]

        # 1. Create a dense context string combining all semantic value
        rich_context = f"Product: {standardized_name}. "
        rich_context += f"Summary: {ai_data.get('sentiment_summary', '')}. "
        rich_context += f"Pros: {', '.join(ai_data.get('pros', []))}. "
        rich_context += f"Cons: {', '.join(ai_data.get('cons', []))}."

        # 2. Generate the mathematical vector
        print("🧠 Compiling semantic vector embedding for intent matching...")
        product_vector = self.embedding_generator.generate_embedding(rich_context)


        try:
            if cached_product:
                print(f"🔄 Hydrating stale record for ID: {cached_product.id}")
                cached_product.current_price_egp = float(ai_data.get("current_price_egp", 0))
                cached_product.lowest_ever_price = float(ai_data.get("lowest_ever_price", 0))
                cached_product.price_history_6m = ai_data.get("price_history_6m", [])
                cached_product.pros = ai_data.get("pros", [])
                cached_product.cons = ai_data.get("cons", [])
                cached_product.sentiment_summary = ai_data.get("sentiment_summary", "")
                
                # Overwrite database properties using SerpApi's real findings
                cached_product.links = verified_url_list
                cached_product.lowest_price_link = real_market_links.get("amazon") or real_market_links.get("noon")
                cached_product.last_ai_update = datetime.now()
                cached_product.image_url = discovered_image
                cached_product.embedding = product_vector

                db.commit()
                db.refresh(cached_product)
                active_record = cached_product
            else:
                # Store a brand new product entry
                new_product = ProductAnalysis(
                    name=standardized_name,
                    rating=float(ai_data.get("rating", 0.0)) if ai_data.get("rating") else None,
                    current_price_egp=float(ai_data.get("current_price_egp", 0)),
                    lowest_ever_price=float(ai_data.get("lowest_ever_price", 0)),
                    price_history_6m=ai_data.get("price_history_6m", []),
                    pros=ai_data.get("pros", []),
                    cons=ai_data.get("cons", []),
                    sentiment_summary=ai_data.get("sentiment_summary", ""),
                    
                    # Injecting SerpApi verified arrays
                    links=verified_url_list,
                    image_url=discovered_image,
                    lowest_price_link=real_market_links.get("amazon") or real_market_links.get("noon"),
                    embedding=product_vector
                )
                db.add(new_product)
                db.commit()
                db.refresh(new_product)
                active_record = new_product
                
            return {
                "source": "gemini_plus_serp_live",
                "data": active_record
            }

        except Exception as db_fault:
            db.rollback()
            return {"error": f"Transaction rolled back. Details: {db_fault}"}
        
# --- TEST HARNESS ---
if __name__ == "__main__":
    # This block is for quick local testing of the entire workflow without needing to run the FastAPI server
    from src.core.database import SessionLocal, engine
    from src.models.product import Base
    
    # Ensure tables are created
    Base.metadata.create_all(bind=engine)
    
    # Create a new database session
    db = SessionLocal()
    
    # Example product query for testing
    product_to_check = "Apple iPhone 14 Pro Max"
    result = ProductWorkflowManager().process_deep_dive(db, product_to_check)
    print(result)
    
    print(result['data'].name)
    print(result['data'].current_price_egp)
    print(result['data'].links)
    print(result['data'].sentiment_summary)
    print(result['data'].pros)
    print(result['data'].cons)
    print(result['data'].image_url)
    print(f"Embedding Vector Length: {len(result['data'].embedding)}")
