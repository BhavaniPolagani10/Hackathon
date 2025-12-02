import uuid
from datetime import datetime
from app.extensions import db


class Customer(db.Model):
    """Customer model for storing customer information"""
    __tablename__ = 'customers'
    
    customer_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    customer_code = db.Column(db.String(50), unique=True, nullable=False, index=True)
    company_name = db.Column(db.String(255), nullable=False)
    tax_number = db.Column(db.String(50))
    email = db.Column(db.String(255))
    phone = db.Column(db.String(50))
    customer_type = db.Column(db.String(50), default='STANDARD')
    status = db.Column(db.String(20), default='ACTIVE')
    credit_limit = db.Column(db.Numeric(15, 2), default=0)
    payment_terms = db.Column(db.Integer, default=30)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    addresses = db.relationship('CustomerAddress', backref='customer', lazy='dynamic', cascade='all, delete-orphan')
    contacts = db.relationship('CustomerContact', backref='customer', lazy='dynamic', cascade='all, delete-orphan')
    quotes = db.relationship('Quote', backref='customer', lazy='dynamic')
    
    def __repr__(self):
        return f'<Customer {self.company_name}>'
    
    def to_dict(self):
        """Convert customer to dictionary"""
        return {
            'customer_id': self.customer_id,
            'customer_code': self.customer_code,
            'company_name': self.company_name,
            'tax_number': self.tax_number,
            'email': self.email,
            'phone': self.phone,
            'customer_type': self.customer_type,
            'status': self.status,
            'credit_limit': float(self.credit_limit) if self.credit_limit else 0,
            'payment_terms': self.payment_terms,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class CustomerAddress(db.Model):
    """Customer address model"""
    __tablename__ = 'customer_addresses'
    
    address_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    customer_id = db.Column(db.String(36), db.ForeignKey('customers.customer_id'), nullable=False)
    address_type = db.Column(db.String(50), nullable=False)
    street_address = db.Column(db.Text)
    city = db.Column(db.String(100))
    state = db.Column(db.String(100))
    postal_code = db.Column(db.String(20))
    country = db.Column(db.String(100))
    is_primary = db.Column(db.Boolean, default=False)
    
    def to_dict(self):
        return {
            'address_id': self.address_id,
            'address_type': self.address_type,
            'street_address': self.street_address,
            'city': self.city,
            'state': self.state,
            'postal_code': self.postal_code,
            'country': self.country,
            'is_primary': self.is_primary
        }


class CustomerContact(db.Model):
    """Customer contact model"""
    __tablename__ = 'customer_contacts'
    
    contact_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    customer_id = db.Column(db.String(36), db.ForeignKey('customers.customer_id'), nullable=False)
    first_name = db.Column(db.String(100))
    last_name = db.Column(db.String(100))
    email = db.Column(db.String(255))
    phone = db.Column(db.String(50))
    designation = db.Column(db.String(100))
    is_primary = db.Column(db.Boolean, default=False)
    is_decision_maker = db.Column(db.Boolean, default=False)
    
    def to_dict(self):
        return {
            'contact_id': self.contact_id,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'email': self.email,
            'phone': self.phone,
            'designation': self.designation,
            'is_primary': self.is_primary,
            'is_decision_maker': self.is_decision_maker
        }
