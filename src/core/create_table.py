import os
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, func, text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import declarative_base
from pgvector.sqlalchemy import Vector 
from dotenv import load_dotenv

load_dotenv()

# 1. Database Connection
DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL)
Base = declarative_base()

# 2. Define the Updated Product Schema Matrix
class ProductAnalysis(Base):
    __tablename__ = "product_analyses"

    id = Column(Integer, primary_key=True, index=True)
    
    # Identity
    name = Column(String, nullable=False, index=True)
    category = Column(String, nullable=True)
    brand = Column(String, nullable=True)
    
    # Semantic Context (From Gemini)
    description = Column(String, nullable=True)
    sentiment_summary = Column(String, nullable=True)
    pros = Column(JSONB, nullable=False, default=list)
    cons = Column(JSONB, nullable=False, default=list)
    
    # Local Market Metric (From Gemini)
    current_price_egp = Column(Float, nullable=False)
    
    # Global Indexing Metrics (Flattened from SerpApi)
    image_url = Column(String, nullable=True)
    global_rating = Column(Float, nullable=True)
    global_usd_price = Column(String, nullable=True)
    
    # State Invariants & Spatial Mapping
    last_ai_update = Column(DateTime, server_default=func.now(), onupdate=func.now())
    embedding = Column(Vector(768), nullable=True)

# 3. Execution Pipeline
def build_database_schema():
    print("🚀 Connecting to your database to build the flattened schemas...")
    
    with engine.connect() as conn:
        # Invariant: Extension must be initialized BEFORE table/index creation
        print("🔧 Enabling PostgreSQL Trigram Extension...")
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS pg_trgm;"))

        # Invariant: Vector extension for semantic search with embeddings
        conn.execute(text("CREATE EXTENSION IF NOT EXISTS vector;"))
        conn.commit()

    # CRITICAL INVARIANT: Drop existing table to prevent column mismatch crashes
    print("Dropping outdated tables to enforce new schema invariants...")
    Base.metadata.drop_all(bind=engine)

    print("Creating tables via SQLAlchemy ORM...")
    Base.metadata.create_all(bind=engine)

    with engine.connect() as conn:
        # Invariant: GIN Index speeds up fuzzy string chunk matching significantly
        print("⚡ Creating GIN Trigram Index for fast fuzzy search matching...")
        conn.execute(text("""
            CREATE INDEX IF NOT EXISTS idx_products_name_trgm 
            ON product_analyses USING gin (name gin_trgm_ops);
        """))
        conn.commit()
        
    print("Database table structure is fully operational!")

if __name__ == "__main__":
    build_database_schema()