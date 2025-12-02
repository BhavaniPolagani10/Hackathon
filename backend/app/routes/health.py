from flask import Blueprint, jsonify

health_bp = Blueprint('health', __name__)


@health_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Dealer Management API',
        'version': '1.0.0'
    })


@health_bp.route('/', methods=['GET'])
def index():
    """API root endpoint"""
    return jsonify({
        'message': 'Welcome to Dealer Management System API',
        'version': '1.0.0',
        'endpoints': {
            'health': '/api/health',
            'auth': '/api/auth/*',
            'customers': '/api/customers/*',
            'products': '/api/products/*',
            'inventory': '/api/inventory/*',
            'quotes': '/api/quotes/*'
        }
    })
