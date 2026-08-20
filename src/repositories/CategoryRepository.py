# Database operations
# category - categoryModel conversion

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from models.CategoryModel import CategoryModel            # categoryModel for sqlalchemy and postgres
from models.pydantic_schemas.category import Category     # category for python


class CategoryRepository:
    def __init__(self,session: AsyncSession) -> None:
        self.session = session

    async def create(self,category: Category) -> Category:

        db_category = CategoryModel(
            id=category.id,
            name=category.name,
        )

        self.session.add(db_category)

        await self.session.commit()    # sqlalchemy ask psycopg driver to execute query
        await self.session.refresh(db_category)   # refresh category with stored data after commit

        return Category(
            id=db_category.id,
            name=db_category.name,
        )
    
    async def get_by_id(self, category_id: UUID) -> Category | None:

        result = await self.session.execute(
            select(CategoryModel).where(
                CategoryModel.id == category_id
            )
        )

        db_category = result.scalar_one_or_none() 

        if db_category is None:
            return None

        return Category(
            id=db_category.id,
            name=db_category.name,
        )
    
    async def get_by_name(self, name: str) -> Category | None:

        result = await self.session.execute(
            select(CategoryModel).where(
                CategoryModel.name == name
            )
        )

        db_category = result.scalar_one_or_none()

        if db_category is None:
            return None

        return Category(
            id=db_category.id,
            name=db_category.name,
        )


    async def update(self, category: Category) -> Category | None:

        result = await self.session.execute(
            select(CategoryModel).where(
                CategoryModel.id == category.id
            )
        )

        db_category = result.scalar_one_or_none()

        if db_category is None:
            return None

        db_category.name = category.name

        await self.session.commit()
        await self.session.refresh(db_category)

        return Category(
            id=db_category.id,
            name=db_category.name,
        )

    async def delete(self, category_id: UUID,) -> bool:

        result = await self.session.execute(
            select(CategoryModel).where(
                CategoryModel.id == category_id
            )
        )

        db_category = result.scalar_one_or_none()

        if db_category is None:
            return False

        await self.session.delete(db_category)
        await self.session.commit()

        return True