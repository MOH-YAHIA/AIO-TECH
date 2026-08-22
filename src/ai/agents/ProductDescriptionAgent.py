import os

from google import genai
from google.adk.agents import LlmAgent
from google.adk.runners import InMemoryRunner

from ai.prompt_templates.english_locale import product_description
from helpers.config import get_settings

class ProductDescriptionAgent:
    def __init__(self, model: str, search_tool):
        os.environ["GEMINI_API_KEY"] = get_settings().GEMINI_API_KEY        
        self.agent = LlmAgent(
            name="product_description_agent",
            model=model,
            instruction=product_description.SYSTEM_INSTRUCTION.substitute(),
            tools=[search_tool],
        )

        self.runner = InMemoryRunner(agent=self.agent)

    async def analyze(self, product_name: str):
        user_prompt = product_description.USER_INSTRUCTION.substitute(
            product_name=product_name
        )

        result = await self.runner.run_debug(
            user_prompt,
            verbose=True,
        )

        return result[0].content.parts[0].text