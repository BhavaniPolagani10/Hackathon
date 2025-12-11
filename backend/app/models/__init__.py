"""Data models module"""
from .email import (
    EmailMessage,
    EmailThread,
    EmailThreadWithMessages,
    EmailSummary,
    EmailDirection,
    EmailStatus,
)
from .quote import (
    Quote,
    QuoteCreate,
    QuoteWithLineItems,
    QuoteLineItem,
    ProductPricing,
)

__all__ = [
    "EmailMessage",
    "EmailThread",
    "EmailThreadWithMessages",
    "EmailSummary",
    "EmailDirection",
    "EmailStatus",
    "Quote",
    "QuoteCreate",
    "QuoteWithLineItems",
    "QuoteLineItem",
    "ProductPricing",
]
