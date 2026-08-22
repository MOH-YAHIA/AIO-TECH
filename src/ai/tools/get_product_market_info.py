import httpx

from helpers.config import get_settings


async def get_product_market_info(product_name: str) -> dict:
    settings = get_settings()

    params = {
        "engine": "google_shopping_light",
        "q": product_name,
        "api_key": settings.SERPAPI_API_KEY,
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(
            "https://serpapi.com/search",
            params=params,
            timeout=10.0,
        )
        response.raise_for_status()
        data = response.json()

    items = (
        data.get("shopping_results")
        or data.get("inline_shopping_results")
        or []
    )

    if not items:
        return {
            "query": product_name,
            "found": False,
            "price": None,
            "rating": None,
            "image_url": None,
        }

    item = items[0]

    return {
        "query": product_name,
        "found": True,
        "title": item.get("title"),
        "price": item.get("price"),
        "extracted_price": item.get("extracted_price"),
        "rating": item.get("rating"),
        "image_url": item.get("thumbnail"),
    }