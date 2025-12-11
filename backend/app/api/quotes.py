"""
Quote generation API endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from typing import List
import os

from app.models import Quote, QuoteWithLineItems, QuoteCreate, ProductPricing
from app.services import email_service, quote_service, pdf_service
from app.utils import get_db

router = APIRouter(prefix="/quotes", tags=["quotes"])


@router.post("/generate", response_model=QuoteWithLineItems)
async def generate_quote(
    thread_id: int,
    db: Session = Depends(get_db)
):
    """
    Generate a quote from an email conversation
    
    Process:
    1. Summarizes the email thread using Azure GPT-4o
    2. Extracts product requirements and quantities
    3. Fetches pricing from PostgreSQL based on previous purchases
    4. Calculates totals with tax and discounts
    5. Generates a standardized quote
    
    Args:
        thread_id: Email thread ID to generate quote from
        
    Returns:
        Complete quote with line items and pricing
    """
    try:
        # Get email thread
        thread_data = email_service.get_thread_by_id(db, thread_id)
        if not thread_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Email thread {thread_id} not found"
            )
        
        # Summarize the email conversation
        summary = email_service.summarize_thread(db, thread_id)
        if not summary:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to summarize email conversation"
            )
        
        # Generate quote from summary
        quote = quote_service.generate_quote_from_summary(
            db=db,
            summary=summary,
            customer_name=thread_data.get("customer_name", "Customer"),
            customer_email=thread_data.get("customer_email", ""),
            customer_company=None
        )
        
        return quote
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate quote: {str(e)}"
        )


@router.post("/preview", response_model=QuoteWithLineItems)
async def preview_quote(
    quote_data: QuoteCreate,
    db: Session = Depends(get_db)
):
    """
    Preview a quote before finalizing
    
    Allows manual adjustment of quote details before generation
    
    Args:
        quote_data: Quote creation data
        
    Returns:
        Preview of the quote with calculated totals
    """
    try:
        # This is a simplified preview - in production you'd validate and calculate
        raise HTTPException(
            status_code=status.HTTP_501_NOT_IMPLEMENTED,
            detail="Preview endpoint not yet implemented"
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to preview quote: {str(e)}"
        )


@router.get("/{quote_number}/pdf")
async def download_quote_pdf(
    quote_number: str,
    thread_id: int,
    db: Session = Depends(get_db)
):
    """
    Download quote as PDF
    
    Generates a professional PDF document of the quote
    
    Args:
        quote_number: Quote number
        thread_id: Associated email thread ID
        
    Returns:
        PDF file for download
    """
    try:
        # Generate the quote first
        thread_data = email_service.get_thread_by_id(db, thread_id)
        if not thread_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Email thread {thread_id} not found"
            )
        
        summary = email_service.summarize_thread(db, thread_id)
        quote = quote_service.generate_quote_from_summary(
            db=db,
            summary=summary,
            customer_name=thread_data.get("customer_name", "Customer"),
            customer_email=thread_data.get("customer_email", ""),
            customer_company=None
        )
        
        # Generate PDF
        pdf_path = pdf_service.generate_quote_pdf(quote)
        
        if not os.path.exists(pdf_path):
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to generate PDF"
            )
        
        return FileResponse(
            path=pdf_path,
            media_type="application/pdf",
            filename=f"quote_{quote_number}.pdf",
            headers={"Content-Disposition": f"attachment; filename=quote_{quote_number}.pdf"}
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate PDF: {str(e)}"
        )


@router.get("/pricing/{product_code}", response_model=ProductPricing)
async def get_product_pricing(
    product_code: str,
    db: Session = Depends(get_db)
):
    """
    Get pricing for a specific product
    
    Retrieves pricing from PostgreSQL based on product code and purchase history
    
    Args:
        product_code: Product code to get pricing for
        
    Returns:
        Product pricing information
    """
    try:
        pricing_list = quote_service.get_product_pricing(db, [product_code])
        if not pricing_list:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Pricing not found for product {product_code}"
            )
        return pricing_list[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch pricing: {str(e)}"
        )
