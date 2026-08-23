from pydantic import BaseModel, Field

class NameSearchRequest(BaseModel):
    product_name: str = Field(min_length=1)
    min_similarity: float | None = Field(ge=0, le=1)
    limit: int | None = Field(ge=1)

class NameSearchResponse(BaseModel):
    status: str
    products: list[dict]

class DescriptionSearchRequest(BaseModel):
    description: str
    max_distance: float | None = Field(ge=0)
    limit: int | None = Field(ge=1)

class DescriptionSearchResponse(BaseModel):
    status: str
    products: list[dict]