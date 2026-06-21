import os
import sys
import subprocess
from sqlalchemy import create_engine, inspect
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

# =====================================================================
# 🛡️ AUTOMATED TABLE CHECK & INVARIANT PROTECTION
# =====================================================================
def verify_database_state():
    """
    Inspects the database schema on boot. If the target table is missing,
    it executes the centralized creation script using absolute paths.
    """
    inspector = inspect(engine)
    
    # NOTE: SQLAlchemy automatically maps CamelCase models to snake_case tables.
    # Verify if your table name in Postgres is exactly "product_analyses"
    target_table = "product_analyses" 
    
    if not inspector.has_table(target_table):
        print(f"⚠️ Table '{target_table}' not detected. Triggering automated migration...")
        
        try:
            # Deterministic Path Resolution: Find create_table.py in the same directory
            current_dir = os.path.dirname(os.path.abspath(__file__))
            script_path = os.path.join(current_dir, "create_table.py")
            
            # Execute utilizing the current active Python virtual environment executable
            subprocess.run([sys.executable, script_path], check=True)
            print("✅ Database state synchronized. Table created successfully.")
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Critical failure while executing create_table.py: {e}")
            # Non-zero exit prevents the faulty container from reporting healthy to Azure
            sys.exit(1) 
        except Exception as e:
            print(f"❌ Unexpected error checking schema invariants: {e}")
            sys.exit(1)

# Execute the health check before the server begins listening for routing requests
verify_database_state()

# =====================================================================
# 🏗️ SESSION & BASE INITIALIZATION
# =====================================================================

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