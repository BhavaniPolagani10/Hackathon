"""Routes package"""
from .auth import auth_bp
from .customers import customers_bp
from .products import products_bp
from .inventory import inventory_bp
from .quotes import quotes_bp
from .health import health_bp

__all__ = ['auth_bp', 'customers_bp', 'products_bp', 'inventory_bp', 'quotes_bp', 'health_bp']
