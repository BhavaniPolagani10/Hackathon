"""API endpoints module"""
from fastapi import APIRouter
from .emails import router as emails_router
from .quotes import router as quotes_router
from .opportunities import router as opportunities_router

# Create main API router
api_router = APIRouter()

# Include sub-routers
api_router.include_router(emails_router)
api_router.include_router(quotes_router)
api_router.include_router(opportunities_router)

__all__ = ["api_router"]
