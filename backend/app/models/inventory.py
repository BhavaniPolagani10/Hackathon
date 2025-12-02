import uuid
from datetime import datetime
from app.extensions import db


class Warehouse(db.Model):
    """Warehouse model for storing warehouse information"""
    __tablename__ = 'warehouses'
    
    warehouse_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    warehouse_code = db.Column(db.String(50), unique=True, nullable=False, index=True)
    warehouse_name = db.Column(db.String(255), nullable=False)
    address = db.Column(db.Text)
    city = db.Column(db.String(100))
    country = db.Column(db.String(100))
    is_active = db.Column(db.Boolean, default=True)
    
    # Relationships
    inventory = db.relationship('Inventory', backref='warehouse', lazy='dynamic')
    
    def __repr__(self):
        return f'<Warehouse {self.warehouse_name}>'
    
    def to_dict(self):
        return {
            'warehouse_id': self.warehouse_id,
            'warehouse_code': self.warehouse_code,
            'warehouse_name': self.warehouse_name,
            'address': self.address,
            'city': self.city,
            'country': self.country,
            'is_active': self.is_active
        }


class Inventory(db.Model):
    """Inventory model for tracking stock levels"""
    __tablename__ = 'inventory'
    
    inventory_id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    product_id = db.Column(db.String(36), db.ForeignKey('products.product_id'), nullable=False)
    warehouse_id = db.Column(db.String(36), db.ForeignKey('warehouses.warehouse_id'), nullable=False)
    quantity_on_hand = db.Column(db.Integer, default=0)
    quantity_reserved = db.Column(db.Integer, default=0)
    reorder_level = db.Column(db.Integer, default=5)
    last_updated = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Unique constraint for product-warehouse combination
    __table_args__ = (db.UniqueConstraint('product_id', 'warehouse_id', name='uq_product_warehouse'),)
    
    @property
    def quantity_available(self):
        """Calculate available quantity"""
        return self.quantity_on_hand - self.quantity_reserved
    
    def to_dict(self):
        return {
            'inventory_id': self.inventory_id,
            'product_id': self.product_id,
            'warehouse_id': self.warehouse_id,
            'quantity_on_hand': self.quantity_on_hand,
            'quantity_reserved': self.quantity_reserved,
            'quantity_available': self.quantity_available,
            'reorder_level': self.reorder_level,
            'last_updated': self.last_updated.isoformat() if self.last_updated else None
        }
