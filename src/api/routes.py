from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

# 1. Dependency Injections
from src.core.database import get_db
from src.services.product_service import ProductWorkflowManager
from src.services.search_service import SearchWorkflowManager
from src.services.compare_service import ComparisonWorkflowManager
from src.services.router_service import IntentRouterEngine

# 2. Router Initialization
router = APIRouter(prefix="/api/v1/products", tags=["Products"])

# Instantiate services once (Singleton pattern for efficiency)
deep_dive_manager = ProductWorkflowManager()
semantic_search_manager = SearchWorkflowManager()
comparison_manager = ComparisonWorkflowManager()
smart_router = IntentRouterEngine()

# =====================================================================
#  SCHEMAS (Strict Type Invariants)
# =====================================================================
class IntentSearchRequest(BaseModel):
    description: str
    limit: int = 3

class DeepDiveRequest(BaseModel):
    query: str

class CompareRequest(BaseModel):
    product_a_query: str
    product_b_query: str

class SmartDispatchRequest(BaseModel):
    query_string: str = Field(..., description="Raw unstructured string from user query bar")
    limit: int = Field(3, description="Pagination bounds constraint")

# =====================================================================
#  ENDPOINTS
# =====================================================================

@router.post("/dispatch")
def execute_smart_dispatch(request: SmartDispatchRequest, db: Session = Depends(get_db)):
    """
    Agentic Semantic Gateway: Routes incoming traffic based on real-time 
    intent token analysis from geimin-2.5-flash-lite
    """
    try:
        # 1.  Invoke local routing wrapper
        routing_decision = smart_router.classify_intent(request.query_string)
        
        intent = routing_decision.get("intent_type")
        cleaned_query = routing_decision.get("cleaned_query")

        # 2. Guard against out-of-bounds requests
        if intent == "unrelated":
            return {
                "status": "error",
                "routing": "unrelated",
                "detail": "Query out of scope. Please enter an electronics description or product model identifier."
            }

        # 3. Route A: Specific Product Scan (Enforced Exact Hash Match)
        elif intent == "specific_product":
           
            # Execute database retrieval targeting exact string match (Similarity = 1.0)
            result = deep_dive_manager.process_deep_dive(db=db, user_query=cleaned_query)
            
            if "error" in result:
                raise HTTPException(status_code=502, detail=result["error"])
                
            return {
                "status": "success", 
                "routing": "product-deep-dive", 
                "payload": result
            }

        # 4. Route B: Feature Description (Vector Similarity Subspace Search)
        elif intent == "recommendation":
            results = semantic_search_manager.recommend_on_description(
                db=db, 
                user_intent=cleaned_query.lower(), 
                limit=request.limit
            )
            
            if isinstance(results, dict) and "error" in results:
                raise HTTPException(status_code=400, detail=results["error"])
                
            return {
                "status": "success", 
                "routing": "vector-semantic-search", 
                "data": results
            }

    except HTTPException as http_ex:
        raise http_ex
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Agentic Pipeline Failure: {str(e)}")

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

        if result['status']=="non-valid":
            return {
                "status": "error", 
                "routing": "compare", 
                "details": "non valid product names"
            }
        
        return {
            "status": "success", 
            "routing": "compare" ,
            "payload": result
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Comparison Pipeline Crash: {str(e)}")