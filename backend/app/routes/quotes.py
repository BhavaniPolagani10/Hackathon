from flask import Blueprint, request, jsonify
from datetime import date, timedelta
from app.extensions import db
from app.models.quote import Quote, QuoteLineItem, MachineConfiguration
from app.models.customer import Customer
from app.models.product import Product
import uuid

quotes_bp = Blueprint('quotes', __name__, url_prefix='/api/quotes')


def generate_quote_number():
    """Generate unique quote number"""
    today = date.today()
    prefix = f"QT-{today.strftime('%Y%m%d')}"
    count = Quote.query.filter(Quote.quote_number.like(f'{prefix}%')).count()
    return f"{prefix}-{count + 1:04d}"


@quotes_bp.route('', methods=['GET'])
def get_quotes():
    """Get all quotes with optional filters"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    status = request.args.get('status')
    customer_id = request.args.get('customer_id')
    sales_rep_id = request.args.get('sales_rep_id')
    
    query = Quote.query
    
    if status:
        query = query.filter_by(status=status)
    if customer_id:
        query = query.filter_by(customer_id=customer_id)
    if sales_rep_id:
        query = query.filter_by(sales_rep_id=sales_rep_id)
    
    pagination = query.order_by(Quote.created_at.desc()).paginate(page=page, per_page=per_page, error_out=False)
    
    return jsonify({
        'quotes': [q.to_dict() for q in pagination.items],
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': page
    })


@quotes_bp.route('/<quote_id>', methods=['GET'])
def get_quote(quote_id):
    """Get quote by ID with line items"""
    quote = Quote.query.get(quote_id)
    
    if not quote:
        return jsonify({'error': 'Quote not found'}), 404
    
    customer = Customer.query.get(quote.customer_id)
    
    return jsonify({
        'quote': quote.to_dict(),
        'customer': customer.to_dict() if customer else None,
        'line_items': [li.to_dict() for li in quote.line_items]
    })


@quotes_bp.route('', methods=['POST'])
def create_quote():
    """Create a new quote"""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    customer_id = data.get('customer_id')
    sales_rep_id = data.get('sales_rep_id')
    
    if not customer_id or not sales_rep_id:
        return jsonify({'error': 'customer_id and sales_rep_id are required'}), 400
    
    # Verify customer exists
    customer = Customer.query.get(customer_id)
    if not customer:
        return jsonify({'error': 'Customer not found'}), 404
    
    quote = Quote(
        quote_number=generate_quote_number(),
        customer_id=customer_id,
        sales_rep_id=sales_rep_id,
        quote_date=date.today(),
        valid_until=date.today() + timedelta(days=30),
        status='DRAFT',
        currency=data.get('currency', 'USD'),
        notes=data.get('notes')
    )
    
    db.session.add(quote)
    db.session.commit()
    
    return jsonify({
        'message': 'Quote created successfully',
        'quote': quote.to_dict()
    }), 201


@quotes_bp.route('/<quote_id>/line-items', methods=['POST'])
def add_line_item(quote_id):
    """Add line item to quote"""
    quote = Quote.query.get(quote_id)
    
    if not quote:
        return jsonify({'error': 'Quote not found'}), 404
    
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    # Get product if specified
    product = None
    if 'product_id' in data:
        product = Product.query.get(data['product_id'])
    
    line_item = QuoteLineItem(
        quote_id=quote_id,
        product_id=data.get('product_id'),
        product_code=product.product_code if product else data.get('product_code'),
        product_name=product.product_name if product else data.get('product_name'),
        quantity=data.get('quantity', 1),
        unit_price=product.base_price if product else data.get('unit_price', 0),
        discount_percent=data.get('discount_percent', 0)
    )
    
    # Calculate line total
    unit_price = float(line_item.unit_price or 0)
    quantity = line_item.quantity
    discount = float(line_item.discount_percent or 0)
    line_item.line_total = unit_price * quantity * (1 - discount / 100)
    
    db.session.add(line_item)
    
    # Add configuration if provided
    if 'configuration' in data:
        config_data = data['configuration']
        config = MachineConfiguration(
            line_item_id=line_item.line_item_id,
            base_model=config_data.get('base_model'),
            bucket_size=config_data.get('bucket_size'),
            tire_type=config_data.get('tire_type'),
            attachment_1=config_data.get('attachment_1'),
            attachment_2=config_data.get('attachment_2'),
            warranty_package=config_data.get('warranty_package'),
            special_instructions=config_data.get('special_instructions'),
            configuration_data=config_data
        )
        db.session.add(config)
    
    # Recalculate quote totals
    recalculate_quote_totals(quote)
    
    db.session.commit()
    
    return jsonify({
        'message': 'Line item added successfully',
        'line_item': line_item.to_dict()
    }), 201


@quotes_bp.route('/<quote_id>/line-items/<line_item_id>', methods=['DELETE'])
def delete_line_item(quote_id, line_item_id):
    """Delete line item from quote"""
    quote = Quote.query.get(quote_id)
    
    if not quote:
        return jsonify({'error': 'Quote not found'}), 404
    
    line_item = QuoteLineItem.query.get(line_item_id)
    
    if not line_item or line_item.quote_id != quote_id:
        return jsonify({'error': 'Line item not found'}), 404
    
    db.session.delete(line_item)
    
    # Recalculate quote totals
    recalculate_quote_totals(quote)
    
    db.session.commit()
    
    return jsonify({'message': 'Line item deleted successfully'})


@quotes_bp.route('/<quote_id>/status', methods=['PUT'])
def update_quote_status(quote_id):
    """Update quote status"""
    quote = Quote.query.get(quote_id)
    
    if not quote:
        return jsonify({'error': 'Quote not found'}), 404
    
    data = request.get_json()
    
    if not data or 'status' not in data:
        return jsonify({'error': 'status is required'}), 400
    
    valid_statuses = ['DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'SENT', 'ACCEPTED', 'REJECTED', 'EXPIRED']
    
    if data['status'] not in valid_statuses:
        return jsonify({'error': f"Invalid status. Must be one of: {', '.join(valid_statuses)}"}), 400
    
    quote.status = data['status']
    db.session.commit()
    
    return jsonify({
        'message': 'Quote status updated successfully',
        'quote': quote.to_dict()
    })


def recalculate_quote_totals(quote):
    """Recalculate quote totals based on line items"""
    subtotal = 0
    for li in quote.line_items:
        subtotal += float(li.line_total or 0)
    
    quote.subtotal = subtotal
    discount_amount = subtotal * float(quote.discount_percent or 0) / 100
    quote.discount_amount = discount_amount
    taxable = subtotal - discount_amount
    quote.tax_amount = taxable * 0.1  # 10% tax rate
    quote.total_amount = taxable + quote.tax_amount


@quotes_bp.route('/validate-configuration', methods=['POST'])
def validate_configuration():
    """Validate machine configuration"""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    errors = []
    
    # Validate required fields
    if not data.get('base_model'):
        errors.append({'field': 'base_model', 'message': 'Base model is required'})
    
    # Validate attachment combinations
    attachment_1 = data.get('attachment_1')
    attachment_2 = data.get('attachment_2')
    
    if attachment_1 and attachment_2 and attachment_1 == attachment_2:
        errors.append({'field': 'attachments', 'message': 'Cannot select the same attachment twice'})
    
    # Add more validation rules as needed
    
    if errors:
        return jsonify({
            'valid': False,
            'errors': errors
        })
    
    return jsonify({
        'valid': True,
        'message': 'Configuration is valid'
    })
