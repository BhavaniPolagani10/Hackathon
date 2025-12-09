"""Pydantic schemas for API validation"""
from pydantic import BaseModel, EmailStr
from typing import Optional, List, Dict, Any
from datetime import datetime


# Email Schemas
class EmailBase(BaseModel):
    """Base email schema"""
    subject: str
    from_email: EmailStr
    from_name: Optional[str] = None
    to_email: EmailStr
    to_name: Optional[str] = None
    body: str
    date: Optional[datetime] = None


class EmailCreate(EmailBase):
    """Schema for creating email"""
    thread_id: Optional[str] = None


class EmailResponse(EmailBase):
    """Schema for email response"""
    id: int
    customer_name: Optional[str] = None
    customer_company: Optional[str] = None
    customer_email: Optional[str] = None
    products_requested: Optional[List[str]] = None
    quantities: Optional[List[int]] = None
    deadline: Optional[str] = None
    shipping_address: Optional[str] = None
    urgency: Optional[str] = None
    summary: Optional[str] = None
    key_requirements: Optional[Dict[str, Any]] = None
    status: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# Quote Schemas
class QuoteBase(BaseModel):
    """Base quote schema"""
    customer_name: str
    customer_company: Optional[str] = None
    customer_email: EmailStr
    shipping_address: Optional[str] = None
    products: List[Dict[str, Any]]
    quantities: List[int]
    prices: List[float]
    subtotal: float
    tax: float = 0.0
    shipping_cost: float = 0.0
    total: float
    estimated_delivery: Optional[str] = None
    delivery_deadline: Optional[str] = None
    urgency: Optional[str] = None
    notes: Optional[str] = None


class QuoteCreate(QuoteBase):
    """Schema for creating quote"""
    email_id: int


class QuoteResponse(QuoteBase):
    """Schema for quote response"""
    id: int
    quote_number: str
    email_id: int
    terms_and_conditions: Optional[str] = None
    valid_until: Optional[datetime] = None
    status: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# Summary Schema
class EmailSummary(BaseModel):
    """Schema for email summary"""
    summary: str
    products_requested: List[str]
    quantities: List[int]
    customer_name: Optional[str] = None
    customer_company: Optional[str] = None
    customer_email: Optional[str] = None
    urgency: str
    deadline: Optional[str] = None
    shipping_address: Optional[str] = None
    key_requirements: Dict[str, Any]


# Statistics Schema
class DashboardStats(BaseModel):
    """Dashboard statistics"""
    total_emails: int
    analyzed_emails: int
    quotes_generated: int
    pending_emails: int
