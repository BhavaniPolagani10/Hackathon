"""
Email conversation models
"""
from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional
from datetime import datetime
from enum import Enum


class EmailDirection(str, Enum):
    """Email direction"""
    INBOUND = "inbound"
    OUTBOUND = "outbound"


class EmailStatus(str, Enum):
    """Email thread status"""
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    QUOTE_GENERATED = "quote_generated"
    CLOSED = "closed"


class EmailMessage(BaseModel):
    """Individual email message"""
    message_id: Optional[int] = None
    thread_id: Optional[int] = None
    direction: EmailDirection
    from_email: EmailStr
    from_name: Optional[str] = None
    to_emails: List[EmailStr]
    subject: str
    body_text: str
    sent_at: datetime
    is_read: bool = False
    
    class Config:
        from_attributes = True


class EmailThread(BaseModel):
    """Email conversation thread"""
    thread_id: Optional[int] = None
    subject: str
    customer_name: Optional[str] = None
    customer_email: Optional[EmailStr] = None
    status: EmailStatus = EmailStatus.OPEN
    message_count: int = 0
    first_message_at: Optional[datetime] = None
    last_message_at: Optional[datetime] = None
    summary: Optional[str] = None
    quote_id: Optional[int] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        from_attributes = True


class EmailThreadWithMessages(EmailThread):
    """Email thread with full message list"""
    messages: List[EmailMessage] = []


class EmailSummary(BaseModel):
    """AI-generated email summary"""
    thread_id: int
    summary_text: str
    requested_products: List[str] = []
    quantities: dict = {}
    urgency: str = "normal"  # low, normal, high, urgent
    shipping_address: Optional[str] = None
    delivery_deadline: Optional[str] = None
    customer_comments: Optional[str] = None
    estimated_budget: Optional[float] = None
    confidence_score: Optional[float] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        from_attributes = True
