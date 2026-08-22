from fastapi import APIRouter, Request, status
from fastapi.responses import JSONResponse

from .schemas import (InsertBrandRequest,InsertBrandResponse,
                      InsertCategoryRequest,InsertCategoryResponse,
                      UpdateProductRequest,UpdateProductResponse)

from repositories import BrandRepository, CategoryRepository
from .enums.response_enums import ResponseEnums
from models.pydantic_schemas import Brand, Category
from controllers import DataController

data_router = APIRouter(prefix="/data", tags=["Data Insertion"])

@data_router.post("/insert_brand", response_model=InsertBrandResponse)
async def insert_brand(request : Request, brand: InsertBrandRequest):

    brand_repository = BrandRepository(request.app.session)
    if await brand_repository.get_by_name(brand.name):
        return JSONResponse(
            status_code = status.HTTP_400_BAD_REQUEST,
            content = {
                "message" : ResponseEnums.BRAND_ALREDY_EXISTS.value
            }
        )
    brand = await brand_repository.create(Brand(name=brand.name))

    return InsertBrandResponse(
        status=ResponseEnums.BRAND_INSERTED_SUCCESSFULY.value,
        id=brand.id,
        name=brand.name
    )

@data_router.post("/insert_category", response_model=InsertCategoryResponse)
async def insert_category(request : Request, category: InsertCategoryRequest):

    category_repository = CategoryRepository(request.app.session)
    if await category_repository.get_by_name(category.name):
        return JSONResponse(
            status_code = status.HTTP_400_BAD_REQUEST,
            content = {
                "message" : ResponseEnums.CATEGORY_ALREDY_EXISTS.value
            }
        )
    category = await category_repository.create(Category(name=category.name))

    return InsertBrandResponse(
        status=ResponseEnums.CATEGORY_INSERTED_SUCCESSFULY.value,
        id=category.id,
        name=category.name
    )

@data_router.post("/update_product", response_model=UpdateProductResponse)
async def update_product(request: Request, product: UpdateProductRequest):
    brand_repository = BrandRepository(request.app.session)
    brand = await brand_repository.get_by_name(product.brand_name)
    if not brand:
        return JSONResponse(
            status_code = status.HTTP_400_BAD_REQUEST,
            content = {
                "message" : ResponseEnums.BRAND_NOT_FOUND.value
            }
        )

    category_repository = CategoryRepository(request.app.session)
    category = await category_repository.get_by_name(product.category_name)
    if not category:
        return JSONResponse(
            status_code = status.HTTP_400_BAD_REQUEST,
            content = {
                "message" : ResponseEnums.CATEGORY_NOT_FOUND.value
            }
        )

    data_controller = DataController(session=request.app.session)
    product = await data_controller.update_product_or_create_one(product_name=product.product_name, 
                                                           brand_id=brand.id, category_id=category.id)

    return UpdateProductResponse(
        status=ResponseEnums.PRODUCT_UPDATED_SUCCESSFULY.value,
        name=product.name,
        id=product.id,
        description=product.description,
        pros=product.pros,
        cons=product.cons,
        price_usd=product.price_usd,
        global_rating=product.global_rating,
        semantic_summary=product.semantic_summary,
        image_url=product.image_url,
        brand_id=product.brand_id,
        category_id=product.category_id,
        embedding_length=len(product.embedding),
        last_updated=product.last_updated
    )
    