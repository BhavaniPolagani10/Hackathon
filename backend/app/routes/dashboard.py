"""Dashboard routes"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.database import get_db
from app.models import Email, Quote
from app.schemas import DashboardStats

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("/stats", response_model=DashboardStats)
async def get_dashboard_stats(db: AsyncSession = Depends(get_db)):
    """Get dashboard statistics"""
    # Count total emails
    total_emails_result = await db.execute(select(func.count(Email.id)))
    total_emails = total_emails_result.scalar()
    
    # Count analyzed emails
    analyzed_result = await db.execute(
        select(func.count(Email.id)).where(Email.status.in_(["analyzed", "quoted"]))
    )
    analyzed_emails = analyzed_result.scalar()
    
    # Count quotes generated
    quotes_result = await db.execute(select(func.count(Quote.id)))
    quotes_generated = quotes_result.scalar()
    
    # Count pending emails
    pending_result = await db.execute(
        select(func.count(Email.id)).where(Email.status == "new")
    )
    pending_emails = pending_result.scalar()
    
    return DashboardStats(
        total_emails=total_emails or 0,
        analyzed_emails=analyzed_emails or 0,
        quotes_generated=quotes_generated or 0,
        pending_emails=pending_emails or 0
    )
