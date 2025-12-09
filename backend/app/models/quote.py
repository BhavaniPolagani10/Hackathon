"""Quote model"""
from sqlalchemy import Column, Integer, String, Text, DateTime, JSON, Float, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base


class Quote(Base):
    """Quote model"""
    __tablename__ = "quotes"
    
    id = Column(Integer, primary_key=True, index=True)
    quote_number = Column(String(100), unique=True, nullable=False)
    email_id = Column(Integer, ForeignKey("emails.id"), nullable=False)
    
    # Customer information
    customer_name = Column(String(255), nullable=False)
    customer_company = Column(String(255))
    customer_email = Column(String(255), nullable=False)
    shipping_address = Column(Text)
    
    # Quote details
    products = Column(JSON, nullable=False)  # List of products with details
    quantities = Column(JSON, nullable=False)  # Corresponding quantities
    prices = Column(JSON, nullable=False)  # Individual prices
    subtotal = Column(Float, nullable=False)
    tax = Column(Float, default=0.0)
    shipping_cost = Column(Float, default=0.0)
    total = Column(Float, nullable=False)
    
    # Delivery information
    estimated_delivery = Column(String(255))
    delivery_deadline = Column(String(255))
    urgency = Column(String(50))
    
    # Quote metadata
    notes = Column(Text)
    terms_and_conditions = Column(Text)
    valid_until = Column(DateTime)
    status = Column(String(50), default="draft")  # draft, sent, accepted, rejected
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    email = relationship("Email", back_populates="quotes")
