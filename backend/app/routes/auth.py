from flask import Blueprint, request, jsonify
from datetime import datetime
from app.extensions import db
from app.models.user import User

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')


@auth_bp.route('/register', methods=['POST'])
def register():
    """
    Register a new user after Firebase authentication
    Expects: firebase_uid, email from the request body
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    firebase_uid = data.get('firebase_uid')
    email = data.get('email')
    first_name = data.get('first_name', '')
    last_name = data.get('last_name', '')
    role = data.get('role', 'SALES_REP')
    
    if not firebase_uid or not email:
        return jsonify({'error': 'firebase_uid and email are required'}), 400
    
    # Check if user already exists
    existing_user = User.query.filter_by(firebase_uid=firebase_uid).first()
    if existing_user:
        return jsonify({'error': 'User already exists'}), 409
    
    # Create new user
    user = User(
        firebase_uid=firebase_uid,
        email=email,
        first_name=first_name,
        last_name=last_name,
        role=role,
        status='ACTIVE'
    )
    
    db.session.add(user)
    db.session.commit()
    
    return jsonify({
        'message': 'User registered successfully',
        'user': user.to_dict()
    }), 201


@auth_bp.route('/login', methods=['POST'])
def login():
    """
    Record user login and return user profile
    Expects: firebase_uid from the request body
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    firebase_uid = data.get('firebase_uid')
    
    if not firebase_uid:
        return jsonify({'error': 'firebase_uid is required'}), 400
    
    # Find user
    user = User.query.filter_by(firebase_uid=firebase_uid).first()
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    # Update last login
    user.last_login = datetime.utcnow()
    db.session.commit()
    
    return jsonify({
        'message': 'Login successful',
        'user': user.to_dict()
    })


@auth_bp.route('/profile', methods=['GET'])
def get_profile():
    """
    Get user profile by Firebase UID
    """
    firebase_uid = request.args.get('firebase_uid')
    
    if not firebase_uid:
        return jsonify({'error': 'firebase_uid is required'}), 400
    
    user = User.query.filter_by(firebase_uid=firebase_uid).first()
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    return jsonify({'user': user.to_dict()})


@auth_bp.route('/profile', methods=['PUT'])
def update_profile():
    """
    Update user profile
    """
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    firebase_uid = data.get('firebase_uid')
    
    if not firebase_uid:
        return jsonify({'error': 'firebase_uid is required'}), 400
    
    user = User.query.filter_by(firebase_uid=firebase_uid).first()
    
    if not user:
        return jsonify({'error': 'User not found'}), 404
    
    # Update allowed fields
    if 'first_name' in data:
        user.first_name = data['first_name']
    if 'last_name' in data:
        user.last_name = data['last_name']
    
    db.session.commit()
    
    return jsonify({
        'message': 'Profile updated successfully',
        'user': user.to_dict()
    })
