from google.adk.agents import LlmAgent
from google.adk.runners import InMemoryRunner

from ai.prompt_templates.english_locale import product_response
from ai.schemas.ProductResarchSchema import ProductResarchSchema


class ProductResearchAgent:
    def __init__(
        self,
        model: str,
        product_description_agent,
        social_reviews_agent,
    ):
        self.agent = LlmAgent(
            name="product_research_agent",
            model=model,
            instruction=product_response.SYSTEM_INSTRUCTION.substitute(),
            sub_agents=[
                product_description_agent,
                social_reviews_agent,
            ],
            output_schema=ProductResarchSchema,
        )

        self.runner = InMemoryRunner(agent=self.agent)

    async def research(
        self,
        product_name: str,
        market_info: dict,
    ):
        user_prompt = product_response.USER_INSTRUCTION.substitute(
            product_name=product_name,
            market_info=market_info,
        )

        result = await self.runner.run_debug(
            user_prompt,
            verbose=True,
        )

        return result[0].content.parts[0].text