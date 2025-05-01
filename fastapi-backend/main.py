from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
import firebase_admin
from firebase_admin import credentials, db

# Firebase setup
cred = credentials.Certificate("bus-tracking-46939-firebase-adminsdk-fbsvc-983bf6d36b.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://bus-tracking-46939-default-rtdb.firebaseio.com/'
})

app = FastAPI()

# Serve static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Serve index.html on root
@app.get("/", response_class=HTMLResponse)
def serve_index():
    with open("static/index.html", "r") as f:
        return f.read()

# Location receiving endpoint
@app.post("/update-location/")
async def send_location(request: Request):
    data = await request.json()
    lat = data['latitude']
    lng = data['longitude']
    ref = db.reference("busLocation")
    ref.set({"lat": lat, "lng": lng})
    return {"message": "Location saved"}
