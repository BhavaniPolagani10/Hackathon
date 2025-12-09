"""Email routes"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List
from app.database import get_db
from app.models import Email
from app.schemas import EmailCreate, EmailResponse, EmailSummary
from app.services.email_processor import EmailProcessor

router = APIRouter(prefix="/emails", tags=["emails"])


@router.post("/", response_model=EmailResponse)
async def create_email(
    email: EmailCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new email conversation"""
    # Analyze the email
    analysis = EmailProcessor.analyze_email(
        email.subject,
        email.body,
        email.from_name or "",
        email.from_email
    )
    
    # Create email record
    db_email = Email(
        subject=email.subject,
        from_email=email.from_email,
        from_name=email.from_name,
        to_email=email.to_email,
        to_name=email.to_name,
        body=email.body,
        date=email.date,
        thread_id=email.thread_id,
        **analysis,
        status="analyzed"
    )
    
    db.add(db_email)
    await db.commit()
    await db.refresh(db_email)
    
    return db_email


@router.get("/", response_model=List[EmailResponse])
async def list_emails(
    skip: int = 0,
    limit: int = 100,
    status: str = None,
    db: AsyncSession = Depends(get_db)
):
    """List all email conversations"""
    query = select(Email)
    
    if status:
        query = query.where(Email.status == status)
    
    query = query.offset(skip).limit(limit).order_by(Email.created_at.desc())
    result = await db.execute(query)
    emails = result.scalars().all()
    
    return emails


@router.get("/{email_id}", response_model=EmailResponse)
async def get_email(
    email_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get a specific email conversation"""
    result = await db.execute(select(Email).where(Email.id == email_id))
    email = result.scalar_one_or_none()
    
    if not email:
        raise HTTPException(status_code=404, detail="Email not found")
    
    return email


@router.get("/{email_id}/summary", response_model=EmailSummary)
async def get_email_summary(
    email_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get email summary"""
    result = await db.execute(select(Email).where(Email.id == email_id))
    email = result.scalar_one_or_none()
    
    if not email:
        raise HTTPException(status_code=404, detail="Email not found")
    
    return EmailSummary(
        summary=email.summary or "",
        products_requested=email.products_requested or [],
        quantities=email.quantities or [],
        customer_name=email.customer_name,
        customer_company=email.customer_company,
        customer_email=email.customer_email,
        urgency=email.urgency or "medium",
        deadline=email.deadline,
        shipping_address=email.shipping_address,
        key_requirements=email.key_requirements or {}
    )


@router.post("/{email_id}/analyze")
async def analyze_email(
    email_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Analyze or re-analyze an email"""
    result = await db.execute(select(Email).where(Email.id == email_id))
    email = result.scalar_one_or_none()
    
    if not email:
        raise HTTPException(status_code=404, detail="Email not found")
    
    # Re-analyze the email
    analysis = EmailProcessor.analyze_email(
        email.subject,
        email.body,
        email.from_name or "",
        email.from_email
    )
    
    # Update email with analysis
    for key, value in analysis.items():
        setattr(email, key, value)
    
    email.status = "analyzed"
    
    await db.commit()
    await db.refresh(email)
    
    return {"message": "Email analyzed successfully", "email": email}


@router.delete("/{email_id}")
async def delete_email(
    email_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Delete an email conversation"""
    result = await db.execute(select(Email).where(Email.id == email_id))
    email = result.scalar_one_or_none()
    
    if not email:
        raise HTTPException(status_code=404, detail="Email not found")
    
    await db.delete(email)
    await db.commit()
    
    return {"message": "Email deleted successfully"}
