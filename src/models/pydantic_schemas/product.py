from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, HttpUrl


class Product(BaseModel):
    id: UUID | None = None

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

    embedding: list[float]

    last_updated: datetime
