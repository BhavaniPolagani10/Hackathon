from flask import Blueprint, request, jsonify
from app.extensions import db
from app.models.product import Product, ProductOption

products_bp = Blueprint('products', __name__, url_prefix='/api/products')


@products_bp.route('', methods=['GET'])
def get_products():
    """Get all products with optional filters"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    category = request.args.get('category')
    manufacturer = request.args.get('manufacturer')
    status = request.args.get('status')
    search = request.args.get('q')
    
    query = Product.query
    
    if category:
        query = query.filter_by(category=category)
    if manufacturer:
        query = query.filter_by(manufacturer=manufacturer)
    if status:
        query = query.filter_by(status=status)
    if search:
        query = query.filter(Product.product_name.ilike(f'%{search}%'))
    
    pagination = query.order_by(Product.product_name).paginate(page=page, per_page=per_page, error_out=False)
    
    return jsonify({
        'products': [p.to_dict() for p in pagination.items],
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': page
    })


@products_bp.route('/<product_id>', methods=['GET'])
def get_product(product_id):
    """Get product by ID with options"""
    product = Product.query.get(product_id)
    
    if not product:
        return jsonify({'error': 'Product not found'}), 404
    
    return jsonify({
        'product': product.to_dict(),
        'options': [o.to_dict() for o in product.options]
    })


@products_bp.route('', methods=['POST'])
def create_product():
    """Create a new product"""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    required_fields = ['product_code', 'product_name']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    # Check if product code already exists
    existing = Product.query.filter_by(product_code=data['product_code']).first()
    if existing:
        return jsonify({'error': 'Product code already exists'}), 409
    
    product = Product(
        product_code=data['product_code'],
        product_name=data['product_name'],
        category=data.get('category'),
        manufacturer=data.get('manufacturer'),
        base_price=data.get('base_price'),
        description=data.get('description'),
        specifications=data.get('specifications')
    )
    
    db.session.add(product)
    db.session.commit()
    
    return jsonify({
        'message': 'Product created successfully',
        'product': product.to_dict()
    }), 201


@products_bp.route('/<product_id>', methods=['PUT'])
def update_product(product_id):
    """Update product information"""
    product = Product.query.get(product_id)
    
    if not product:
        return jsonify({'error': 'Product not found'}), 404
    
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    # Update allowed fields
    updateable_fields = ['product_name', 'category', 'manufacturer', 
                         'base_price', 'description', 'specifications', 'status']
    
    for field in updateable_fields:
        if field in data:
            setattr(product, field, data[field])
    
    db.session.commit()
    
    return jsonify({
        'message': 'Product updated successfully',
        'product': product.to_dict()
    })


@products_bp.route('/<product_id>/options', methods=['POST'])
def add_product_option(product_id):
    """Add option to product"""
    product = Product.query.get(product_id)
    
    if not product:
        return jsonify({'error': 'Product not found'}), 404
    
    data = request.get_json()
    
    if not data or 'option_type' not in data or 'option_name' not in data:
        return jsonify({'error': 'option_type and option_name are required'}), 400
    
    option = ProductOption(
        product_id=product_id,
        option_type=data['option_type'],
        option_name=data['option_name'],
        option_value=data.get('option_value'),
        additional_price=data.get('additional_price', 0),
        is_default=data.get('is_default', False)
    )
    
    db.session.add(option)
    db.session.commit()
    
    return jsonify({
        'message': 'Option added successfully',
        'option': option.to_dict()
    }), 201


@products_bp.route('/categories', methods=['GET'])
def get_categories():
    """Get unique product categories"""
    categories = db.session.query(Product.category).distinct().filter(Product.category != None).all()
    return jsonify({'categories': [c[0] for c in categories]})


@products_bp.route('/manufacturers', methods=['GET'])
def get_manufacturers():
    """Get unique manufacturers"""
    manufacturers = db.session.query(Product.manufacturer).distinct().filter(Product.manufacturer != None).all()
    return jsonify({'manufacturers': [m[0] for m in manufacturers]})
