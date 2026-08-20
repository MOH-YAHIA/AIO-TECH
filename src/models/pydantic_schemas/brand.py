# Pydantic Class
# Python representation of brand data

from uuid import UUID

from pydantic import BaseModel, Field

class Brand(BaseModel):
    id: UUID | None = None # type can be UUID or None . default is None
    name: str
