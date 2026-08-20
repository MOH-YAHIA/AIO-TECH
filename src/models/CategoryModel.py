# SQLAlchemy Model
# Database representation of brands table

from uuid import UUID, uuid4

from sqlalchemy import String
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column

from .BaseModel import Base


class CategoryModel(Base):

    __tablename__ = "categories"

    id: Mapped[UUID] = mapped_column( # UUID in python mapped to UUID in sqlalchemy witch is PGUUID
        PGUUID(as_uuid=True),   # as_uuid=True, to be as UUID object not string 
        primary_key=True,
        default=uuid4, # pass function name not call it
    )

    name: Mapped[str] = mapped_column( # str in python mapped to String in sqlalchemy
        String(100),
        unique=True,
        nullable=False,
    )

