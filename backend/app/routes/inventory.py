from flask import Blueprint, request, jsonify
from app.extensions import db
from app.models.inventory import Warehouse, Inventory
from app.models.product import Product

inventory_bp = Blueprint('inventory', __name__, url_prefix='/api/inventory')


@inventory_bp.route('/availability', methods=['GET'])
def check_availability():
    """Check stock availability for a product"""
    product_id = request.args.get('product_id')
    quantity = request.args.get('quantity', 1, type=int)
    warehouse_id = request.args.get('warehouse_id')
    
    if not product_id:
        return jsonify({'error': 'product_id is required'}), 400
    
    if warehouse_id:
        # Check specific warehouse
        inventory = Inventory.query.filter_by(
            product_id=product_id, 
            warehouse_id=warehouse_id
        ).first()
        
        if not inventory:
            return jsonify({
                'available': False,
                'quantity_available': 0,
                'warehouse_id': warehouse_id
            })
        
        return jsonify({
            'available': inventory.quantity_available >= quantity,
            'quantity_available': inventory.quantity_available,
            'warehouse_id': warehouse_id
        })
    else:
        # Check all warehouses
        inventories = Inventory.query.filter_by(product_id=product_id).all()
        options = []
        
        for inv in inventories:
            if inv.quantity_available >= quantity:
                warehouse = Warehouse.query.get(inv.warehouse_id)
                options.append({
                    'warehouse_id': inv.warehouse_id,
                    'warehouse_name': warehouse.warehouse_name if warehouse else None,
                    'quantity_available': inv.quantity_available
                })
        
        return jsonify({
            'available': len(options) > 0,
            'options': options
        })


@inventory_bp.route('/products/<product_id>', methods=['GET'])
def get_product_inventory(product_id):
    """Get inventory for a product across all warehouses"""
    product = Product.query.get(product_id)
    
    if not product:
        return jsonify({'error': 'Product not found'}), 404
    
    inventories = Inventory.query.filter_by(product_id=product_id).all()
    
    warehouse_data = []
    for inv in inventories:
        warehouse = Warehouse.query.get(inv.warehouse_id)
        warehouse_data.append({
            **inv.to_dict(),
            'warehouse': warehouse.to_dict() if warehouse else None
        })
    
    return jsonify({
        'product': product.to_dict(),
        'warehouses': warehouse_data
    })


@inventory_bp.route('/warehouses', methods=['GET'])
def get_warehouses():
    """Get all warehouses"""
    warehouses = Warehouse.query.filter_by(is_active=True).all()
    return jsonify({
        'warehouses': [w.to_dict() for w in warehouses]
    })


@inventory_bp.route('/warehouses/<warehouse_id>', methods=['GET'])
def get_warehouse(warehouse_id):
    """Get warehouse details with inventory"""
    warehouse = Warehouse.query.get(warehouse_id)
    
    if not warehouse:
        return jsonify({'error': 'Warehouse not found'}), 404
    
    inventories = Inventory.query.filter_by(warehouse_id=warehouse_id).all()
    
    inventory_data = []
    for inv in inventories:
        product = Product.query.get(inv.product_id)
        inventory_data.append({
            **inv.to_dict(),
            'product': product.to_dict() if product else None
        })
    
    return jsonify({
        'warehouse': warehouse.to_dict(),
        'inventory': inventory_data
    })


@inventory_bp.route('/warehouses', methods=['POST'])
def create_warehouse():
    """Create a new warehouse"""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    required_fields = ['warehouse_code', 'warehouse_name']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    # Check if warehouse code already exists
    existing = Warehouse.query.filter_by(warehouse_code=data['warehouse_code']).first()
    if existing:
        return jsonify({'error': 'Warehouse code already exists'}), 409
    
    warehouse = Warehouse(
        warehouse_code=data['warehouse_code'],
        warehouse_name=data['warehouse_name'],
        address=data.get('address'),
        city=data.get('city'),
        country=data.get('country')
    )
    
    db.session.add(warehouse)
    db.session.commit()
    
    return jsonify({
        'message': 'Warehouse created successfully',
        'warehouse': warehouse.to_dict()
    }), 201


@inventory_bp.route('/stock', methods=['POST'])
def update_stock():
    """Update inventory stock levels"""
    data = request.get_json()
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    product_id = data.get('product_id')
    warehouse_id = data.get('warehouse_id')
    
    if not product_id or not warehouse_id:
        return jsonify({'error': 'product_id and warehouse_id are required'}), 400
    
    # Get or create inventory record
    inventory = Inventory.query.filter_by(
        product_id=product_id,
        warehouse_id=warehouse_id
    ).first()
    
    if not inventory:
        inventory = Inventory(
            product_id=product_id,
            warehouse_id=warehouse_id
        )
        db.session.add(inventory)
    
    # Update stock
    if 'quantity_on_hand' in data:
        inventory.quantity_on_hand = data['quantity_on_hand']
    if 'quantity_reserved' in data:
        inventory.quantity_reserved = data['quantity_reserved']
    if 'reorder_level' in data:
        inventory.reorder_level = data['reorder_level']
    
    db.session.commit()
    
    return jsonify({
        'message': 'Stock updated successfully',
        'inventory': inventory.to_dict()
    })


@inventory_bp.route('/low-stock', methods=['GET'])
def get_low_stock():
    """Get products below reorder level"""
    inventories = Inventory.query.filter(
        Inventory.quantity_on_hand - Inventory.quantity_reserved <= Inventory.reorder_level
    ).all()
    
    results = []
    for inv in inventories:
        product = Product.query.get(inv.product_id)
        warehouse = Warehouse.query.get(inv.warehouse_id)
        results.append({
            **inv.to_dict(),
            'product': product.to_dict() if product else None,
            'warehouse': warehouse.to_dict() if warehouse else None
        })
    
    return jsonify({'low_stock_items': results})
