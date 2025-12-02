import uuid
from datetime import datetime, date
from app.extensions import db


class Quote(db.Model):
    """Quote model for storing quote information"""
    __tablename__ = 'quotes'
    
    quote_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    quote_number = db.Column(db.String(50), unique=True, nullable=False, index=True)
    customer_id = db.Column(db.String(36), db.ForeignKey('customers.customer_id'), nullable=False)
    sales_rep_id = db.Column(db.String(36), db.ForeignKey('users.user_id'), nullable=False)
    quote_date = db.Column(db.Date, default=date.today)
    valid_until = db.Column(db.Date)
    status = db.Column(db.String(50), default='DRAFT')
    subtotal = db.Column(db.Numeric(15, 2))
    discount_amount = db.Column(db.Numeric(15, 2), default=0)
    discount_percent = db.Column(db.Numeric(5, 2), default=0)
    tax_amount = db.Column(db.Numeric(15, 2), default=0)
    total_amount = db.Column(db.Numeric(15, 2))
    currency = db.Column(db.String(3), default='USD')
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    line_items = db.relationship('QuoteLineItem', backref='quote', lazy='dynamic', cascade='all, delete-orphan')
    
    def __repr__(self):
        return f'<Quote {self.quote_number}>'
    
    def to_dict(self):
        return {
            'quote_id': self.quote_id,
            'quote_number': self.quote_number,
            'customer_id': self.customer_id,
            'sales_rep_id': self.sales_rep_id,
            'quote_date': self.quote_date.isoformat() if self.quote_date else None,
            'valid_until': self.valid_until.isoformat() if self.valid_until else None,
            'status': self.status,
            'subtotal': float(self.subtotal) if self.subtotal else 0,
            'discount_amount': float(self.discount_amount) if self.discount_amount else 0,
            'discount_percent': float(self.discount_percent) if self.discount_percent else 0,
            'tax_amount': float(self.tax_amount) if self.tax_amount else 0,
            'total_amount': float(self.total_amount) if self.total_amount else 0,
            'currency': self.currency,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class QuoteLineItem(db.Model):
    """Quote line item model"""
    __tablename__ = 'quote_line_items'
    
    line_item_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    quote_id = db.Column(db.String(36), db.ForeignKey('quotes.quote_id'), nullable=False)
    product_id = db.Column(db.String(36), db.ForeignKey('products.product_id'))
    product_code = db.Column(db.String(50))
    product_name = db.Column(db.String(255))
    quantity = db.Column(db.Integer, default=1)
    unit_price = db.Column(db.Numeric(15, 2))
    discount_percent = db.Column(db.Numeric(5, 2), default=0)
    line_total = db.Column(db.Numeric(15, 2))
    configuration_id = db.Column(db.String(36))
    
    # Relationship to configuration
    configuration = db.relationship('MachineConfiguration', backref='line_item', uselist=False, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'line_item_id': self.line_item_id,
            'product_id': self.product_id,
            'product_code': self.product_code,
            'product_name': self.product_name,
            'quantity': self.quantity,
            'unit_price': float(self.unit_price) if self.unit_price else 0,
            'discount_percent': float(self.discount_percent) if self.discount_percent else 0,
            'line_total': float(self.line_total) if self.line_total else 0,
            'configuration': self.configuration.to_dict() if self.configuration else None
        }


class MachineConfiguration(db.Model):
    """Machine configuration model for quote line items"""
    __tablename__ = 'machine_configurations'
    
    config_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    line_item_id = db.Column(db.String(36), db.ForeignKey('quote_line_items.line_item_id'), nullable=False)
    base_model = db.Column(db.String(100))
    bucket_size = db.Column(db.String(50))
    tire_type = db.Column(db.String(50))
    attachment_1 = db.Column(db.String(100))
    attachment_2 = db.Column(db.String(100))
    warranty_package = db.Column(db.String(50))
    special_instructions = db.Column(db.Text)
    configuration_data = db.Column(db.JSON)
    
    def to_dict(self):
        return {
            'config_id': self.config_id,
            'base_model': self.base_model,
            'bucket_size': self.bucket_size,
            'tire_type': self.tire_type,
            'attachment_1': self.attachment_1,
            'attachment_2': self.attachment_2,
            'warranty_package': self.warranty_package,
            'special_instructions': self.special_instructions,
            'configuration_data': self.configuration_data
        }
