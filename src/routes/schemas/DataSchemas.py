from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

class InsertBrandRequest(BaseModel):
    name: str = Field(min_length=1)

class InsertBrandResponse(BaseModel):
    status: str
    id: UUID
    name: str

class InsertCategoryRequest(BaseModel):
    name: str = Field(min_length=1)

class InsertCategoryResponse(BaseModel):
    status: str
    id: UUID
    name: str

class UpdateProductRequest(BaseModel):
    product_name: str = Field(min_length=1)
    brand_name: str = Field(min_length=1)
    category_name: str = Field(min_length=1)

class UpdateProductResponse(BaseModel):
    status: str
    id: UUID 
    name: str
    description: str | None
    pros: list[str]
    cons: list[str]
    price_usd: float | None = Field(default=None, ge=0)
    global_rating: float | None = Field(default=None, ge=0, le=5)
    semantic_summary: str | None
    image_url: str | None = None
    brand_id: UUID
    category_id: UUID
    embedding_length: int
    last_updated: datetime
