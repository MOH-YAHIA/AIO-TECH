from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy import text

from models.BaseModel import Base
from models import BrandModel , CategoryModel ,ProductModel # Load all model modules so their tables are registered with Base.metadata.(ether you import the class of the module. python will go throw classes)

class DatabaseManager:
    def __init__(self,database_url: str) -> None:

        self.engine = create_async_engine(
                database_url, # see the database location, the driver to use.
                echo=False, # if you want to see the SQL statements
            )
        self.session_manager = async_sessionmaker(
            self.engine,
            class_=AsyncSession, # the type of session to create
            expire_on_commit=False, # disable expire on commit. 
        )
    def get_async_session_manager(self) -> async_sessionmaker[AsyncSession]:

        return self.session_manager

    async def create_tables(self) -> None:
        async with self.engine.begin() as connection:
            # Enable pgvector extension
            await connection.execute(
                text("CREATE EXTENSION IF NOT EXISTS vector")
            )

            await connection.run_sync(
                Base.metadata.create_all # create all tables witch inherit from BaseModel if not exist
            )

        return None

    async def close_database_engine(self) -> None:
        await self.engine.dispose()