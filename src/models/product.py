from sqlalchemy import Column, Integer, String, Float, DateTime, func
from sqlalchemy.dialects.postgresql import JSONB
from src.core.database import Base  # Importing the central declarative base

class ProductAnalysis(Base):
    __tablename__ = "product_analyses"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False, index=True)
    rating = Column(Float, nullable=True)
    current_price_egp = Column(Float, nullable=False)
    lowest_ever_price = Column(Float, nullable=True)
    
    # JSONB safely preserves arrays, dictionaries, and dynamic configurations natively
    price_history_6m = Column(JSONB, nullable=False) 
    pros = Column(JSONB, nullable=False)
    cons = Column(JSONB, nullable=False)
    sentiment_summary = Column(String, nullable=True)
    links = Column(JSONB, nullable=False)
    lowest_price_link = Column(String, nullable=True)
    
    # Automatically tracks when data becomes stale
    last_ai_update = Column(DateTime, server_default=func.now(), onupdate=func.now())
    image_url = Column(String, nullable=True)