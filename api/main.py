from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import os
from waste_chatbot import GamifiedWasteChatbot

app = FastAPI()

# Configuration CORS pour permettre les requêtes depuis Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # En production, spécifiez les origines exactes
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialisation du chatbot
chatbot = GamifiedWasteChatbot()

class MessageRequest(BaseModel):
    message: str
    location: Optional[str] = None

class MessageResponse(BaseModel):
    response: str
    points: Optional[int] = None
    badges: Optional[List[str]] = None

class ChallengeResponse(BaseModel):
    title: str
    description: str
    difficulty: str
    tips: List[str]

class QuizQuestion(BaseModel):
    question: str
    options: List[str]
    correct: str
    explanation: str

@app.post("/chat", response_model=MessageResponse)
async def chat(request: MessageRequest):
    try:
        # Si une localisation est fournie, la définir
        if request.location:
            chatbot.set_user_location(request.location)
        
        response = chatbot.get_response(request.message)
        
        return MessageResponse(
            response=response,
            points=chatbot.user_points,
            badges=chatbot.badges
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/analyze-image")
async def analyze_image(
    file: UploadFile = File(...),
    message: Optional[str] = None,
    location: Optional[str] = None
):
    try:
        # Sauvegarder temporairement l'image
        temp_path = f"temp_{file.filename}"
        with open(temp_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        if location:
            chatbot.set_user_location(location)
        
        response = chatbot.analyze_waste_image(temp_path, message)
        
        # Nettoyer le fichier temporaire
        os.remove(temp_path)
        
        return {"response": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/daily-challenge", response_model=ChallengeResponse)
async def get_daily_challenge():
    try:
        challenge = chatbot.get_daily_challenge()
        return ChallengeResponse(
            title=challenge["title"],
            description=challenge["description"],
            difficulty=challenge["difficulty"],
            tips=challenge["tips"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/complete-challenge/{challenge_title}")
async def complete_challenge(challenge_title: str):
    try:
        response = chatbot.complete_challenge(challenge_title)
        return {
            "message": response,
            "points": chatbot.user_points,
            "badges": chatbot.badges
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/quiz", response_model=QuizQuestion)
async def get_quiz():
    try:
        quiz = chatbot.get_quiz_question()
        return QuizQuestion(
            question=quiz["question"],
            options=quiz["options"],
            correct=quiz["correct"],
            explanation=quiz["explanation"]
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/stats")
async def get_stats():
    try:
        return {
            "points": chatbot.user_points,
            "badges": chatbot.badges,
            "completed_challenges": len([c for c in chatbot.user_challenges if c["completed"]])
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="10.0.8.202", port=8000) 