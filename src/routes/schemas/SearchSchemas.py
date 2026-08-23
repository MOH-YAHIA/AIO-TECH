from pydantic import BaseModel, Field

class NameSearchRequest(BaseModel):
    product_name: str = Field(min_length=1)
    min_similarity: float | None = Field(ge=0, le=1)
    limit: int | None = Field(ge=1)

class NameSearchResponse(BaseModel):
    status: str
    products: list[dict]