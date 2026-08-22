from google.adk.agents import LlmAgent
from google.adk.runners import InMemoryRunner

from ai.prompt_templates.english_locale import social_reviews


class SocialReviewsAgent:
    def __init__(self, model: str, search_tool):
        self.agent = LlmAgent(
            name="social_reviews_agent",
            model=model,
            instruction=social_reviews.SYSTEM_INSTRUCTION.substitute(),
            tools=[search_tool],
        )

        self.runner = InMemoryRunner(agent=self.agent)

    async def analyze(self, product_name: str):
        user_prompt = social_reviews.USER_INSTRUCTION.substitute(
            product_name=product_name
        )

        result = await self.runner.run_debug(
            user_prompt,
            verbose=True,
        )

        return result[0].content.parts[0].text