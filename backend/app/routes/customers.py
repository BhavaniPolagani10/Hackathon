from flask import Blueprint, request, jsonify
from app.extensions import db
from app.models.customer import Customer, CustomerAddress, CustomerContact

customers_bp = Blueprint('customers', __name__, url_prefix='/api/customers')


@customers_bp.route('', methods=['GET'])
def get_customers():
    """Get all customers with optional filters"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    status = request.args.get('status')
    customer_type = request.args.get('type')
    search = request.args.get('q')
    
    query = Customer.query
    
    if status:
        query = query.filter_by(status=status)
    if customer_type:
        query = query.filter_by(customer_type=customer_type)
    if search:
        query = query.filter(Customer.company_name.ilike(f'%{search}%'))
    
    pagination = query.order_by(Customer.company_name).paginate(page=page, per_page=per_page, error_out=False)
    
    return jsonify({
        'customers': [c.to_dict() for c in pagination.items],
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': page
    })


@customers_bp.route('/<customer_id>', methods=['GET'])
def get_customer(customer_id):
    """Get customer by ID with full 360 view"""
    customer = Customer.query.get(customer_id)
    
    if not customer:
        return jsonify({'error': 'Customer not found'}), 404
    
    return jsonify({
        'customer': customer.to_dict(),
        'addresses': [a.to_dict() for a in customer.addresses],
        'contacts': [c.to_dict() for c in customer.contacts]
    })


@customers_bp.route('', methods=['POST'])
def create_customer():
    """Create a new customer"""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    required_fields = ['customer_code', 'company_name']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    # Check if customer code already exists
    existing = Customer.query.filter_by(customer_code=data['customer_code']).first()
    if existing:
        return jsonify({'error': 'Customer code already exists'}), 409
    
    customer = Customer(
        customer_code=data['customer_code'],
        company_name=data['company_name'],
        tax_number=data.get('tax_number'),
        email=data.get('email'),
        phone=data.get('phone'),
        customer_type=data.get('customer_type', 'STANDARD'),
        credit_limit=data.get('credit_limit', 0),
        payment_terms=data.get('payment_terms', 30)
    )
    
    db.session.add(customer)
    db.session.commit()
    
    return jsonify({
        'message': 'Customer created successfully',
        'customer': customer.to_dict()
    }), 201


@customers_bp.route('/<customer_id>', methods=['PUT'])
def update_customer(customer_id):
    """Update customer information"""
    customer = Customer.query.get(customer_id)
    
    if not customer:
        return jsonify({'error': 'Customer not found'}), 404
    
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    # Update allowed fields
    updateable_fields = ['company_name', 'tax_number', 'email', 'phone', 
                         'customer_type', 'status', 'credit_limit', 'payment_terms']
    
    for field in updateable_fields:
        if field in data:
            setattr(customer, field, data[field])
    
    db.session.commit()
    
    return jsonify({
        'message': 'Customer updated successfully',
        'customer': customer.to_dict()
    })


@customers_bp.route('/<customer_id>/addresses', methods=['POST'])
def add_customer_address(customer_id):
    """Add address to customer"""
    customer = Customer.query.get(customer_id)
    
    if not customer:
        return jsonify({'error': 'Customer not found'}), 404
    
    data = request.get_json()
    
    if not data or 'address_type' not in data:
        return jsonify({'error': 'address_type is required'}), 400
    
    address = CustomerAddress(
        customer_id=customer_id,
        address_type=data['address_type'],
        street_address=data.get('street_address'),
        city=data.get('city'),
        state=data.get('state'),
        postal_code=data.get('postal_code'),
        country=data.get('country'),
        is_primary=data.get('is_primary', False)
    )
    
    db.session.add(address)
    db.session.commit()
    
    return jsonify({
        'message': 'Address added successfully',
        'address': address.to_dict()
    }), 201


@customers_bp.route('/<customer_id>/contacts', methods=['POST'])
def add_customer_contact(customer_id):
    """Add contact to customer"""
    customer = Customer.query.get(customer_id)
    
    if not customer:
        return jsonify({'error': 'Customer not found'}), 404
    
    data = request.get_json()
    
    contact = CustomerContact(
        customer_id=customer_id,
        first_name=data.get('first_name'),
        last_name=data.get('last_name'),
        email=data.get('email'),
        phone=data.get('phone'),
        designation=data.get('designation'),
        is_primary=data.get('is_primary', False),
        is_decision_maker=data.get('is_decision_maker', False)
    )
    
    db.session.add(contact)
    db.session.commit()
    
    return jsonify({
        'message': 'Contact added successfully',
        'contact': contact.to_dict()
    }), 201
