"""
Main FastAPI application for Email Summarization & Quote Generation
"""
import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import time

from app.config import settings
from app.api import api_router
from app.utils import test_db_connection

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="""
    Backend API for Email Summarization and Quote Generation
    
    Features:
    - Track and manage email conversations
    - AI-powered email summarization using Azure GPT-4o
    - Automated quote generation with pricing from PostgreSQL
    - PDF quote generation and download
    
    ## Email Management
    - List all email conversations
    - View conversation threads with messages
    - Summarize conversations to extract key information
    
    ## Quote Generation
    - Generate quotes from email conversations
    - Auto-calculate pricing based on previous purchases
    - Download quotes as professional PDF documents
    """,
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log all requests"""
    start_time = time.time()
    
    # Log request
    logger.info(f"Request: {request.method} {request.url.path}")
    
    # Process request
    response = await call_next(request)
    
    # Log response
    process_time = time.time() - start_time
    logger.info(
        f"Response: {request.method} {request.url.path} "
        f"Status: {response.status_code} "
        f"Time: {process_time:.3f}s"
    )
    
    return response


# Include API routes
app.include_router(api_router, prefix=settings.API_PREFIX)


# Health check endpoint
@app.get("/health", tags=["health"])
async def health_check():
    """
    Health check endpoint
    
    Returns API status and database connectivity
    """
    db_status = "healthy" if test_db_connection() else "unhealthy"
    
    return {
        "status": "healthy" if db_status == "healthy" else "degraded",
        "version": settings.APP_VERSION,
        "environment": settings.APP_ENV,
        "database": db_status,
        "services": {
            "api": "healthy",
            "database": db_status,
            "azure_openai": "configured" if settings.AZURE_OPENAI_API_KEY else "not_configured"
        }
    }


# Root endpoint
@app.get("/", tags=["root"])
async def root():
    """
    Root endpoint with API information
    """
    return {
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "docs": "/docs",
        "health": "/health",
        "api": settings.API_PREFIX
    }


# Error handlers
@app.exception_handler(404)
async def not_found_handler(request: Request, exc):
    """Handle 404 errors"""
    return JSONResponse(
        status_code=404,
        content={
            "detail": f"Endpoint {request.url.path} not found",
            "path": request.url.path
        }
    )


@app.exception_handler(500)
async def internal_error_handler(request: Request, exc):
    """Handle 500 errors"""
    logger.error(f"Internal server error: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error occurred",
            "error": str(exc) if settings.DEBUG else "Contact administrator"
        }
    )


# Startup event
@app.on_event("startup")
async def startup_event():
    """Run on application startup"""
    logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    logger.info(f"Environment: {settings.APP_ENV}")
    logger.info(f"API Prefix: {settings.API_PREFIX}")
    
    # Test database connection
    if test_db_connection():
        logger.info("Database connection successful")
    else:
        logger.warning("Database connection failed - some features may not work")
    
    # Check Azure OpenAI configuration
    if settings.AZURE_OPENAI_API_KEY:
        logger.info("Azure OpenAI configured")
    else:
        logger.warning("Azure OpenAI not configured - summarization features will not work")


# Shutdown event
@app.on_event("shutdown")
async def shutdown_event():
    """Run on application shutdown"""
    logger.info("Shutting down application")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    )
