from sqlalchemy import Column, Integer
from src.core.database import Base

class User(Base):
    # This MUST exactly match the casing of the table .NET created
    __tablename__ = "Users" 
    
    # Optional: Tells SQLAlchemy this table already exists, don't try to recreate it
    __table_args__ = {'extend_existing': True}

    # You ONLY need to define the Primary Key that you are mapping to.
    # Ignore email, password, etc. — Python doesn't need to know they exist.
    UserId = Column(Integer, primary_key=True)