from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session
from typing import List

# 1. Dependency Injections
from src.core.database import get_db
from src.services.product_service import ProductWorkflowManager
from src.services.search_service import SearchWorkflowManager
from src.services.compare_service import ComparisonWorkflowManager

# 2. Router Initialization
router = APIRouter(prefix="/api/v1/products", tags=["Products"])

# Instantiate services once (Singleton pattern for efficiency)
deep_dive_manager = ProductWorkflowManager()
semantic_search_manager = SearchWorkflowManager()
comparison_manager = ComparisonWorkflowManager()
# =====================================================================
# 📦 SCHEMAS (Strict Type Invariants)
# =====================================================================
class IntentSearchRequest(BaseModel):
    description: str
    limit: int = 3

class DeepDiveRequest(BaseModel):
    query: str

class CompareRequest(BaseModel):
    product_a_query: str
    product_b_query: str
# =====================================================================
# 📡 ENDPOINTS
# =====================================================================

@router.post("/semantic-search")
def execute_semantic_search(request: IntentSearchRequest, db: Session = Depends(get_db)):
    """
    Feature 1: Resolves raw user descriptions to mathematical vectors 
    and retrieves exact neighbors using Cosine Distance.
    """
    try:
        results = semantic_search_manager.recommend_on_description(
            db=db, 
            user_intent=request.description, 
            limit=request.limit
        )
        
        # Handle service-level failures gracefully
        if isinstance(results, dict) and "error" in results:
            raise HTTPException(status_code=400, detail=results["error"])
            
        return {"status": "success", "data": results}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Semantic Engine Fault: {str(e)}")


@router.post("/deep-dive")
def execute_deep_dive(request: DeepDiveRequest, db: Session = Depends(get_db)):
    """
    Feature 2: Pipeline routing. Checks Trigram cache -> Invokes Gemini -> 
    Extracts Live Links via SerpApi -> Updates PostgreSQL Vector State.
    """
    try:
        result = deep_dive_manager.process_deep_dive(db=db, user_query=request.query)
        
        if "error" in result:
            raise HTTPException(status_code=502, detail=result["error"])
            
        return {"status": "success", "payload": result}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Pipeline Crash: {str(e)}")
    
@router.post("/compare")
def execute_comparison(request: CompareRequest, db: Session = Depends(get_db)):
    """
    Feature 3: Takes two product names, fetches their deep-dive localized data, 
    and generates a structured head-to-head AI comparison.
    """
    try:
        # The service handles the database checking and the Gemini calls!
        result = comparison_manager.generate_comparison(
            db=db,
            product_a_query=request.product_a_query,
            product_b_query=request.product_b_query
        )
        
        # Check for explicitly thrown errors in the service pipeline
        if "error" in result:
            raise HTTPException(status_code=502, detail=result["error"])

        return {"status": "success", "payload": result}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Comparison Pipeline Crash: {str(e)}")