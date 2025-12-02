import uuid
from datetime import datetime, date
from app.extensions import db


class Vendor(db.Model):
    """Vendor model for storing vendor information"""
    __tablename__ = 'vendors'
    
    vendor_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    vendor_code = db.Column(db.String(50), unique=True, nullable=False, index=True)
    vendor_name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255))
    phone = db.Column(db.String(50))
    address = db.Column(db.Text)
    payment_terms = db.Column(db.Integer, default=30)
    status = db.Column(db.String(20), default='ACTIVE')
    rating = db.Column(db.Numeric(3, 2), default=0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    purchase_orders = db.relationship('PurchaseOrder', backref='vendor', lazy='dynamic')
    
    def __repr__(self):
        return f'<Vendor {self.vendor_name}>'
    
    def to_dict(self):
        return {
            'vendor_id': self.vendor_id,
            'vendor_code': self.vendor_code,
            'vendor_name': self.vendor_name,
            'email': self.email,
            'phone': self.phone,
            'address': self.address,
            'payment_terms': self.payment_terms,
            'status': self.status,
            'rating': float(self.rating) if self.rating else 0,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class PurchaseOrder(db.Model):
    """Purchase order model"""
    __tablename__ = 'purchase_orders'
    
    po_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    po_number = db.Column(db.String(50), unique=True, nullable=False, index=True)
    vendor_id = db.Column(db.String(36), db.ForeignKey('vendors.vendor_id'), nullable=False)
    quote_id = db.Column(db.String(36), db.ForeignKey('quotes.quote_id'))
    customer_id = db.Column(db.String(36), db.ForeignKey('customers.customer_id'))
    po_date = db.Column(db.Date, default=date.today)
    expected_delivery_date = db.Column(db.Date)
    actual_delivery_date = db.Column(db.Date)
    status = db.Column(db.String(50), default='DRAFT')
    total_amount = db.Column(db.Numeric(15, 2))
    currency = db.Column(db.String(3), default='USD')
    shipping_address = db.Column(db.Text)
    notes = db.Column(db.Text)
    created_by = db.Column(db.String(36), db.ForeignKey('users.user_id'))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    line_items = db.relationship('POLineItem', backref='purchase_order', lazy='dynamic', cascade='all, delete-orphan')
    
    def __repr__(self):
        return f'<PurchaseOrder {self.po_number}>'
    
    def to_dict(self):
        return {
            'po_id': self.po_id,
            'po_number': self.po_number,
            'vendor_id': self.vendor_id,
            'quote_id': self.quote_id,
            'customer_id': self.customer_id,
            'po_date': self.po_date.isoformat() if self.po_date else None,
            'expected_delivery_date': self.expected_delivery_date.isoformat() if self.expected_delivery_date else None,
            'actual_delivery_date': self.actual_delivery_date.isoformat() if self.actual_delivery_date else None,
            'status': self.status,
            'total_amount': float(self.total_amount) if self.total_amount else 0,
            'currency': self.currency,
            'shipping_address': self.shipping_address,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class POLineItem(db.Model):
    """Purchase order line item model"""
    __tablename__ = 'po_line_items'
    
    po_line_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    po_id = db.Column(db.String(36), db.ForeignKey('purchase_orders.po_id'), nullable=False)
    product_id = db.Column(db.String(36), db.ForeignKey('products.product_id'))
    product_code = db.Column(db.String(50))
    product_description = db.Column(db.Text)
    quantity = db.Column(db.Integer, default=1)
    unit_price = db.Column(db.Numeric(15, 2))
    line_total = db.Column(db.Numeric(15, 2))
    configuration_data = db.Column(db.JSON)
    
    def to_dict(self):
        return {
            'po_line_id': self.po_line_id,
            'product_id': self.product_id,
            'product_code': self.product_code,
            'product_description': self.product_description,
            'quantity': self.quantity,
            'unit_price': float(self.unit_price) if self.unit_price else 0,
            'line_total': float(self.line_total) if self.line_total else 0,
            'configuration_data': self.configuration_data
        }
