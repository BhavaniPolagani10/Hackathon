"""Email conversation model"""
from sqlalchemy import Column, Integer, String, Text, DateTime, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class Email(Base):
    """Email conversation model"""
    __tablename__ = "emails"
    
    id = Column(Integer, primary_key=True, index=True)
    subject = Column(String(500), nullable=False)
    from_email = Column(String(255), nullable=False)
    from_name = Column(String(255))
    to_email = Column(String(255), nullable=False)
    to_name = Column(String(255))
    date = Column(DateTime, default=datetime.utcnow)
    body = Column(Text, nullable=False)
    
    # Extracted information
    customer_name = Column(String(255))
    customer_company = Column(String(255))
    customer_email = Column(String(255))
    products_requested = Column(JSON)  # List of products
    quantities = Column(JSON)  # List of quantities
    deadline = Column(String(255))
    shipping_address = Column(Text)
    urgency = Column(String(50))  # low, medium, high, urgent
    
    # Conversation thread
    thread_id = Column(String(255))
    is_initial = Column(Integer, default=1)  # 1 for initial, 0 for replies
    
    # Summary
    summary = Column(Text)
    key_requirements = Column(JSON)
    
    # Status
    status = Column(String(50), default="new")  # new, analyzed, quoted, closed
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    quotes = relationship("Quote", back_populates="email", cascade="all, delete-orphan")
