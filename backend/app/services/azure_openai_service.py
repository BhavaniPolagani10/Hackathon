"""
Azure OpenAI GPT-4o service for email summarization
"""
import logging
from typing import Dict, Any, List
import json
from openai import AzureOpenAI

from app.config import settings

logger = logging.getLogger(__name__)


class AzureOpenAIService:
    """Service for interacting with Azure OpenAI GPT-4o"""
    
    def __init__(self):
        """Initialize Azure OpenAI client"""
        try:
            self.client = AzureOpenAI(
                azure_endpoint=settings.AZURE_OPENAI_ENDPOINT,
                api_key=settings.AZURE_OPENAI_API_KEY,
                api_version=settings.AZURE_OPENAI_API_VERSION
            )
            self.deployment_name = settings.AZURE_OPENAI_DEPLOYMENT_NAME
            logger.info("Azure OpenAI client initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Azure OpenAI client: {e}")
            raise
    
    def summarize_email_conversation(
        self, 
        email_thread: List[Dict[str, Any]]
    ) -> Dict[str, Any]:
        """
        Summarize an email conversation thread and extract structured data
        
        Args:
            email_thread: List of email messages with sender, content, timestamp
            
        Returns:
            Dictionary with summary and extracted information
        """
        try:
            # Build conversation text
            conversation_text = self._format_email_thread(email_thread)
            
            # Create prompt for GPT-4o
            prompt = self._create_summarization_prompt(conversation_text)
            
            # Call Azure OpenAI
            response = self.client.chat.completions.create(
                model=self.deployment_name,
                messages=[
                    {
                        "role": "system",
                        "content": "You are an expert sales assistant analyzing email conversations between customers and sales representatives. Extract key information and provide structured summaries."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.3,
                max_tokens=1500,
                response_format={"type": "json_object"}
            )
            
            # Parse response
            result = json.loads(response.choices[0].message.content)
            logger.info(f"Email summarization completed successfully")
            
            return result
            
        except Exception as e:
            logger.error(f"Error summarizing email conversation: {e}")
            raise
    
    def _format_email_thread(self, email_thread: List[Dict[str, Any]]) -> str:
        """Format email thread for GPT-4o processing"""
        formatted = []
        for idx, email in enumerate(email_thread, 1):
            formatted.append(f"Message {idx}:")
            formatted.append(f"From: {email.get('from_name', 'Unknown')} <{email.get('from_email', '')}>")
            formatted.append(f"To: {', '.join(email.get('to_emails', []))}")
            formatted.append(f"Date: {email.get('sent_at', '')}")
            formatted.append(f"Subject: {email.get('subject', '')}")
            formatted.append(f"\n{email.get('body_text', '')}")
            formatted.append("\n" + "="*80 + "\n")
        
        return "\n".join(formatted)
    
    def _create_summarization_prompt(self, conversation_text: str) -> str:
        """Create prompt for email summarization"""
        return f"""
Analyze the following email conversation between a customer and a sales representative. 
Extract and structure the following information in JSON format:

{{
    "summary": "A concise summary of the entire conversation (2-3 sentences)",
    "requested_products": ["list of specific products or equipment mentioned"],
    "quantities": {{"product_name": quantity}},
    "urgency": "low/normal/high/urgent - assess based on timeline mentioned",
    "shipping_address": "full shipping address if mentioned, otherwise null",
    "delivery_deadline": "specific date or timeframe mentioned, otherwise null",
    "customer_comments": "any special requirements, concerns, or important comments",
    "estimated_budget": numeric value if budget is mentioned (number only, no currency symbol),
    "key_requirements": ["list of specific requirements or specifications"],
    "decision_stage": "inquiry/evaluation/negotiation/ready_to_order",
    "next_steps": "what needs to happen next based on the conversation",
    "confidence_score": 0.0-1.0 indicating confidence in the extracted information
}}

Email Conversation:
{conversation_text}

Provide ONLY valid JSON output without any additional text or explanation.
"""
    
    def generate_quote_description(
        self, 
        summary: Dict[str, Any],
        products_info: List[Dict[str, Any]]
    ) -> str:
        """
        Generate professional quote description based on email summary
        
        Args:
            summary: Email conversation summary
            products_info: List of products with pricing
            
        Returns:
            Professional quote description text
        """
        try:
            prompt = f"""
Based on the following customer requirements and product information, generate a professional 
quote introduction/description (2-3 paragraphs) that:
1. Acknowledges the customer's needs
2. Briefly describes the proposed solution
3. Highlights key benefits and value proposition

Customer Requirements:
{json.dumps(summary, indent=2)}

Proposed Products:
{json.dumps(products_info, indent=2)}

Generate a professional, concise quote description:
"""
            
            response = self.client.chat.completions.create(
                model=self.deployment_name,
                messages=[
                    {
                        "role": "system",
                        "content": "You are a professional sales representative creating quote descriptions for heavy equipment and machinery sales."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ],
                temperature=0.7,
                max_tokens=500
            )
            
            return response.choices[0].message.content.strip()
            
        except Exception as e:
            logger.error(f"Error generating quote description: {e}")
            return "Thank you for your interest. Please find below our quotation for the requested items."


# Global service instance
azure_openai_service = AzureOpenAIService()
