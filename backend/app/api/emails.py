"""
Email conversation API endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.models import EmailThread, EmailThreadWithMessages, EmailSummary, EmailMessage
from app.services import email_service
from app.utils import get_db

router = APIRouter(prefix="/emails", tags=["emails"])


@router.get("/", response_model=List[EmailThread])
async def list_email_threads(db: Session = Depends(get_db)):
    """
    List all email conversation threads
    
    Returns list of email threads with basic information
    """
    try:
        threads = email_service.get_all_threads(db)
        return threads
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch email threads: {str(e)}"
        )


@router.get("/{thread_id}", response_model=EmailThreadWithMessages)
async def get_email_thread(thread_id: int, db: Session = Depends(get_db)):
    """
    Get specific email thread with all messages
    
    Args:
        thread_id: Email thread ID
        
    Returns:
        Email thread with complete message history
    """
    try:
        thread_data = email_service.get_thread_by_id(db, thread_id)
        if not thread_data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Email thread {thread_id} not found"
            )
        
        # Get messages
        messages = email_service.get_messages_for_thread(db, thread_id)
        
        # Build response
        thread = EmailThreadWithMessages(
            thread_id=thread_data["thread_id"],
            subject=thread_data["subject"],
            customer_name=thread_data.get("customer_name"),
            customer_email=thread_data.get("customer_email"),
            status=thread_data.get("status", "open"),
            message_count=len(messages),
            messages=messages
        )
        
        return thread
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch email thread: {str(e)}"
        )


@router.get("/{thread_id}/messages", response_model=List[EmailMessage])
async def get_thread_messages(thread_id: int, db: Session = Depends(get_db)):
    """
    Get all messages for a specific email thread
    
    Args:
        thread_id: Email thread ID
        
    Returns:
        List of email messages in chronological order
    """
    try:
        messages = email_service.get_messages_for_thread(db, thread_id)
        if not messages:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"No messages found for thread {thread_id}"
            )
        return messages
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch messages: {str(e)}"
        )


@router.post("/{thread_id}/summarize", response_model=EmailSummary)
async def summarize_email_thread(thread_id: int, db: Session = Depends(get_db)):
    """
    Summarize an email thread using Azure GPT-4o
    
    Analyzes the conversation and extracts:
    - Summary of the conversation
    - Requested products and quantities
    - Urgency level
    - Shipping address
    - Delivery deadline
    - Customer comments and requirements
    
    Args:
        thread_id: Email thread ID
        
    Returns:
        Structured email summary with extracted information
    """
    try:
        summary = email_service.summarize_thread(db, thread_id)
        if not summary:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Email thread {thread_id} not found"
            )
        return summary
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to summarize email thread: {str(e)}"
        )
