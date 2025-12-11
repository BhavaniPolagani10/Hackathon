"""
Email conversation management service
"""
import logging
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import text
from datetime import datetime

from app.models import EmailThread, EmailMessage, EmailSummary, EmailStatus
from app.services.azure_openai_service import azure_openai_service

logger = logging.getLogger(__name__)


class EmailService:
    """Service for managing email conversations"""
    
    def __init__(self):
        """Initialize email service"""
        self.mock_emails = []  # Will be loaded from MockData
    
    def load_mock_emails(self) -> List[Dict[str, Any]]:
        """
        Load mock email conversations from the MockData file
        This is a simplified version - in production, you'd parse the actual file
        """
        # Sample mock data based on the MockMailConversations.md
        mock_conversations = [
            {
                "thread_id": 21,
                "subject": "Quotation #Q-2025-1201 - CAT 320 Excavator",
                "customer_name": "Mark Thompson",
                "customer_email": "m.thompson@thompsonexcavating.com",
                "status": "quote_generated",
                "messages": [
                    {
                        "from_name": "Mark Thompson",
                        "from_email": "m.thompson@thompsonexcavating.com",
                        "to_emails": ["lisa.anderson@heavyequipdealer.com"],
                        "subject": "CAT 320 Excavator Inquiry",
                        "body_text": "Hi Lisa, I'm interested in purchasing a CAT 320 Excavator for our excavating business. We need it with a 42-inch bucket, standard tracks, AC cabin, and rear camera. Our budget is around $290,000. Can you provide a quote? We need delivery within 3-4 weeks.",
                        "sent_at": "2025-12-10T09:00:00",
                        "direction": "inbound"
                    },
                    {
                        "from_name": "Lisa Anderson",
                        "from_email": "lisa.anderson@heavyequipdealer.com",
                        "to_emails": ["m.thompson@thompsonexcavating.com"],
                        "subject": "RE: CAT 320 Excavator Inquiry",
                        "body_text": "Dear Mr. Thompson, Thank you for your interest. I can offer the CAT 320 with your specified configuration at $295,000. Payment terms: 30% deposit, balance on delivery. Delivery: 3-4 weeks. Please let me know if you have any questions.",
                        "sent_at": "2025-12-10T11:00:00",
                        "direction": "outbound"
                    }
                ]
            },
            {
                "thread_id": 22,
                "subject": "Wheel Loader Fleet Purchase",
                "customer_name": "Susan Baker",
                "customer_email": "s.baker@bakerquarry.com",
                "status": "open",
                "messages": [
                    {
                        "from_name": "Susan Baker",
                        "from_email": "s.baker@bakerquarry.com",
                        "to_emails": ["mike.thompson@heavyequipdealer.com"],
                        "subject": "Fleet Purchase - 3 Wheel Loaders",
                        "body_text": "Mike, We're looking to purchase 3 Komatsu WA380-8 Wheel Loaders for our quarry operations. We need extended warranty (5 years) on all units. Delivery should be staggered over 6-8 weeks. What's your best fleet pricing? Our shipping address is Baker Quarry Operations, 5678 Quarry Road, Denver, CO 80201.",
                        "sent_at": "2025-12-11T10:00:00",
                        "direction": "inbound"
                    }
                ]
            },
            {
                "thread_id": 23,
                "subject": "URGENT - Mini Excavator Needed",
                "customer_name": "Tony Russo",
                "customer_email": "t.russo@russolandscaping.com",
                "status": "open",
                "messages": [
                    {
                        "from_name": "Tony Russo",
                        "from_email": "t.russo@russolandscaping.com",
                        "to_emails": ["sarah.johnson@heavyequipdealer.com"],
                        "subject": "URGENT: Mini Excavator Required by Monday",
                        "body_text": "Sarah, URGENT REQUEST! We need a Kubota KX040-4 Mini Excavator by Monday. Our current equipment broke down and we have a project starting. Budget is $55,000 max. Can you help? Ship to: Russo Landscaping, 234 Garden Way, Atlanta, GA 30301. Please respond ASAP!",
                        "sent_at": "2025-12-14T08:00:00",
                        "direction": "inbound"
                    }
                ]
            }
        ]
        
        self.mock_emails = mock_conversations
        return mock_conversations
    
    def get_all_threads(self, db: Session) -> List[EmailThread]:
        """Get all email threads"""
        try:
            # Load mock data if not already loaded
            if not self.mock_emails:
                self.load_mock_emails()
            
            threads = []
            for conv in self.mock_emails:
                thread = EmailThread(
                    thread_id=conv["thread_id"],
                    subject=conv["subject"],
                    customer_name=conv.get("customer_name"),
                    customer_email=conv.get("customer_email"),
                    status=EmailStatus(conv.get("status", "open")),
                    message_count=len(conv.get("messages", [])),
                    first_message_at=datetime.fromisoformat(conv["messages"][0]["sent_at"]) if conv.get("messages") else None,
                    last_message_at=datetime.fromisoformat(conv["messages"][-1]["sent_at"]) if conv.get("messages") else None
                )
                threads.append(thread)
            
            return threads
            
        except Exception as e:
            logger.error(f"Error fetching email threads: {e}")
            return []
    
    def get_thread_by_id(self, db: Session, thread_id: int) -> Optional[Dict[str, Any]]:
        """Get specific email thread with messages"""
        try:
            if not self.mock_emails:
                self.load_mock_emails()
            
            for conv in self.mock_emails:
                if conv["thread_id"] == thread_id:
                    return conv
            
            return None
            
        except Exception as e:
            logger.error(f"Error fetching email thread {thread_id}: {e}")
            return None
    
    def summarize_thread(self, db: Session, thread_id: int) -> Optional[EmailSummary]:
        """
        Summarize an email thread using Azure OpenAI
        
        Args:
            db: Database session
            thread_id: Email thread ID
            
        Returns:
            EmailSummary object with extracted information
        """
        try:
            # Get the email thread
            thread_data = self.get_thread_by_id(db, thread_id)
            if not thread_data:
                logger.error(f"Email thread {thread_id} not found")
                return None
            
            # Call Azure OpenAI for summarization
            summary_data = azure_openai_service.summarize_email_conversation(
                thread_data["messages"]
            )
            
            # Create EmailSummary object
            summary = EmailSummary(
                thread_id=thread_id,
                summary_text=summary_data.get("summary", ""),
                requested_products=summary_data.get("requested_products", []),
                quantities=summary_data.get("quantities", {}),
                urgency=summary_data.get("urgency", "normal"),
                shipping_address=summary_data.get("shipping_address"),
                delivery_deadline=summary_data.get("delivery_deadline"),
                customer_comments=summary_data.get("customer_comments"),
                estimated_budget=summary_data.get("estimated_budget"),
                confidence_score=summary_data.get("confidence_score")
            )
            
            logger.info(f"Email thread {thread_id} summarized successfully")
            return summary
            
        except Exception as e:
            logger.error(f"Error summarizing email thread {thread_id}: {e}")
            raise
    
    def get_messages_for_thread(self, db: Session, thread_id: int) -> List[EmailMessage]:
        """Get all messages for a specific thread"""
        try:
            thread_data = self.get_thread_by_id(db, thread_id)
            if not thread_data:
                return []
            
            messages = []
            for idx, msg_data in enumerate(thread_data.get("messages", []), 1):
                message = EmailMessage(
                    message_id=idx,
                    thread_id=thread_id,
                    direction=msg_data.get("direction", "inbound"),
                    from_email=msg_data["from_email"],
                    from_name=msg_data.get("from_name"),
                    to_emails=msg_data["to_emails"],
                    subject=msg_data["subject"],
                    body_text=msg_data["body_text"],
                    sent_at=datetime.fromisoformat(msg_data["sent_at"]),
                    is_read=True
                )
                messages.append(message)
            
            return messages
            
        except Exception as e:
            logger.error(f"Error fetching messages for thread {thread_id}: {e}")
            return []


# Global service instance
email_service = EmailService()
