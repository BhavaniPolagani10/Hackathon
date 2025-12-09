"""Quote generation service"""
from typing import Dict, List
from datetime import datetime, timedelta
import random


class QuoteGenerator:
    """Generate quotes with pricing and calculations"""
    
    # Mock pricing database
    PRODUCT_PRICING = {
        "excavator": {"base": 250000, "range": (200000, 400000)},
        "bulldozer": {"base": 320000, "range": (280000, 450000)},
        "loader": {"base": 180000, "range": (150000, 350000)},
        "grader": {"base": 340000, "range": (300000, 400000)},
        "crane": {"base": 450000, "range": (400000, 600000)},
        "truck": {"base": 85000, "range": (70000, 150000)},
        "backhoe": {"base": 95000, "range": (80000, 120000)},
        "hauler": {"base": 480000, "range": (450000, 550000)},
        "default": {"base": 100000, "range": (50000, 200000)}
    }
    
    TAX_RATE = 0.08  # 8% tax
    SHIPPING_BASE = 2500
    SHIPPING_PER_UNIT = 500
    
    @classmethod
    def generate_quote_number(cls) -> str:
        """Generate unique quote number"""
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        random_suffix = random.randint(100, 999)
        return f"Q-{timestamp}-{random_suffix}"
    
    @classmethod
    def calculate_product_price(cls, product_name: str, quantity: int = 1) -> float:
        """Calculate price for a product"""
        product_lower = product_name.lower()
        
        # Find matching product category
        pricing = cls.PRODUCT_PRICING["default"]
        for key, value in cls.PRODUCT_PRICING.items():
            if key in product_lower:
                pricing = value
                break
        
        # Base price with some variation
        base_price = pricing["base"]
        variation = random.uniform(-0.05, 0.05)  # ±5% variation
        unit_price = base_price * (1 + variation)
        
        # Volume discount
        if quantity >= 5:
            unit_price *= 0.90  # 10% discount for 5+
        elif quantity >= 3:
            unit_price *= 0.95  # 5% discount for 3+
        
        return round(unit_price, 2)
    
    @classmethod
    def calculate_shipping(cls, quantity: int) -> float:
        """Calculate shipping cost"""
        return cls.SHIPPING_BASE + (quantity * cls.SHIPPING_PER_UNIT)
    
    @classmethod
    def calculate_delivery_time(cls, urgency: str, quantity: int) -> str:
        """Estimate delivery time"""
        base_days = 30
        
        if urgency == "urgent":
            base_days = 7
        elif urgency == "high":
            base_days = 14
        elif urgency == "medium":
            base_days = 21
        
        # Add time for quantity
        additional_days = (quantity - 1) * 3
        total_days = base_days + additional_days
        
        delivery_date = datetime.now() + timedelta(days=total_days)
        return f"{total_days} days (by {delivery_date.strftime('%B %d, %Y')})"
    
    @classmethod
    def generate_terms_and_conditions(cls) -> str:
        """Generate standard terms and conditions"""
        return """
TERMS AND CONDITIONS:

1. PAYMENT TERMS
   - 30% deposit required upon quote acceptance
   - Balance due upon delivery
   - Payment methods: Wire transfer, Check, Credit Card

2. DELIVERY
   - Delivery time estimates are approximate and subject to change
   - Customer is responsible for site access and preparation
   - Delivery includes basic placement at agreed location

3. WARRANTY
   - Equipment covered by manufacturer's standard warranty
   - Extended warranty options available
   - Service and parts support through authorized dealers

4. CANCELLATION
   - Cancellation within 48 hours: Full refund minus 5% processing fee
   - Cancellation after 48 hours: Deposit non-refundable
   - Custom orders are non-refundable

5. VALIDITY
   - This quote is valid for 30 days from issue date
   - Prices subject to change after expiration
   - Equipment availability subject to prior sale

6. LIABILITY
   - Seller not responsible for delays due to circumstances beyond control
   - Customer responsible for equipment operation and safety
   - Insurance recommended for all equipment

For questions or concerns, please contact our sales team.
        """.strip()
    
    @classmethod
    def create_quote_from_email_data(cls, email_data: Dict, analysis: Dict) -> Dict:
        """Create a complete quote from email and analysis data"""
        products = analysis.get("products_requested", ["Equipment"])
        quantities = analysis.get("quantities", [1])
        
        # Ensure equal length
        if len(quantities) < len(products):
            quantities.extend([1] * (len(products) - len(quantities)))
        elif len(products) < len(quantities):
            quantities = quantities[:len(products)]
        
        # Calculate prices
        prices = []
        product_details = []
        for product, qty in zip(products, quantities):
            unit_price = cls.calculate_product_price(product, qty)
            prices.append(unit_price)
            product_details.append({
                "name": product,
                "quantity": qty,
                "unit_price": unit_price,
                "total_price": unit_price * qty
            })
        
        # Calculate totals
        subtotal = sum(price * qty for price, qty in zip(prices, quantities))
        tax = round(subtotal * cls.TAX_RATE, 2)
        shipping = cls.calculate_shipping(sum(quantities))
        total = round(subtotal + tax + shipping, 2)
        
        # Delivery estimation
        urgency = analysis.get("urgency", "medium")
        estimated_delivery = cls.calculate_delivery_time(urgency, sum(quantities))
        
        # Valid until
        valid_until = datetime.now() + timedelta(days=30)
        
        quote_data = {
            "quote_number": cls.generate_quote_number(),
            "customer_name": analysis.get("customer_name", email_data.get("from_name", "Customer")),
            "customer_company": analysis.get("customer_company", ""),
            "customer_email": analysis.get("customer_email", email_data.get("from_email")),
            "shipping_address": analysis.get("shipping_address", "To be provided"),
            "products": product_details,
            "quantities": quantities,
            "prices": prices,
            "subtotal": subtotal,
            "tax": tax,
            "shipping_cost": shipping,
            "total": total,
            "estimated_delivery": estimated_delivery,
            "delivery_deadline": analysis.get("deadline"),
            "urgency": urgency,
            "notes": f"Quote generated from email conversation. {analysis.get('summary', '')}",
            "terms_and_conditions": cls.generate_terms_and_conditions(),
            "valid_until": valid_until,
            "status": "draft"
        }
        
        return quote_data
