from uuid import UUID
from datetime import datetime, timezone

from sqlalchemy.ext.asyncio import AsyncSession
from google.adk.tools import google_search
from repositories import ProductRepository
from models.pydantic_schemas import Product
from ai.services import EmbeddingService,ProductResearchService
from ai.clients import GeminiClient
from ai.agents import ProductDescriptionAgent, SocialReviewsAgent
from helpers.config import get_settings
class DataController():
    def __init__(self, session: AsyncSession):
        self.session = session
        self.settings = get_settings()

    async def get_product(self,product_name : str, brand_id : UUID, category_id : UUID) -> Product:
        llm_client = GeminiClient()
        embedding_service = EmbeddingService(llm_client=llm_client, 
                                                embedding_model=self.settings.EMBEDDING_MODEL)
        product_description_agent = ProductDescriptionAgent(
            model=self.settings.GENERATION_MODEL,
            search_tool=google_search,
        )
        reviews_agent = SocialReviewsAgent(
            model=self.settings.GENERATION_MODEL,
            search_tool=google_search,
        )

        product_research_service = ProductResearchService(
            product_description_agent=product_description_agent,
            social_reviews_agent=reviews_agent,
            llm_client=llm_client,
            generation_model=self.settings.GENERATION_MODEL,
        )

        product_research = await product_research_service.research(product_name=product_name)
        product_semantic_text = " ".join([
            product_research.name,
            product_research.description,
            " ".join(product_research.pros),
            " ".join(product_research.cons),
            product_research.semantic_summary,
            ])
        product_semantic_embeddings = await embedding_service.embed_text(
            text=product_semantic_text,
            embedding_dim=self.settings.EMBEDDING_DIMENSION,
        )

        return Product(
            name=product_research.name,
            description=product_research.description,
            pros=product_research.pros,
            cons=product_research.cons,
            price_usd=product_research.price_usd,
            global_rating=product_research.global_rating,
            semantic_summary=product_research.semantic_summary,
            image_url=product_research.image_url,
            brand_id=brand_id,
            category_id=category_id,
            embedding=product_semantic_embeddings,
            last_updated=datetime.now(timezone.utc),
        )
    
    async def update_product_or_create_one(self,product_name : str, brand_id : UUID, category_id : UUID):
        product_repository = ProductRepository(session = self.session)
        product = await self.get_product(product_name=product_name, brand_id=brand_id, category_id=category_id)

        db_product = await product_repository.get_by_name(name=product_name)

        if db_product is None:
            return await product_repository.create(product=product)
        else:
            return await product_repository.update(product=product)
      
