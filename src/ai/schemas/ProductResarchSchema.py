from pydantic import BaseModel, Field


class ProductResarchSchema(BaseModel):
    name: str
    description: str | None = None
    pros: list[str]
    cons: list[str]
    price_usd: float | None = Field(default=None, ge=0)
    global_rating: float | None = Field(default=None, ge=0, le=5)
    semantic_summary: str | None = None
    image_url: str | None = None