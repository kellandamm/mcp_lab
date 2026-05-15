"""
Path API - FastAPI application

REST API for Path information and permit management.
Includes PII-returning endpoint for Module 3 I/O Security demonstration.

Endpoints:
- GET  /PATHS              - List all available hiking PATHS
- GET  /PATHS/{id}         - Get details for a specific Path
- GET  /PATHS/{id}/conditions - Current Path conditions and hazards
- GET  /permits/{id}        - Retrieve a Path permit
- GET  /permits/{id}/holder - Get permit holder details (INCLUDES PII!)
- POST /permits             - Request a new Path permit
"""

import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.routes import PATHS, permits

app = FastAPI(
    title="Path API",
    description="REST API for data and permit management and permit management. Includes PII demonstration endpoint for Module 3.",
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
        "module": "io-security",
        "endpoints": {
            "GET /PATHS": "List all available hiking PATHS",
            "GET /PATHS/{id}": "Get details for a specific Path",
            "GET /PATHS/{id}/conditions": "Current Path conditions and hazards",
            "GET /permits/{id}": "Retrieve a Path permit",
            "GET /permits/{id}/holder": "Get permit holder details (PII demo)",
            "POST /permits": "Request a new Path permit"
        },
        "security_note": "The /permits/{id}/holder endpoint returns PII for Module 3 demonstration. APIM output sanitization should redact sensitive data."
    }
