from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.api.routes import router as product_router

# 1. Initialize the ASGI App
app = FastAPI(
    title="AioTech Core API",
    description="Vector Search & LLM-Grounded E-commerce Aggregator",
    version="1.0.0"
)

# 2. CORS Edge Case Protection
# Invariant: If your frontend runs on localhost:3000, the browser blocks requests 
# to localhost:8000 unless CORS headers explicitly allow it.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict this to specific domains in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. Mount the modular router
app.include_router(product_router)

@app.get("/health")
def health_check():
    return {"status": "operational", "engine": "FastAPI + pgvector"}

# 4. Local Execution Server
if __name__ == "__main__":
    import uvicorn
    # reload=True ensures the server auto-restarts when you edit code
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000, reload=True)