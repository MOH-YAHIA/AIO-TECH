# Database operations
# Brand - BrandModel conversion

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from models.BrandModel import BrandModel            # BrandModel for sqlalchemy and postgres
from models.pydantic_schemas.brand import Brand     # Brand for python


class BrandRepository:
    def __init__(self,session: AsyncSession) -> None:
        self.session = session

    async def create(self,brand: Brand) -> Brand:

        db_brand = BrandModel(
            id=brand.id,
            name=brand.name,
        )

        self.session.add(db_brand)

        await self.session.commit()    # sqlalchemy ask psycopg driver to execute query
        await self.session.refresh(db_brand)   # refresh brand with stored data after commit

        return Brand(
            id=db_brand.id,
            name=db_brand.name,
        )
    
    async def get_by_id(self, brand_id: UUID) -> Brand | None:

        result = await self.session.execute(
            select(BrandModel).where(
                BrandModel.id == brand_id
            )
        )

        db_brand = result.scalar_one_or_none() 

        if db_brand is None:
            return None

        return Brand(
            id=db_brand.id,
            name=db_brand.name,
        )
    
    async def get_by_name(self, name: str) -> Brand | None:

        result = await self.session.execute(
            select(BrandModel).where(
                BrandModel.name == name
            )
        )

        db_brand = result.scalar_one_or_none()

        if db_brand is None:
            return None

        return Brand(
            id=db_brand.id,
            name=db_brand.name,
        )


    async def update(self, brand: Brand) -> Brand | None:

        result = await self.session.execute(
            select(BrandModel).where(
                BrandModel.id == brand.id
            )
        )

        db_brand = result.scalar_one_or_none()

        if db_brand is None:
            return None

        db_brand.name = brand.name

        await self.session.commit()
        await self.session.refresh(db_brand)

        return Brand(
            id=db_brand.id,
            name=db_brand.name,
        )

    async def delete(self, brand_id: UUID,) -> bool:

        result = await self.session.execute(
            select(BrandModel).where(
                BrandModel.id == brand_id
            )
        )

        db_brand = result.scalar_one_or_none()

        if db_brand is None:
            return False

        await self.session.delete(db_brand)
        await self.session.commit()

        return True