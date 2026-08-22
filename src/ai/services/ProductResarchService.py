import asyncio

from ai.agents.ProductDescriptionAgent import ProductDescriptionAgent
from ai.agents.SocialReviewsAgent import SocialReviewsAgent
from ai.clients.GeminiClient import GeminiClient
from ai.tools.get_product_market_info import get_product_market_info
from ai.schemas.ProductResarchSchema import ProductResarchSchema


class ProductResearchService:
    def __init__(
        self,
        product_description_agent: ProductDescriptionAgent,
        social_reviews_agent: SocialReviewsAgent,
        gemini_client: GeminiClient,
    ):
        self.product_description_agent = product_description_agent
        self.social_reviews_agent = social_reviews_agent
        self.gemini_client = gemini_client

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

        return await self.gemini_client.create_product_response(
            product_name=product_name,
            market_info=market_info,
            description=description,
            reviews=reviews,
        )