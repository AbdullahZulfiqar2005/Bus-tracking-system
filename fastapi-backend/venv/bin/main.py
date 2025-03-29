from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

# Root endpoint
@app.get("/")
async def home():
    return {"message": "FastAPI Backend is Running!"}

# Data model for GPS location
class LocationData(BaseModel):
    latitude: float
    longitude: float

@app.post("/update-location/")
async def update_location(data: LocationData):
    print(f"Received location: {data.latitude}, {data.longitude}")
    return {"message": "Location received successfully"}
