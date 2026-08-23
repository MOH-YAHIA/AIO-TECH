from sqlalchemy.ext.asyncio import AsyncSession
from models.pydantic_schemas import Product
from ai.services import EmbeddingService
from ai.clients import GeminiClient
from repositories import ProductRepository

class SearchController():
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def search_by_product_descrption(self, product_description: str,
                                                embedding_dim: int,
                                                embedding_model: str,
                                                max_distance: float = 0.5,
                                                limit: int = 10,) -> list[Product]:
        llm_client = GeminiClient()
        embedding_service = EmbeddingService(llm_client, embedding_model)

        product_description_embeddings = await embedding_service.embed_text(
            text=product_description,
            embedding_dim=embedding_dim,
        )

        product_repository = ProductRepository(session=self.session)
        products = await product_repository.search_by_embedding_cosine_distance(
            embedding=product_description_embeddings,
            max_distance=max_distance,
            limit=limit,
        )

        return products