from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from groq import Groq
import os
from dotenv import load_dotenv
import asyncio

# Load environment variables
load_dotenv()

# Configure Groq client
client = Groq(api_key=os.getenv("GROQ_API_KEY"))

app = FastAPI()

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class LyricsRequest(BaseModel):
    language: str
    genre: str
    description: str

async def generate_lyrics_stream(prompt):
    try:
        completion = client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[
                {
                    "role": "system",
                    "content": "You are a professional songwriter. Create lyrics that match the specified genre and style. Format the output as proper song lyrics with verses and chorus."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            temperature=0.7,
            max_tokens=1024,
            top_p=0.8,
            stream=True
        )

        accumulated_text = ""
        for chunk in completion:
            if hasattr(chunk.choices[0].delta, 'content'):
                content = chunk.choices[0].delta.content
                if content:
                    accumulated_text += content
                    yield content

        if not accumulated_text:
            yield "No lyrics were generated. Please try again."

    except Exception as e:
        print(f"Error in generate_lyrics_stream: {str(e)}")
        yield f"Error generating lyrics: {str(e)}"

@app.post("/api/generate_lyrics")
async def generate_lyrics(request: LyricsRequest):
    try:
        prompt = f"""Write song lyrics based on the following criteria:
        Language: {request.language}
        Genre: {request.genre}
        Description: {request.description}

        Please create original, creative lyrics that match the requested genre and style.
        Format the lyrics with proper verse and chorus structure.
        The response should only contain the lyrics, no additional explanations or comments.
        """

        return StreamingResponse(
            generate_lyrics_stream(prompt),
            media_type="text/plain",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )

    except Exception as e:
        print(f"Error in generate_lyrics endpoint: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Error generating lyrics: {str(e)}"
        )

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)