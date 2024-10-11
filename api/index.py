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
    allow_origins=[
        "https://lyriclab-ten.vercel.app/",  # Update this with your frontend domain
        "http://localhost:3000",  # For local development
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class LyricsRequest(BaseModel):
    language: str
    genre: str
    description: str
    emotions: list[str] = []
    previous_lyrics: str | None = None
    version_count: int = 1
    musical_elements: dict = {
        "melody_style": "",
        "harmony_type": "",
        "instruments": [],
        "tempo": ""
    }

async def generate_lyrics_stream(prompt, version_index=0):
    try:
        completion = client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[
                {
                    "role": "system",
                    "content": """You are a professional songwriter and music composer. Create lyrics that match the specified genre and style. 
                    Format the output as proper song lyrics with verses and chorus. Include musical suggestions for melody, harmony, and instrumentation 
                    when specified. Version variations should maintain the core theme while exploring different emotional angles."""
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            temperature=0.7 + (version_index * 0.1),
            max_tokens=1024,
            top_p=0.8,
            stream=True
        )

        # Send version header first
        yield f"Version {version_index + 1}:\n"
        
        for chunk in completion:
            if hasattr(chunk.choices[0].delta, 'content'):
                content = chunk.choices[0].delta.content
                if content:
                    yield content

    except Exception as e:
        print(f"Error in generate_lyrics_stream: {str(e)}")
        yield f"Error generating lyrics: {str(e)}"

@app.post("/api/generate_lyrics")
async def generate_lyrics(request: LyricsRequest):
    try:
        emotions_str = ", ".join(request.emotions) if request.emotions else "neutral"
        refinement_context = f"\nPrevious version to refine: {request.previous_lyrics}" if request.previous_lyrics else ""
        
        musical_elements = ""
        if any(request.musical_elements.values()):
            musical_elements = f"""
            Musical Elements to incorporate:
            Melody Style: {request.musical_elements['melody_style']}
            Harmony Type: {request.musical_elements['harmony_type']}
            Instruments: {', '.join(request.musical_elements['instruments'])}
            Tempo: {request.musical_elements['tempo']}
            """

        base_prompt = f"""Create song lyrics with the following specifications:
        Language: {request.language}
        Genre: {request.genre}
        Emotional tone: {emotions_str}
        Description: {request.description}
        {musical_elements}
        {refinement_context}

        Structure the output exactly as follows:

        [Musical Arrangement]
        - Melody: (describe melody style)
        - Harmony: (describe harmony approach)
        - Instruments: (list key instruments)
        - Tempo: (specify tempo)

        [Lyrics]
        (Verse 1)
        (4 lines of verse)

        (Chorus)
        (4 lines of chorus)

        (Verse 2)
        (4 lines of verse)

        (Bridge)
        (2-4 lines of bridge)

        (Final Chorus)
        (4 lines of chorus)
        """

        async def combine_streams():
            for i in range(request.version_count):
                version_prompt = f"{base_prompt}\n\nThis is version {i + 1} of {request.version_count}."
                async for content in generate_lyrics_stream(version_prompt, i):
                    yield content
                if i < request.version_count - 1:
                    yield "\n\n"  # Add spacing between versions

        return StreamingResponse(
            combine_streams(),
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

    