from langchain.chat_models import ChatOpenAI
from langchain.agents import initialize_agent, Tool
from langchain.schema import SystemMessage
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from datetime import timedelta, datetime
import dateparser
import re

SCOPES = ['https://www.googleapis.com/auth/calendar']

def get_calendar_service():
    creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    return build('calendar', 'v3', credentials=creds)

def schedule_event_in_google_calendar(title, start_datetime):
    end_datetime = start_datetime + timedelta(hours=1)
    service = get_calendar_service()

    event = {
        'summary': title.title(),
        'start': {'dateTime': start_datetime.isoformat(), 'timeZone': 'UTC'},
        'end': {'dateTime': end_datetime.isoformat(), 'timeZone': 'UTC'},
    }

    created_event = service.events().insert(calendarId='primary', body=event).execute()

    return {
        "title": created_event['summary'],
        "date": created_event['start']['dateTime'],
        "id": created_event['id']
    }

def extract_event_details(input_text: str):
    match = re.search(r"(?:schedule|set|create|add)\s+(?:a\s+)?(?P<title>.+?)\s+(on|at|for)?\s*(?P<time>.+)", input_text, re.IGNORECASE)
    title = match.group("title").strip() if match else input_text
    time_str = match.group("time").strip() if match else input_text

    parsed_datetime = dateparser.parse(time_str)
    if not parsed_datetime:
        return None, None
    return title, parsed_datetime

# Tool for LangChain
def calendar_agent_tool(input_text):
    title, date = extract_event_details(input_text)
    if not date:
        return {"error": "Couldn't parse date/time"}

    return schedule_event_in_google_calendar(title, date)

# LangChain agent setup
llm = ChatOpenAI(temperature=0)
tools = [Tool(name="Calendar Creator", func=calendar_agent_tool, description="Creates calendar events")]
agent = initialize_agent(tools, llm, agent="zero-shot-react-description")

# Expose this for FastAPI
def create_event_with_langchain(user_input: str):
    return agent.run(user_input)

def list_upcoming_events():
    service = get_calendar_service()
    now = datetime.utcnow().isoformat() + 'Z'
    events_result = service.events().list(calendarId='primary', timeMin=now, maxResults=10,
                                          singleEvents=True, orderBy='startTime').execute()
    events = events_result.get('items', [])

    return [
        {
            "title": event.get("summary"),
            "start": event["start"].get("dateTime", event["start"].get("date")),
            "end": event["end"].get("dateTime", event["end"].get("date"))
        } for event in events
    ]
