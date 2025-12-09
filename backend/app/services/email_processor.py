"""Email processing and analysis service"""
import re
from typing import Dict, List, Tuple, Optional
from datetime import datetime


class EmailProcessor:
    """Process and analyze email conversations"""
    
    @staticmethod
    def extract_customer_info(email_body: str, from_name: str, from_email: str) -> Dict[str, str]:
        """Extract customer information from email"""
        customer_info = {
            "customer_name": from_name or "",
            "customer_email": from_email,
            "customer_company": ""
        }
        
        # Try to extract company name from email signature or body
        company_patterns = [
            r'(?:from|at|@)\s+([A-Z][A-Za-z\s&]+(?:Inc|LLC|Ltd|Corp|Corporation|Company))',
            r'\n([A-Z][A-Za-z\s&]+(?:Inc|LLC|Ltd|Corp|Corporation|Company))\n',
        ]
        
        for pattern in company_patterns:
            match = re.search(pattern, email_body)
            if match:
                customer_info["customer_company"] = match.group(1).strip()
                break
        
        return customer_info
    
    @staticmethod
    def extract_products(email_body: str) -> List[str]:
        """Extract requested products from email"""
        products = []
        
        # Common product-related keywords
        product_patterns = [
            r'(?:CAT|Caterpillar|Komatsu|Volvo|John Deere|Bobcat|Kubota)\s+(?:[A-Z0-9-]+)',
            r'(?:excavator|bulldozer|loader|grader|crane|truck|dump truck|hauler|backhoe)s?',
        ]
        
        for pattern in product_patterns:
            matches = re.finditer(pattern, email_body, re.IGNORECASE)
            for match in matches:
                product = match.group(0).strip()
                if product and product not in products:
                    products.append(product)
        
        return products if products else ["Equipment (details in email)"]
    
    @staticmethod
    def extract_quantities(email_body: str) -> List[int]:
        """Extract quantities from email"""
        quantities = []
        
        # Look for quantity patterns
        quantity_patterns = [
            r'(\d+)\s+(?:units?|pieces?|items?)',
            r'quantity[:\s]+(\d+)',
            r'(?:need|require|want)\s+(\d+)',
        ]
        
        for pattern in quantity_patterns:
            matches = re.finditer(pattern, email_body, re.IGNORECASE)
            for match in matches:
                qty = int(match.group(1))
                if qty > 0 and qty not in quantities:
                    quantities.append(qty)
        
        return quantities if quantities else [1]
    
    @staticmethod
    def extract_deadline(email_body: str) -> Optional[str]:
        """Extract deadline from email"""
        # Look for date patterns and urgency indicators
        deadline_patterns = [
            r'(?:by|before|deadline|due)\s+([A-Z][a-z]+\s+\d{1,2},?\s+\d{4})',
            r'(?:by|before|deadline|due)\s+(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})',
            r'within\s+(\d+)\s+(days?|weeks?|months?)',
            r'(?:need|require).*(?:by|before)\s+([A-Z][a-z]+\s+\d{1,2})',
        ]
        
        for pattern in deadline_patterns:
            match = re.search(pattern, email_body, re.IGNORECASE)
            if match:
                return match.group(1).strip()
        
        return None
    
    @staticmethod
    def extract_shipping_address(email_body: str) -> Optional[str]:
        """Extract shipping address from email"""
        # Look for address patterns
        address_patterns = [
            r'(?:ship to|shipping address|deliver to|delivery address)[:\s]+([^\n]+(?:\n[^\n]+){0,3})',
            r'(?:address)[:\s]+([^\n]+(?:\n[^\n]+){0,2})',
        ]
        
        for pattern in address_patterns:
            match = re.search(pattern, email_body, re.IGNORECASE)
            if match:
                address = match.group(1).strip()
                # Clean up the address
                address = re.sub(r'\s+', ' ', address)
                return address[:500]  # Limit length
        
        return None
    
    @staticmethod
    def determine_urgency(email_body: str, subject: str) -> str:
        """Determine urgency level from email content"""
        combined_text = f"{subject} {email_body}".lower()
        
        if any(word in combined_text for word in ['urgent', 'asap', 'immediately', 'emergency', 'rush']):
            return "urgent"
        elif any(word in combined_text for word in ['soon', 'quickly', 'expedite', 'fast']):
            return "high"
        elif any(word in combined_text for word in ['when possible', 'no rush', 'flexible']):
            return "low"
        else:
            return "medium"
    
    @staticmethod
    def generate_summary(email_body: str, subject: str, products: List[str], 
                        quantities: List[int], urgency: str, deadline: Optional[str]) -> str:
        """Generate a concise summary of the email"""
        summary_parts = []
        
        # Product and quantity information
        if products and quantities:
            if len(products) == len(quantities):
                items = [f"{qty}x {prod}" for prod, qty in zip(products, quantities)]
                summary_parts.append(f"Customer requesting: {', '.join(items)}")
            else:
                summary_parts.append(f"Customer requesting: {', '.join(products)}")
        
        # Urgency
        summary_parts.append(f"Urgency: {urgency.capitalize()}")
        
        # Deadline
        if deadline:
            summary_parts.append(f"Deadline: {deadline}")
        
        # Extract key phrases from body
        sentences = email_body.split('.')
        if sentences:
            # Get first meaningful sentence
            for sentence in sentences[:3]:
                sentence = sentence.strip()
                if len(sentence) > 20 and not sentence.lower().startswith(('hi', 'hello', 'dear', 'thank')):
                    summary_parts.append(f"Note: {sentence}.")
                    break
        
        return " | ".join(summary_parts)
    
    @staticmethod
    def extract_key_requirements(email_body: str, products: List[str], 
                                 quantities: List[int], deadline: Optional[str]) -> Dict:
        """Extract structured key requirements"""
        requirements = {
            "products": products,
            "quantities": quantities,
            "deadline": deadline,
            "special_requests": []
        }
        
        # Look for special requests or requirements
        special_patterns = [
            r'(?:require|need|must have|important)[:\s]+([^\n.]+)',
            r'(?:specification|specs?|configuration)[:\s]+([^\n.]+)',
        ]
        
        for pattern in special_patterns:
            matches = re.finditer(pattern, email_body, re.IGNORECASE)
            for match in matches:
                requirement = match.group(1).strip()
                if len(requirement) > 10:
                    requirements["special_requests"].append(requirement)
        
        return requirements
    
    @classmethod
    def analyze_email(cls, subject: str, body: str, from_name: str, from_email: str) -> Dict:
        """Perform complete email analysis"""
        customer_info = cls.extract_customer_info(body, from_name, from_email)
        products = cls.extract_products(body)
        quantities = cls.extract_quantities(body)
        deadline = cls.extract_deadline(body)
        shipping_address = cls.extract_shipping_address(body)
        urgency = cls.determine_urgency(body, subject)
        summary = cls.generate_summary(body, subject, products, quantities, urgency, deadline)
        key_requirements = cls.extract_key_requirements(body, products, quantities, deadline)
        
        return {
            **customer_info,
            "products_requested": products,
            "quantities": quantities,
            "deadline": deadline,
            "shipping_address": shipping_address,
            "urgency": urgency,
            "summary": summary,
            "key_requirements": key_requirements
        }
