import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from dotenv import load_dotenv

load_dotenv()

# Read the connection string from your root .env file
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("❌ DATABASE_URL is not set in the environment or .env file.")

# Initialize the connection engine with production pooling rules
engine = create_engine(
    DATABASE_URL,
    pool_size=5,
    max_overflow=10,
    pool_timeout=30
)

# Establish the session transaction constructor
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Shares a single declarative base across all application models
Base = declarative_base()

# FastAPI Context Dependency Provider to automate session lifecycle cleanup
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()