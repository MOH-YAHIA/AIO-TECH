import asyncio

from ai.agents import ProductDescriptionAgent
from ai.agents import SocialReviewsAgent
from ai.clients import GeminiClient
from ai.tools import get_product_market_info
from ai.schemas import ProductResarchSchema


class ProductResearchService:
    def __init__(
        self,
        product_description_agent: ProductDescriptionAgent,
        social_reviews_agent: SocialReviewsAgent,
        llm_client: GeminiClient,
        generation_model: str,
    ):
        self.product_description_agent = product_description_agent
        self.social_reviews_agent = social_reviews_agent
        self.llm_client = llm_client
        self.generation_model= generation_model

    async def research(self, product_name: str) -> ProductResarchSchema:

        market_info, description, reviews = await asyncio.gather(
            get_product_market_info(product_name),
            self.product_description_agent.analyze(
                product_name,
            ),
            self.social_reviews_agent.analyze(
                product_name,
            ),
        )

        return await self.llm_client.create_product_response(
            model=self.generation_model,
            product_name=product_name,
            market_info=market_info,
            description=description,
            reviews=reviews,
        )