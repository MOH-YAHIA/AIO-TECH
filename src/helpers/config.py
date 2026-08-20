from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):

    DATABASE_URL: str
    EMBEDDING_DIMENSION: int
    model_config = SettingsConfigDict(        
        env_file= ".env",
    )


def get_settings():
    return Settings()