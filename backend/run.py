#!/usr/bin/env python3
"""
Dealer Management System - Backend API Server
Run this file to start the Flask development server
"""

import os
from app.factory import create_app
from app.extensions import db

app = create_app()

if __name__ == '__main__':
    with app.app_context():
        # Create tables if they don't exist
        db.create_all()
    
    # Only enable debug mode in development, controlled by environment variable
    debug_mode = os.environ.get('FLASK_ENV', 'production') == 'development'
    app.run(host='0.0.0.0', port=5000, debug=debug_mode)
