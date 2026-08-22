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