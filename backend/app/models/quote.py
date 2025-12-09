"""
Quote generation models
"""
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime, date
from decimal import Decimal


class QuoteLineItem(BaseModel):
    """Individual line item in a quote"""
    line_number: int
    product_code: str
    product_name: str
    description: Optional[str] = None
    quantity: int
    unit_price: Decimal
    discount_percent: Decimal = Decimal("0.00")
    line_total: Decimal
    lead_time_days: Optional[int] = None
    
    class Config:
        from_attributes = True


class QuoteCreate(BaseModel):
    """Request to create a new quote"""
    thread_id: int
    customer_name: str
    customer_email: str
    customer_company: Optional[str] = None
    shipping_address: Optional[str] = None
    line_items: List[dict]
    notes: Optional[str] = None


class Quote(BaseModel):
    """Complete quote details"""
    quote_id: Optional[int] = None
    quote_number: str
    thread_id: Optional[int] = None
    customer_name: str
    customer_email: str
    customer_company: Optional[str] = None
    quote_date: date = Field(default_factory=date.today)
    valid_until: date
    subtotal: Decimal
    discount_amount: Decimal = Decimal("0.00")
    tax_rate: Decimal = Decimal("0.00")
    tax_amount: Decimal = Decimal("0.00")
    shipping_amount: Decimal = Decimal("0.00")
    total_amount: Decimal
    shipping_address: Optional[str] = None
    payment_terms: str = "Net 30"
    delivery_terms: Optional[str] = None
    notes: Optional[str] = None
    status: str = "draft"
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        from_attributes = True


class QuoteWithLineItems(Quote):
    """Quote with full line items"""
    line_items: List[QuoteLineItem] = []


class ProductPricing(BaseModel):
    """Product pricing information from database"""
    product_code: str
    product_name: str
    category: Optional[str] = None
    base_price: Decimal
    discount_percent: Decimal = Decimal("0.00")
    final_price: Decimal
    currency: str = "USD"
    last_purchase_date: Optional[date] = None
    last_purchase_quantity: Optional[int] = None
    lead_time_days: Optional[int] = None
    
    class Config:
        from_attributes = True
