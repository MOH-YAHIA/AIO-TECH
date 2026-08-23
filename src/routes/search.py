from fastapi import APIRouter, Request, status
from fastapi.responses import JSONResponse
from .schemas import NameSearchRequest, NameSearchResponse
from .enums.response_enums import ResponseEnums
from repositories import ProductRepository
# from controllers import SearchController
from models.pydantic_schemas import Product

search_router = APIRouter(prefix="/search", tags=["Product Search"])

@search_router.post("/name", response_model=NameSearchResponse)
async def search_by_name(request: Request, name_search_request: NameSearchRequest):
    product_repository = ProductRepository(request.app.session)
    similer_products = await product_repository.search_by_similar_name(name_search_request.product_name,
                                                                      name_search_request.min_similarity,   
                                                                      name_search_request.limit) 

    return NameSearchResponse(
        status = ResponseEnums.PRODUCT_SEARCH_NAME_SUCCESS.value,
        products = [
            product.model_dump(exclude={"embedding"})
            for product in similer_products
        ]
    )