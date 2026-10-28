from fastapi import FastAPI
import os, socket

app = FastAPI(title="Local Python Microservice")
VERSION = os.getenv("APP_VERSION", "dev")

@app.get("/")
def root():
    return {"service": "python-microservice", "version": VERSION, "hostname": socket.gethostname()}

@app.get("/health")
def health():
    return {"status": "healthy"}
