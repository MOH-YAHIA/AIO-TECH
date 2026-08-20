import asyncio
from uuid import UUID, uuid4
from datetime import datetime, timezone
from database import DatabaseManager
from helpers.config import get_settings
from models.CategoryModel import CategoryModel
from models.pydantic_schemas.category import Category
from models.pydantic_schemas.brand import Brand
from repositories.CategoryRepository import CategoryRepository
from repositories.BrandRepository import BrandRepository
from models.pydantic_schemas.product import Product
from repositories.ProductRepository import ProductRepository
async def main():

    settings = get_settings()

    database_manager = DatabaseManager(
        settings.DATABASE_URL
    )

    # Create database tables if not exist
    await database_manager.create_tables()

    # Create session manager
    session_manager = database_manager.get_async_session_manager()

    # Open database session
    async with session_manager() as session:
        product_repository = ProductRepository(session)
        brand_repository = BrandRepository(session)
        category_repository = CategoryRepository(session)

        # Create brand
        brand = Brand(
            id=uuid4(),
            name="Apple",
        )

        created_brand = await brand_repository.get_by_name("Apple")

        # Create category
        category = Category(
            id=uuid4(),
            name="Smartphones",
        )

        created_category = await category_repository.get_by_name("Smartphones")

        # Create product
        product = Product(
            name="iPhone 17",
            description="Latest Apple smartphone",
            pros=[
                "Excellent camera",
                "Powerful performance",
                "Long battery life",
            ],
            cons=[
                "Expensive",
                "No charger included",
            ],
            price_usd=999.99,
            global_rating=4.7,
            semantic_summary="A premium smartphone with excellent performance and camera quality.",
            image_url="https://example.com/iphone17.jpg",

            # Existing brand
            brand_id=created_brand.id,

            # Existing category
            category_id=created_category.id,

            # Must contain exactly the dimension of your VECTOR column
            embedding=[0.0] * 2048,

            last_updated=datetime.now(timezone.utc),
        )

        created_product = await product_repository.create(product)

        print(created_product.model_dump())


if __name__ == "__main__":
    asyncio.run(main())