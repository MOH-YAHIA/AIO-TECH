from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session
from typing import List, Literal

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

class UnifiedDispatchRequest(BaseModel):
    # Enforces compile-time/runtime validation values strictly at the router border
    service_name: Literal["product", "detailed"] = Field(
        ..., 
        description="The target pipeline selection metric. 'product' -> Deep Dive, 'detailed' -> Vector Search"
    )
    query_string: str = Field(
        ..., 
        description="The exact user intent query string or product model descriptor"
    )
    limit: int = Field(
        3, 
        description="Max pagination constraint. Only evaluated when processing 'detailed' queries"
    )

# =====================================================================
# 📡 ENDPOINTS
# =====================================================================

@router.post("/dispatch")
def execute_unified_dispatch(request: UnifiedDispatchRequest, db: Session = Depends(get_db)):
    """
    Polymorphic Gateway Engine: Dynamically checks the requested service string,
    manages the internal execution path, and unifies response structures.
    """
    try:
        # Route 1: Target to the LLM-grounded hydration/caching manager
        if request.service_name == "product":
            result = deep_dive_manager.process_deep_dive(db=db, user_query=request.query_string)
            
            if "error" in result:
                raise HTTPException(status_code=502, detail=result["error"])
                
            return {"status": "success", "routing": "deep-dive", "payload": result}

        # Route 2: Target to the pgvector mathematical neighborhood engine
        elif request.service_name == "detailed":
            results = semantic_search_manager.recommend_on_description(
                db=db, 
                user_intent=request.query_string, 
                limit=request.limit
            )
            
            if isinstance(results, dict) and "error" in results:
                raise HTTPException(status_code=400, detail=results["error"])
                
            return {"status": "success", "routing": "semantic-search", "data": results}

    except HTTPException as http_ex:
        # Prevent double-wrapping structural exceptions already captured
        raise http_ex
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Polymorphic Dispatcher Crash: {str(e)}")


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
        result = comparison_manager.generate_comparison(
            db=db,
            product_a_query=request.product_a_query,
            product_b_query=request.product_b_query
        )
        
        if "error" in result:
            raise HTTPException(status_code=502, detail=result["error"])

        return {"status": "success", "payload": result}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Comparison Pipeline Crash: {str(e)}")