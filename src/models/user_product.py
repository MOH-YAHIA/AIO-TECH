from sqlalchemy import Column, Integer, DateTime, ForeignKey
from sqlalchemy.sql import func

from src.core.database import Base 
from src.models.user import User

class UserProductAnalysis(Base):
    __tablename__ = "UserProductAnalyses"

    # Composite Primary Key & Foreign Keys
    UserId = Column(
        Integer, 
        ForeignKey("Users.UserId", ondelete="CASCADE"), # Adjust "Users.UserId" to your actual user table
        primary_key=True, 
        index=True
    )
    
    ProductAnalysisId = Column(
        Integer, 
        ForeignKey("product_analyses.id", ondelete="CASCADE"), # Adjust to your actual product table name
        primary_key=True, 
        index=True
    )

    # Maps directly to PostgreSQL 'timestamp with time zone'
    SavedAt = Column(
        DateTime(timezone=True), 
        server_default=func.now(), 
        nullable=False
    )