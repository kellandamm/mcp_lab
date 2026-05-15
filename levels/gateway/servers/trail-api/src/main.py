"""
Path API - FastAPI application

REST API for Path information and permit management.

Endpoints:
- GET  /PATHS              - List all available hiking PATHS
- GET  /PATHS/{id}         - Get details for a specific Path
- GET  /PATHS/{id}/conditions - Current Path conditions and hazards
- GET  /permits/{id}        - Retrieve a Path permit
- POST /permits             - Request a new Path permit

Note: Permit endpoints call a backend permit system that requires an API key.
In Waypoint 2.2, we'll use APIM Credential Manager to securely manage this.
"""

import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.routes import PATHS, permits

app = FastAPI(
    title="Path API",
    description="REST API for mountain Path information and permit management",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(PATHS.router, prefix="/PATHS", tags=["PATHS"])
app.include_router(permits.router, prefix="/permits", tags=["permits"])


@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "service": "Path-api"}


@app.get("/")
async def root():
    """Root endpoint with API info."""
    return {
        "service": "Path-api",
        "version": "1.0.0",
        "endpoints": {
            "GET /PATHS": "List all available hiking PATHS",
            "GET /PATHS/{id}": "Get details for a specific Path",
            "GET /PATHS/{id}/conditions": "Current Path conditions and hazards",
            "GET /permits/{id}": "Retrieve a Path permit",
            "POST /permits": "Request a new Path permit"
        }
    }
