# SQLAlchemy Model
# Database representation of products table

from datetime import datetime
from uuid import UUID, uuid4

from pgvector.sqlalchemy import Vector
from sqlalchemy import String, Float, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID as PGUUID, ARRAY
from sqlalchemy.orm import Mapped, mapped_column
from helpers.config import get_settings
from .BaseModel import Base

settings = get_settings()
class ProductModel(Base):

    __tablename__ = "products"

    id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )

    name: Mapped[str] = mapped_column(
        String(200),
        nullable=False,
    )

    description: Mapped[str | None] = mapped_column(
        String,
        nullable=True,
    )

    pros: Mapped[list[str]] = mapped_column(
        ARRAY(String),
        nullable=False,
    )

    cons: Mapped[list[str]] = mapped_column(
        ARRAY(String),
        nullable=False,
    )

    price_usd: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
    )

    global_rating: Mapped[float | None] = mapped_column(
        Float,
        nullable=True,
    )

    semantic_summary: Mapped[str | None] = mapped_column(
        String,
        nullable=True,
    )

    image_url: Mapped[str | None] = mapped_column(
        String,
        nullable=True,
    )

    brand_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("brands.id"),
        nullable=False,
    )

    category_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("categories.id"),
        nullable=False,
    )

    embedding: Mapped[list[float]] = mapped_column(
        Vector(settings.EMBEDDING_DIMENSION),  # pgvector type
        nullable=False,
    )

    last_updated: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
    )