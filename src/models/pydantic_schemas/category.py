from uuid import UUID

from pydantic import BaseModel, Field

class Category(BaseModel):
    id: UUID | None = None
    name: str
