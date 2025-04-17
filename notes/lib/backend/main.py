from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from calendar_agent import create_event_with_langchain, list_upcoming_events
import socket
import uvicorn

app = FastAPI()

# Allow all origins for now (can be customized for production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request model
class ScheduleInput(BaseModel):
    user_input: str

# POST endpoint to create a calendar event
@app.post("/create_event/")
def create_event(data: ScheduleInput):
    return create_event_with_langchain(data.user_input)

# GET endpoint to fetch upcoming events
@app.get("/events/")
def get_events():
    return list_upcoming_events()

# Entry point for running the app
if __name__ == "__main__":
    hostname = socket.gethostname()
    ip_address = socket.gethostbyname(hostname)
    print(f"\n🚀 Calendar API is running at: http://{ip_address}:8000\n")
    
    uvicorn.run(app, host="0.0.0.0", port=8000)
