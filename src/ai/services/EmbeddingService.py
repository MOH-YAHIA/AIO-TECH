import asyncio


class EmbeddingService:
    def __init__(self, llm_client, embedding_model : str):
        self.llm_client = llm_client
        self.embedding_model= embedding_model


    async def embed_text(
            self,
            text: str,
            embedding_dim: int,
        ) -> list[float]:
            
        return await self.llm_client.embed_text(
            model=self.embedding_model,
            text=text,
            embedding_dim=embedding_dim,
        )