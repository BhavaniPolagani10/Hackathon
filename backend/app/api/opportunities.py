"""
Opportunity API endpoints
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from typing import List, Optional

from app.utils import get_db

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/opportunities", tags=["opportunities"])


@router.get("/{opportunity_number}")
async def get_opportunity_details(
    opportunity_number: str,
    db: Session = Depends(get_db)
):
    """
    Get detailed opportunity information including quote details
    
    This endpoint fetches opportunity details from the CRM database including:
    - Basic opportunity information
    - Quote line items (products/services)
    - Pricing and totals
    
    Args:
        opportunity_number: Opportunity number (e.g., 'OP-2024-001')
        
    Returns:
        Complete opportunity details with line items
    """
    try:
        # Query opportunity from CRM database
        query = """
        SELECT 
            o.opportunity_id,
            o.opportunity_number,
            o.opportunity_name,
            o.amount,
            c.customer_name,
            os.stage_name,
            o.probability_percent,
            o.expected_close_date,
            o.actual_close_date,
            o.is_won,
            o.is_closed,
            o.description
        FROM crm.crm_opportunity o
        LEFT JOIN crm.crm_customer c ON o.customer_id = c.customer_id
        LEFT JOIN crm.crm_opportunity_stage os ON o.stage_id = os.stage_id
        WHERE o.opportunity_number = :opportunity_number
        LIMIT 1
        """
        
        result = db.execute(text(query), {"opportunity_number": opportunity_number})
        opportunity = result.fetchone()
        
        if not opportunity:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Opportunity {opportunity_number} not found"
            )
        
        # Get associated quote and line items
        quote_query = """
        SELECT 
            q.quote_id,
            q.quote_number,
            q.quote_date,
            q.valid_until,
            q.subtotal,
            q.discount_amount,
            q.tax_rate,
            q.tax_amount,
            q.total_amount,
            q.payment_terms,
            q.notes
        FROM crm.crm_quotation q
        WHERE q.opportunity_id = :opportunity_id
        ORDER BY q.created_at DESC
        LIMIT 1
        """
        
        quote_result = db.execute(
            text(quote_query), 
            {"opportunity_id": opportunity.opportunity_id}
        )
        quote = quote_result.fetchone()
        
        items = []
        if quote:
            # Get quote line items
            items_query = """
            SELECT 
                line_item_id,
                line_number,
                product_code,
                product_name,
                description,
                quantity,
                unit_price,
                discount_percent,
                line_total,
                lead_time_days
            FROM crm.crm_quote_line_item
            WHERE quote_id = :quote_id
            ORDER BY line_number
            """
            
            items_result = db.execute(text(items_query), {"quote_id": quote.quote_id})
            items = [
                {
                    "id": str(item.line_item_id),
                    "name": item.product_name,
                    "description": item.description,
                    "quantity": item.quantity,
                    "unitPrice": float(item.unit_price) if item.unit_price else 0.0,
                    "total": float(item.line_total) if item.line_total else 0.0,
                    "productCode": item.product_code,
                    "discountPercent": float(item.discount_percent) if item.discount_percent else 0.0,
                    "leadTimeDays": item.lead_time_days
                }
                for item in items_result.fetchall()
            ]
        
        # Build response
        response = {
            "id": str(opportunity.opportunity_id),
            "opportunityId": opportunity.opportunity_number,
            "name": opportunity.opportunity_name,
            "customerName": opportunity.customer_name,
            "stage": opportunity.stage_name,
            "amount": float(opportunity.amount) if opportunity.amount else 0.0,
            "probability": opportunity.probability_percent,
            "expectedCloseDate": opportunity.expected_close_date.isoformat() if opportunity.expected_close_date else None,
            "actualCloseDate": opportunity.actual_close_date.isoformat() if opportunity.actual_close_date else None,
            "isWon": opportunity.is_won,
            "isClosed": opportunity.is_closed,
            "description": opportunity.description,
            "items": items,
            "subtotal": float(quote.subtotal) if quote and quote.subtotal else 0.0,
            "taxRate": float(quote.tax_rate) if quote and quote.tax_rate else 0.0,
            "taxAmount": float(quote.tax_amount) if quote and quote.tax_amount else 0.0,
            "grandTotal": float(quote.total_amount) if quote and quote.total_amount else float(opportunity.amount) if opportunity.amount else 0.0,
            "quoteNumber": quote.quote_number if quote else None,
            "paymentTerms": quote.payment_terms if quote else None,
            "notes": quote.notes if quote else None
        }
        
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to fetch opportunity details: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch opportunity details: {str(e)}"
        )


@router.get("/")
async def list_opportunities(
    db: Session = Depends(get_db),
    customer_id: Optional[int] = None,
    stage: Optional[str] = None,
    is_closed: Optional[bool] = None,
    limit: int = 100
):
    """
    List opportunities with optional filtering
    
    Args:
        customer_id: Filter by customer ID
        stage: Filter by stage name
        is_closed: Filter by closed status
        limit: Maximum number of results (default 100)
        
    Returns:
        List of opportunities
    """
    try:
        # Build query with filters
        query = """
        SELECT 
            o.opportunity_id,
            o.opportunity_number,
            o.opportunity_name,
            o.amount,
            c.customer_name,
            os.stage_name,
            o.probability_percent,
            o.expected_close_date,
            o.is_won,
            o.is_closed
        FROM crm.crm_opportunity o
        LEFT JOIN crm.crm_customer c ON o.customer_id = c.customer_id
        LEFT JOIN crm.crm_opportunity_stage os ON o.stage_id = os.stage_id
        WHERE 1=1
        """
        
        params = {}
        
        if customer_id is not None:
            query += " AND o.customer_id = :customer_id"
            params["customer_id"] = customer_id
            
        if stage is not None:
            query += " AND os.stage_name = :stage"
            params["stage"] = stage
            
        if is_closed is not None:
            query += " AND o.is_closed = :is_closed"
            params["is_closed"] = is_closed
        
        query += " ORDER BY o.created_at DESC LIMIT :limit"
        params["limit"] = limit
        
        result = db.execute(text(query), params)
        opportunities = result.fetchall()
        
        return [
            {
                "id": str(opp.opportunity_id),
                "opportunityId": opp.opportunity_number,
                "name": opp.opportunity_name,
                "customerName": opp.customer_name,
                "stage": opp.stage_name,
                "amount": float(opp.amount) if opp.amount else 0.0,
                "probability": opp.probability_percent,
                "expectedCloseDate": opp.expected_close_date.isoformat() if opp.expected_close_date else None,
                "isWon": opp.is_won,
                "isClosed": opp.is_closed
            }
            for opp in opportunities
        ]
        
    except Exception as e:
        logger.error(f"Failed to list opportunities: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list opportunities: {str(e)}"
        )
