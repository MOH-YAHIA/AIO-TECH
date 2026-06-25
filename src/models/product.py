from pgvector.sqlalchemy import Vector
from sqlalchemy import Column, Integer, String, Float, DateTime, func
from sqlalchemy.dialects.postgresql import JSONB
from src.core.database import Base 

class ProductAnalysis(Base):
    __tablename__ = "product_analyses"

    id = Column(Integer, primary_key=True, index=True)
    
    # Identity 
    name = Column(String, unique=True, nullable=False, index=True)
    category = Column(String, nullable=True)
    brand = Column(String, nullable=True)
    
    # Semantic Context (From Gemini)
    description = Column(String, nullable=True)
    sentiment_summary = Column(String, nullable=True)
    pros = Column(JSONB, nullable=False, default=list) # Still JSONB to safely hold the array of strings
    cons = Column(JSONB, nullable=False, default=list)
    
    # Local Market Metric (From Gemini)
    current_price_egp = Column(Float, nullable=False)
    
    # Global Indexing Metrics (Flattened from SerpApi)
    image_url = Column(String, nullable=True)
    global_rating = Column(Float, nullable=True)
    global_usd_price = Column(String, nullable=True) # Stored as string to safely handle formats like "$1,299.00"
    
    # State Invariants & Spatial Mapping
    last_ai_update = Column(DateTime, server_default=func.now(), onupdate=func.now())
    embedding = Column(Vector(768), nullable=True) # 768-D spatial constraint