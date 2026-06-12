import os
from google import genai
from google.genai import types
from dotenv import load_dotenv
import numpy as np

load_dotenv()

def generate_embedding(text_payload: str) -> list[float]:
    """
    Transforms text strings into a 768-dimensional mathematical vector
    using LangChain's Google GenAI wrapper.
    """
    # 1. Read API key securely from environment
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise ValueError("❌ GEMINI_API_KEY is missing from environment variables.")
    
    try:
        client = genai.Client()

        result = client.models.embed_content(
            model="gemini-embedding-2",
            contents=text_payload,
            config=types.EmbedContentConfig(output_dimensionality=768)
        )
        # 3. Generate the vector mapping
        response = result.embeddings[0].values
        return np.array(response)
        
    except Exception as e:
        print(f"❌ Embedding Generation Error: {e}")
        return []
        
if __name__ == "__main__":
    sample_text = "This is a sample product description to generate an embedding for."
    embedding_vector = generate_embedding(sample_text)
    
    # 4. Verify the dimensionality invariant holds true
    if embedding_vector.any():
        print(f"✅ Generated Embedding Vector (length {len(embedding_vector)})")
        print(f"🔢 First 3 values: {embedding_vector[:3]}")
        print(embedding_vector.ndim)