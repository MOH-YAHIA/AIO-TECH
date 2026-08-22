from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):

    DATABASE_URL: str
    EMBEDDING_DIMENSION: int
    SERPAPI_API_KEY : str
    GEMINI_API_KEY  : str
    model_config = SettingsConfigDict(        
        env_file= ".env",
    )


def get_settings():
    return Settings()