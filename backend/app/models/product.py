import uuid
from datetime import datetime
from app.extensions import db


class Product(db.Model):
    """Product model for storing product information"""
    __tablename__ = 'products'
    
    product_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    product_code = db.Column(db.String(50), unique=True, nullable=False, index=True)
    product_name = db.Column(db.String(255), nullable=False)
    category = db.Column(db.String(100))
    manufacturer = db.Column(db.String(100))
    base_price = db.Column(db.Numeric(15, 2))
    description = db.Column(db.Text)
    specifications = db.Column(db.JSON)
    status = db.Column(db.String(20), default='ACTIVE')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    options = db.relationship('ProductOption', backref='product', lazy='dynamic', cascade='all, delete-orphan')
    inventory = db.relationship('Inventory', backref='product', lazy='dynamic')
    
    def __repr__(self):
        return f'<Product {self.product_name}>'
    
    def to_dict(self):
        """Convert product to dictionary"""
        return {
            'product_id': self.product_id,
            'product_code': self.product_code,
            'product_name': self.product_name,
            'category': self.category,
            'manufacturer': self.manufacturer,
            'base_price': float(self.base_price) if self.base_price else 0,
            'description': self.description,
            'specifications': self.specifications,
            'status': self.status,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }


class ProductOption(db.Model):
    """Product option model for machine configurations"""
    __tablename__ = 'product_options'
    
    option_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    product_id = db.Column(db.String(36), db.ForeignKey('products.product_id'), nullable=False)
    option_type = db.Column(db.String(50), nullable=False)
    option_name = db.Column(db.String(100), nullable=False)
    option_value = db.Column(db.String(255))
    additional_price = db.Column(db.Numeric(15, 2), default=0)
    is_default = db.Column(db.Boolean, default=False)
    
    def to_dict(self):
        return {
            'option_id': self.option_id,
            'option_type': self.option_type,
            'option_name': self.option_name,
            'option_value': self.option_value,
            'additional_price': float(self.additional_price) if self.additional_price else 0,
            'is_default': self.is_default
        }
