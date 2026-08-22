from google import genai
from google.genai import types
from helpers.config import get_settings
from ai.schemas.ProductResarchSchema import ProductResarchSchema
from ai.prompt_templates.english_locale import product_response


class GeminiClient:
    def __init__(
        self,
        model: str,
    ):
        self.client = genai.Client(api_key=get_settings().GEMINI_API_KEY)
        self.model = model

    async def create_product_response(
        self,
        product_name: str,
        market_info: dict,
        description: str,
        reviews: str,
    ) -> ProductResarchSchema:

        user_prompt = product_response.USER_INSTRUCTION.substitute(
            product_name=product_name,
            market_info=market_info,
            description=description,
            reviews=reviews,
        )

        response = await self.client.aio.models.generate_content(
            model=self.model,
            contents=user_prompt,
            config=types.GenerateContentConfig(
                system_instruction=(
                    product_response.SYSTEM_INSTRUCTION.substitute()
                ),
                response_mime_type="application/json",
                response_schema=ProductResarchSchema,
            ),
        )

        return ProductResarchSchema.model_validate_json(response.text)