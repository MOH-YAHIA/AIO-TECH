from contextlib import asynccontextmanager
from fastapi import FastAPI
from database import DatabaseManager
from helpers.config import get_settings
from routes.data import data_router
import uvicorn

@asynccontextmanager
async def lifespan(app: FastAPI):
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
        app.session = session

    yield

    await database_manager.close_database_engine()

def create_app() -> FastAPI:
    app = FastAPI(lifespan=lifespan)

    app.include_router(data_router)

    return app

app = create_app()

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
    # uv run uvicorn main:app --host 127.0.0.1 --port 8000 --reload