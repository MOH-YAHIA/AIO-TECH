from fastapi import APIRouter, Request, status
from fastapi.responses import JSONResponse

from .schemas import InsertBrandRequest,InsertBrandResponse,InsertCategoryRequest,InsertCategoryResponse
from repositories import BrandRepository, CategoryRepository
from .enums.response_enums import ResponseEnums
from models.pydantic_schemas import Brand, Category

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

