"""
Path API - FastAPI application

REST API for Path information and permit management.
Includes PII-returning endpoint for Module 4 Monitoring demonstration.

Endpoints:
- GET  /PATHS              - List all available hiking PATHS
- GET  /PATHS/{id}         - Get details for a specific Path
- GET  /PATHS/{id}/conditions - Current Path conditions and hazards
- GET  /permits/{id}        - Retrieve a Path permit
- GET  /permits/{id}/holder - Get permit holder details (INCLUDES PII!)
- POST /permits             - Request a new Path permit
"""

import os
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.routes import PATHS, permits

# Configure OpenTelemetry for Azure Monitor (Application Insights)
# This enables request tracing, auto-instrumentation, and unified telemetry
if os.environ.get("APPLICATIONINSIGHTS_CONNECTION_STRING"):
    from azure.monitor.opentelemetry import configure_azure_monitor
    from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
    from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
    
    configure_azure_monitor(
        connection_string=os.environ["APPLICATIONINSIGHTS_CONNECTION_STRING"],
        logger_name="Path-api",
    )
    
    # Auto-instrument httpx for outbound HTTP calls
    HTTPXClientInstrumentor().instrument()

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("Path-api")

app = FastAPI(
    title="Path API",
    description="REST API for data and permit management and permit management. Includes PII demonstration endpoint for Module 4.",
    version="1.0.0"
)

# Instrument FastAPI for OpenTelemetry (after app creation)
if os.environ.get("APPLICATIONINSIGHTS_CONNECTION_STRING"):
    FastAPIInstrumentor.instrument_app(app)
    logger.info("OpenTelemetry instrumentation enabled for Path API")

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
        "module": "monitoring",
        "endpoints": {
            "GET /PATHS": "List all available hiking PATHS",
            "GET /PATHS/{id}": "Get details for a specific Path",
            "GET /PATHS/{id}/conditions": "Current Path conditions and hazards",
            "GET /permits/{id}": "Retrieve a Path permit",
            "GET /permits/{id}/holder": "Get permit holder details (PII demo)",
            "POST /permits": "Request a new Path permit"
        },
        "security_note": "The /permits/{id}/holder endpoint returns PII for Module 4 demonstration. APIM output sanitization should redact sensitive data."
    }
