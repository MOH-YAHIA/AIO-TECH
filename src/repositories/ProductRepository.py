# Database operations
# Product - ProductModel conversion

from uuid import UUID

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from models.ProductModel import ProductModel        # SQLAlchemy/PostgreSQL model
from models.pydantic_schemas.product import Product # Python/Pydantic model


class ProductRepository:

    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    @staticmethod
    def _to_model(product: Product) -> ProductModel:
        return ProductModel(
            id=product.id,
            name=product.name,
            description=product.description,
            pros=product.pros,
            cons=product.cons,
            price_usd=product.price_usd,
            global_rating=product.global_rating,
            semantic_summary=product.semantic_summary,
            image_url=str(product.image_url) if product.image_url else None,
            brand_id=product.brand_id,
            category_id=product.category_id,
            embedding=product.embedding,
            last_updated=product.last_updated,
        )

    @staticmethod
    def _to_schema(db_product: ProductModel) -> Product:
        return Product(
            id=db_product.id,
            name=db_product.name,
            description=db_product.description,
            pros=db_product.pros,
            cons=db_product.cons,
            price_usd=db_product.price_usd,
            global_rating=db_product.global_rating,
            semantic_summary=db_product.semantic_summary,
            image_url=db_product.image_url,
            brand_id=db_product.brand_id,
            category_id=db_product.category_id,
            embedding=db_product.embedding,
            last_updated=db_product.last_updated,
        )

    async def create(self, product: Product) -> Product:

        db_product = self._to_model(product)

        self.session.add(db_product)

        await self.session.commit()
        await self.session.refresh(db_product)

        return self._to_schema(db_product)

    async def get_by_id(self, product_id: UUID) -> Product | None:

        result = await self.session.execute(
            select(ProductModel).where(
                ProductModel.id == product_id
            )
        )

        db_product = result.scalar_one_or_none()

        if db_product is None:
            return None

        return self._to_schema(db_product)

    async def get_by_name(self, name: str) -> Product | None:

        result = await self.session.execute(
            select(ProductModel).where(
                ProductModel.name == name
            )
        )

        db_product = result.scalar_one_or_none()

        if db_product is None:
            return None

        return self._to_schema(db_product)

    async def search_by_similar_name(
        self,
        product_name: str,
        min_similarity: float = 0.4,
        limit: int = 10,
    ) -> list[Product]:

        similarity = func.similarity(
            ProductModel.name,
            product_name,
        ).label("similarity")

        result = await self.session.execute(
            select(ProductModel)
            .where(similarity >= min_similarity)
            .order_by(similarity.desc())
            .limit(limit)
        )

        db_products = result.scalars().all()

        return [
            self._to_schema(product)
            for product in db_products
        ]


    async def update(self, product: Product) -> Product | None:

        result = await self.session.execute(
            select(ProductModel).where(
                ProductModel.id == product.id
            )
        )

        db_product = result.scalar_one_or_none()

        if db_product is None:
            return None

        db_product.name = product.name
        db_product.description = product.description
        db_product.pros = product.pros
        db_product.cons = product.cons
        db_product.price_usd = product.price_usd
        db_product.global_rating = product.global_rating
        db_product.semantic_summary = product.semantic_summary
        db_product.image_url = (
            str(product.image_url)
            if product.image_url
            else None
        )
        db_product.brand_id = product.brand_id
        db_product.category_id = product.category_id
        db_product.embedding = product.embedding
        db_product.last_updated = product.last_updated

        await self.session.commit()
        await self.session.refresh(db_product)

        return self._to_schema(db_product)

    async def delete(self, product_id: UUID) -> bool:

        result = await self.session.execute(
            select(ProductModel).where(
                ProductModel.id == product_id
            )
        )

        db_product = result.scalar_one_or_none()

        if db_product is None:
            return False

        await self.session.delete(db_product)
        await self.session.commit()

        return True