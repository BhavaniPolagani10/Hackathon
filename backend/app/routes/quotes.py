"""Quote routes"""
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List
from app.database import get_db
from app.models import Email, Quote
from app.schemas import QuoteCreate, QuoteResponse
from app.services.quote_generator import QuoteGenerator
from app.services.pdf_generator import PDFGenerator

router = APIRouter(prefix="/quotes", tags=["quotes"])


@router.post("/", response_model=QuoteResponse)
async def create_quote(
    quote: QuoteCreate,
    db: AsyncSession = Depends(get_db)
):
    """Create a new quote"""
    # Verify email exists
    result = await db.execute(select(Email).where(Email.id == quote.email_id))
    email = result.scalar_one_or_none()
    
    if not email:
        raise HTTPException(status_code=404, detail="Email not found")
    
    # Generate quote number
    quote_number = QuoteGenerator.generate_quote_number()
    
    # Create quote
    db_quote = Quote(
        quote_number=quote_number,
        email_id=quote.email_id,
        customer_name=quote.customer_name,
        customer_company=quote.customer_company,
        customer_email=quote.customer_email,
        shipping_address=quote.shipping_address,
        products=quote.products,
        quantities=quote.quantities,
        prices=quote.prices,
        subtotal=quote.subtotal,
        tax=quote.tax,
        shipping_cost=quote.shipping_cost,
        total=quote.total,
        estimated_delivery=quote.estimated_delivery,
        delivery_deadline=quote.delivery_deadline,
        urgency=quote.urgency,
        notes=quote.notes,
        terms_and_conditions=QuoteGenerator.generate_terms_and_conditions(),
        status="draft"
    )
    
    db.add(db_quote)
    
    # Update email status
    email.status = "quoted"
    
    await db.commit()
    await db.refresh(db_quote)
    
    return db_quote


@router.post("/from-email/{email_id}", response_model=QuoteResponse)
async def generate_quote_from_email(
    email_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Generate a quote automatically from an email"""
    # Get email
    result = await db.execute(select(Email).where(Email.id == email_id))
    email = result.scalar_one_or_none()
    
    if not email:
        raise HTTPException(status_code=404, detail="Email not found")
    
    # Prepare email data
    email_data = {
        "from_name": email.from_name,
        "from_email": email.from_email,
        "subject": email.subject,
        "body": email.body
    }
    
    # Prepare analysis data
    analysis = {
        "customer_name": email.customer_name,
        "customer_company": email.customer_company,
        "customer_email": email.customer_email,
        "products_requested": email.products_requested or [],
        "quantities": email.quantities or [],
        "deadline": email.deadline,
        "shipping_address": email.shipping_address,
        "urgency": email.urgency,
        "summary": email.summary
    }
    
    # Generate quote data
    quote_data = QuoteGenerator.create_quote_from_email_data(email_data, analysis)
    
    # Create quote
    db_quote = Quote(
        email_id=email_id,
        **quote_data
    )
    
    db.add(db_quote)
    
    # Update email status
    email.status = "quoted"
    
    await db.commit()
    await db.refresh(db_quote)
    
    return db_quote


@router.get("/", response_model=List[QuoteResponse])
async def list_quotes(
    skip: int = 0,
    limit: int = 100,
    status: str = None,
    db: AsyncSession = Depends(get_db)
):
    """List all quotes"""
    query = select(Quote)
    
    if status:
        query = query.where(Quote.status == status)
    
    query = query.offset(skip).limit(limit).order_by(Quote.created_at.desc())
    result = await db.execute(query)
    quotes = result.scalars().all()
    
    return quotes


@router.get("/{quote_id}", response_model=QuoteResponse)
async def get_quote(
    quote_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get a specific quote"""
    result = await db.execute(select(Quote).where(Quote.id == quote_id))
    quote = result.scalar_one_or_none()
    
    if not quote:
        raise HTTPException(status_code=404, detail="Quote not found")
    
    return quote


@router.get("/{quote_id}/pdf")
async def download_quote_pdf(
    quote_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Download quote as PDF"""
    result = await db.execute(select(Quote).where(Quote.id == quote_id))
    quote = result.scalar_one_or_none()
    
    if not quote:
        raise HTTPException(status_code=404, detail="Quote not found")
    
    # Prepare quote data for PDF
    quote_data = {
        "quote_number": quote.quote_number,
        "customer_name": quote.customer_name,
        "customer_company": quote.customer_company,
        "customer_email": quote.customer_email,
        "shipping_address": quote.shipping_address,
        "products": quote.products,
        "quantities": quote.quantities,
        "prices": quote.prices,
        "subtotal": quote.subtotal,
        "tax": quote.tax,
        "shipping_cost": quote.shipping_cost,
        "total": quote.total,
        "estimated_delivery": quote.estimated_delivery,
        "delivery_deadline": quote.delivery_deadline,
        "urgency": quote.urgency,
        "notes": quote.notes,
        "terms_and_conditions": quote.terms_and_conditions,
        "valid_until": quote.valid_until,
        "status": quote.status
    }
    
    # Generate PDF
    pdf_buffer = PDFGenerator.generate_quote_pdf(quote_data)
    
    # Return as streaming response
    return StreamingResponse(
        pdf_buffer,
        media_type="application/pdf",
        headers={
            "Content-Disposition": f"attachment; filename=quote_{quote.quote_number}.pdf"
        }
    )


@router.put("/{quote_id}/status")
async def update_quote_status(
    quote_id: int,
    status: str,
    db: AsyncSession = Depends(get_db)
):
    """Update quote status"""
    result = await db.execute(select(Quote).where(Quote.id == quote_id))
    quote = result.scalar_one_or_none()
    
    if not quote:
        raise HTTPException(status_code=404, detail="Quote not found")
    
    valid_statuses = ["draft", "sent", "accepted", "rejected"]
    if status not in valid_statuses:
        raise HTTPException(status_code=400, detail=f"Invalid status. Must be one of: {', '.join(valid_statuses)}")
    
    quote.status = status
    await db.commit()
    
    return {"message": "Quote status updated", "status": status}


@router.delete("/{quote_id}")
async def delete_quote(
    quote_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Delete a quote"""
    result = await db.execute(select(Quote).where(Quote.id == quote_id))
    quote = result.scalar_one_or_none()
    
    if not quote:
        raise HTTPException(status_code=404, detail="Quote not found")
    
    await db.delete(quote)
    await db.commit()
    
    return {"message": "Quote deleted successfully"}
