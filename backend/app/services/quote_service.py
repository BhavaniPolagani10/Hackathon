"""
Quote generation service with pricing from PostgreSQL
"""
import logging
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime, date, timedelta
from decimal import Decimal
import uuid

from app.models import (
    Quote, QuoteWithLineItems, QuoteLineItem, 
    ProductPricing, EmailSummary
)
from app.services.azure_openai_service import azure_openai_service

logger = logging.getLogger(__name__)


class QuoteService:
    """Service for generating and managing quotes"""
    
    def __init__(self):
        """Initialize quote service"""
        self.tax_rate = Decimal("0.08")  # 8% tax rate
        self.standard_validity_days = 30
    
    def get_product_pricing(
        self, 
        db: Session, 
        product_codes: List[str],
        customer_id: Optional[int] = None
    ) -> List[ProductPricing]:
        """
        Get pricing for products from PostgreSQL database
        Uses previous purchase history to determine best pricing
        
        Args:
            db: Database session
            product_codes: List of product codes to price
            customer_id: Optional customer ID for customer-specific pricing
            
        Returns:
            List of ProductPricing objects
        """
        try:
            pricing_list = []
            
            for product_code in product_codes:
                # Query for product pricing from ERP database
                # This queries the erp_product_pricing table and erp_product_price_history
                query = text("""
                    SELECT 
                        p.product_code,
                        p.product_name,
                        pc.category_name as category,
                        COALESCE(
                            (SELECT pp.unit_cost 
                             FROM erp.erp_product_pricing pp 
                             WHERE pp.product_id = p.product_id 
                             AND pp.is_active = true 
                             AND CURRENT_DATE BETWEEN pp.effective_from AND COALESCE(pp.effective_to, '2099-12-31')
                             ORDER BY pp.effective_from DESC 
                             LIMIT 1
                            ),
                            100000.00
                        ) as base_price,
                        p.lead_time_days,
                        (SELECT currency_code 
                         FROM erp.erp_currency 
                         WHERE currency_id = 1
                        ) as currency
                    FROM erp.erp_product p
                    LEFT JOIN erp.erp_product_category pc ON p.category_id = pc.category_id
                    WHERE p.product_code = :product_code
                    AND p.is_active = true
                """)
                
                result = db.execute(query, {"product_code": product_code}).fetchone()
                
                if result:
                    # Calculate discount based on customer history or product type
                    discount_percent = self._calculate_discount(
                        db, 
                        product_code, 
                        customer_id
                    )
                    
                    base_price = Decimal(str(result.base_price))
                    final_price = base_price * (1 - discount_percent / 100)
                    
                    pricing = ProductPricing(
                        product_code=result.product_code,
                        product_name=result.product_name,
                        category=result.category,
                        base_price=base_price,
                        discount_percent=discount_percent,
                        final_price=final_price,
                        currency=result.currency or "USD",
                        lead_time_days=result.lead_time_days or 30
                    )
                    pricing_list.append(pricing)
                else:
                    # Fallback pricing if product not found
                    logger.warning(f"Product {product_code} not found, using fallback pricing")
                    pricing = ProductPricing(
                        product_code=product_code,
                        product_name=f"Product {product_code}",
                        category="Unknown",
                        base_price=Decimal("100000.00"),
                        discount_percent=Decimal("0.00"),
                        final_price=Decimal("100000.00"),
                        currency="USD",
                        lead_time_days=30
                    )
                    pricing_list.append(pricing)
            
            return pricing_list
            
        except Exception as e:
            logger.error(f"Error fetching product pricing: {e}")
            # Return fallback pricing on error
            return [
                ProductPricing(
                    product_code=code,
                    product_name=f"Product {code}",
                    category="Unknown",
                    base_price=Decimal("100000.00"),
                    discount_percent=Decimal("0.00"),
                    final_price=Decimal("100000.00"),
                    currency="USD",
                    lead_time_days=30
                )
                for code in product_codes
            ]
    
    def _calculate_discount(
        self, 
        db: Session, 
        product_code: str,
        customer_id: Optional[int]
    ) -> Decimal:
        """
        Calculate discount percentage based on purchase history
        
        Args:
            db: Database session
            product_code: Product code
            customer_id: Customer ID
            
        Returns:
            Discount percentage as Decimal
        """
        try:
            if customer_id:
                # Check customer's purchase history
                query = text("""
                    SELECT 
                        COUNT(*) as purchase_count,
                        AVG(discount_percent) as avg_discount
                    FROM crm.crm_product_price_history
                    WHERE product_id = (
                        SELECT product_id FROM erp.erp_product 
                        WHERE product_code = :product_code
                    )
                    AND customer_id = :customer_id
                    AND was_accepted = true
                """)
                
                result = db.execute(
                    query, 
                    {"product_code": product_code, "customer_id": customer_id}
                ).fetchone()
                
                if result and result.purchase_count > 0:
                    # Return average discount from history
                    return Decimal(str(result.avg_discount or "0.00"))
            
            # Default discount for new customers or no history
            return Decimal("5.00")  # 5% standard discount
            
        except Exception as e:
            logger.error(f"Error calculating discount: {e}")
            return Decimal("0.00")
    
    def generate_quote_from_summary(
        self,
        db: Session,
        summary: EmailSummary,
        customer_name: str,
        customer_email: str,
        customer_company: Optional[str] = None
    ) -> QuoteWithLineItems:
        """
        Generate a complete quote from email summary
        
        Args:
            db: Database session
            summary: Email summary with extracted information
            customer_name: Customer name
            customer_email: Customer email
            customer_company: Optional company name
            
        Returns:
            Complete quote with line items
        """
        try:
            # Extract product codes from requested products
            # In production, you'd need a mapping service
            product_codes = self._extract_product_codes(summary.requested_products)
            
            # Get pricing for products
            pricing_list = self.get_product_pricing(db, product_codes)
            
            # Create line items
            line_items = []
            subtotal = Decimal("0.00")
            
            for idx, pricing in enumerate(pricing_list, 1):
                # Get quantity from summary
                quantity = self._extract_quantity(summary.quantities, pricing.product_name)
                
                line_total = pricing.final_price * quantity
                subtotal += line_total
                
                line_item = QuoteLineItem(
                    line_number=idx,
                    product_code=pricing.product_code,
                    product_name=pricing.product_name,
                    description=None,
                    quantity=quantity,
                    unit_price=pricing.final_price,
                    discount_percent=pricing.discount_percent,
                    line_total=line_total,
                    lead_time_days=pricing.lead_time_days
                )
                line_items.append(line_item)
            
            # Calculate totals
            tax_amount = subtotal * self.tax_rate
            total_amount = subtotal + tax_amount
            
            # Generate quote number
            quote_number = self._generate_quote_number()
            
            # Generate quote description using AI
            quote_description = azure_openai_service.generate_quote_description(
                summary.dict(),
                [p.dict() for p in pricing_list]
            )
            
            # Create quote
            quote = QuoteWithLineItems(
                quote_number=quote_number,
                thread_id=summary.thread_id,
                customer_name=customer_name,
                customer_email=customer_email,
                customer_company=customer_company,
                quote_date=date.today(),
                valid_until=date.today() + timedelta(days=self.standard_validity_days),
                subtotal=subtotal,
                tax_rate=self.tax_rate * 100,  # Convert to percentage
                tax_amount=tax_amount,
                total_amount=total_amount,
                shipping_address=summary.shipping_address,
                delivery_terms=summary.delivery_deadline or "Standard delivery within lead time",
                notes=quote_description,
                line_items=line_items
            )
            
            logger.info(f"Generated quote {quote_number} for thread {summary.thread_id}")
            return quote
            
        except Exception as e:
            logger.error(f"Error generating quote: {e}")
            raise
    
    def _extract_product_codes(self, product_names: List[str]) -> List[str]:
        """
        Extract or map product codes from product names
        This is a simplified version - production would use a mapping service
        """
        # Mapping based on common equipment names
        product_mapping = {
            "CAT 320": "CAT320-NG",
            "excavator": "CAT320-NG",
            "wheel loader": "KOM-WA380",
            "WA380": "KOM-WA380",
            "komatsu": "KOM-WA380",
            "mini excavator": "KUB-KX040",
            "kubota": "KUB-KX040",
            "KX040": "KUB-KX040",
            "bulldozer": "CAT-D6",
            "D6": "CAT-D6"
        }
        
        product_codes = []
        for product_name in product_names:
            product_lower = product_name.lower()
            for key, code in product_mapping.items():
                if key.lower() in product_lower:
                    if code not in product_codes:
                        product_codes.append(code)
                    break
            else:
                # Default product if no match
                product_codes.append("GENERIC-EQUIP")
        
        return product_codes if product_codes else ["GENERIC-EQUIP"]
    
    def _extract_quantity(self, quantities: Dict, product_name: str) -> int:
        """Extract quantity for a product from the quantities dict"""
        for key, value in quantities.items():
            if key.lower() in product_name.lower() or product_name.lower() in key.lower():
                return int(value)
        return 1  # Default quantity
    
    def _generate_quote_number(self) -> str:
        """Generate unique quote number"""
        timestamp = datetime.now().strftime("%Y%m%d")
        unique_id = str(uuid.uuid4())[:8].upper()
        return f"Q-{timestamp}-{unique_id}"


# Global service instance
quote_service = QuoteService()
