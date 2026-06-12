import os
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, func, text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import declarative_base, sessionmaker
from dotenv import load_dotenv

load_dotenv()

# 1. Database Connection
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Base = declarative_base()

# 2. Define the Product Schema Matrix
class ProductAnalysis(Base):
    __tablename__ = "product_analyses"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False, index=True)
    rating = Column(Float, nullable=True)
    current_price_egp = Column(Float, nullable=False)
    lowest_ever_price = Column(Float, nullable=True)
    
    # Store complex JSON payloads natively in Postgres
    price_history_6m = Column(JSONB, nullable=False) 
    pros = Column(JSONB, nullable=False)
    cons = Column(JSONB, nullable=False)
    sentiment_summary = Column(String, nullable=True)
    links = Column(JSONB, nullable=False)
    lowest_price_link = Column(String, nullable=True)
    
    last_ai_update = Column(DateTime, server_default=func.now(), onupdate=func.now())
    image_url = Column(String, nullable=True)

# 3. Execution Pipeline
def build_database_schema():
    print("🚀 Connecting to your new database to build schemas...")
    
    with engine.connect() as conn:
        # Invariant: Extension must be initialized BEFORE table/index creation
        print("🔧 Enabling PostgreSQL Trigram Extension...")
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS pg_trgm;"))
        conn.commit()

    print("🏗️  Creating tables via SQLAlchemy ORM...")
    Base.metadata.create_all(bind=engine)

    with engine.connect() as conn:
        # Invariant: GIN Index speeds up fuzzy string chunk matching significantly
        print("⚡ Creating GIN Trigram Index for fast fuzzy search matching...")
        conn.execute(text("""
            CREATE INDEX IF NOT EXISTS idx_products_name_trgm 
            ON product_analyses USING gin (name gin_trgm_ops);
        """))
        conn.commit()
        
    print("🎉 Database table structure is fully operational!")

if __name__ == "__main__":
    build_database_schema()