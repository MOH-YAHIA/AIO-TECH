import json
from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from datetime import datetime, timedelta

from src.models.product import ProductAnalysis
from src.services.gemini_service import DeepDiveAnalyzer
from src.services.embedding_service import VectorEmbedding
from src.services.serp_service import GlobalProductDetailsExtractor

class ProductWorkflowManager:
    def __init__(self):
        self.ai_analyzer = DeepDiveAnalyzer()
        self.embedding_generator = VectorEmbedding()
        self.serp_extractor = GlobalProductDetailsExtractor()
        self.similarity_threshold = 0.9  # Adjusted for stricter similarity matching
        self.cache_expiration_hours = 24*7  # 1 week

    def _format_for_api(self, product: ProductAnalysis) -> dict:
        """Returns the clean, flat JSON structure for the frontend UI."""
        return {
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

    def process_deep_dive(self, db: Session, user_query: str):
        print(f"Analyzing product discovery request for: '{user_query}'")
        
        # 1. Cache Check
        db_name_upper = func.upper(ProductAnalysis.name)
        query_upper = func.upper(user_query)

        similarity_score = func.similarity(db_name_upper, query_upper)

        cached_product = (
            db.query(ProductAnalysis)
            .filter(similarity_score > self.similarity_threshold)
            .order_by(desc(similarity_score))
            .first()
        )

        if cached_product:
            is_fresh = (datetime.now() - cached_product.last_ai_update) < timedelta(hours=self.cache_expiration_hours)
            if is_fresh:
                print("Cache Hit! Serving fresh data immediately.")
                return {"source": "database_cache", "data": self._format_for_api(cached_product)}

        # -----------------------------------------------------------------
        # PHASE 1: Semantic Extraction (Gemini)
        # -----------------------------------------------------------------
        print("⚡ Cache Miss. Invoking Gemini Stage 1...")
        gemini_data = self.ai_analyzer.analyze_product(user_query)
        if "error" in gemini_data:
            raise ValueError(f"Gemini analysis failed: {gemini_data['error']}")

        standardized_name = gemini_data.get("name", user_query)

        # -----------------------------------------------------------------
        # PHASE 2: Deterministic Extraction (SerpApi)
        # -----------------------------------------------------------------
        print(f"Triggering SerpApi Shopping Light for: '{standardized_name}'...")
        serp_data = json.loads(self.serp_extractor.get_product_details_json(standardized_name))
        
        # Default flat values
        extracted_image = None
        extracted_rating = None
        extracted_usd_price = None

        if "error" in serp_data:
            raise ValueError(f"SerpApi extraction failed: {serp_data['error']}")

        img = serp_data.get("image_url")
        if img and img != "No image found":
            extracted_image = img

        rating = serp_data.get("global_rating")
        if rating and rating != "No rating found":
            extracted_rating = float(rating)

        usd_price = serp_data.get("price_usd")
        if usd_price and usd_price != "No price found":
            extracted_usd_price = str(usd_price)

        # -----------------------------------------------------------------
        # PHASE 3: Vector Generation
        # -----------------------------------------------------------------
        rich_context = (
            f"Description: {gemini_data.get('description', '')}. "
            f"Summary: {gemini_data.get('sentiment_summary', '')}. "
            f"Pros: {', '.join(gemini_data.get('pros', []))}. "
            f"Cons: {', '.join(gemini_data.get('cons', []))}."
        )
        
        print("Compiling semantic vector embedding...")
        raw_vector = self.embedding_generator.generate_embedding(rich_context)
        while isinstance(raw_vector, list) and len(raw_vector) > 0 and isinstance(raw_vector[0], list):
            raw_vector = raw_vector[0]
        clean_1d_vector = [float(x) for x in raw_vector]

        # -----------------------------------------------------------------
        # PHASE 4: ACID Database Commit (Drop Existing & Fresh Insert)
        # -----------------------------------------------------------------
        try:
            # 1. Check if the standardized name already exists (case-insensitive)
            existing_record = (
                db.query(ProductAnalysis)
                .filter(func.upper(ProductAnalysis.name) == standardized_name.upper())
                .first()
            )

            if existing_record:
                print(f"[!] Found existing record for '{standardized_name}'. Dropping it from the database...")
                db.delete(existing_record)
                # Flush ensures the delete hits the transaction before the insert happens
                db.flush() 

            # 2. Construct and insert the fresh record
            print(f"[+] Inserting fresh record for '{standardized_name}'...")
            new_product = ProductAnalysis(
                name=standardized_name,
                description=gemini_data.get("description", ""),
                current_price_egp=gemini_data.get("current_price_egp", 0.0),
                pros=gemini_data.get("pros", []),
                cons=gemini_data.get("cons", []),
                sentiment_summary=gemini_data.get("sentiment_summary", ""),
                embedding=clean_1d_vector,
                category=gemini_data.get("category", ""),
                brand=gemini_data.get("brand", ""),
                
                # Flat Inserts
                image_url=extracted_image,
                global_rating=extracted_rating,
                global_usd_price=extracted_usd_price,
                last_ai_update=datetime.now()
            )
            
            db.add(new_product)
            db.commit()
            db.refresh(new_product)
            
            return {"source": "gemini_plus_serp_live", "data": self._format_for_api(new_product)}

        except Exception as db_fault:
            db.rollback()
            print(f"[-] Database operation failed: {db_fault}")
            raise ValueError(f"Database operation failed: {str(db_fault)}")        
        
if __name__ == "__main__":
    from src.core.database import SessionLocal
    db_session = SessionLocal()
    
    manager = ProductWorkflowManager()
    result = manager.process_deep_dive(db_session, "samsung galaxy s24 ultra 256gb")
    
    print("---saving ouput to data/final_output.json---")
    with open("data/final_output.json", "w") as f:
        json.dump(result, f, indent=4)
    