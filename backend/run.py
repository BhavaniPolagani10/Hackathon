#!/usr/bin/env python3
"""
Dealer Management System - Backend API Server
Run this file to start the Flask development server
"""

from app.factory import create_app
from app.extensions import db

app = create_app()

if __name__ == '__main__':
    with app.app_context():
        # Create tables if they don't exist
        db.create_all()
    
    app.run(host='0.0.0.0', port=5000, debug=True)
