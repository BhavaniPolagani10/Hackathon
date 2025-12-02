import os
from flask import Flask
from flask_cors import CORS

from config import config
from app.extensions import db, migrate


def create_app(config_name=None):
    """Application factory for creating Flask app"""
    if config_name is None:
        config_name = os.environ.get('FLASK_ENV', 'development')
    
    app = Flask(__name__)
    app.config.from_object(config[config_name])
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    
    # Enable CORS
    CORS(app, origins=['http://localhost:5173', 'http://127.0.0.1:5173'])
    
    # Import models to ensure they are registered with SQLAlchemy
    with app.app_context():
        from app.models import (
            User, Customer, CustomerAddress, CustomerContact,
            Product, ProductOption, Warehouse, Inventory,
            Quote, QuoteLineItem, MachineConfiguration,
            Vendor, PurchaseOrder, POLineItem
        )
    
    # Register blueprints
    from app.routes import (
        health_bp, auth_bp, customers_bp, 
        products_bp, inventory_bp, quotes_bp
    )
    
    app.register_blueprint(health_bp, url_prefix='/api')
    app.register_blueprint(auth_bp)
    app.register_blueprint(customers_bp)
    app.register_blueprint(products_bp)
    app.register_blueprint(inventory_bp)
    app.register_blueprint(quotes_bp)
    
    return app
