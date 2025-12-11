// Utility functions to transform backend data to frontend data structures
import { EmailThread, EmailThreadWithMessages, QuoteWithLineItems } from '../types/backend';
import { Opportunity, Client, Message, Conversation } from '../types';

/**
 * Transform backend email thread to frontend opportunity
 */
export function transformThreadToOpportunity(thread: EmailThread, quote?: QuoteWithLineItems): Opportunity {
  const items = quote?.line_items.map((item, index) => ({
    id: `item-${index + 1}`,
    name: item.product_name,
    quantity: item.quantity,
    unitPrice: Number(item.unit_price),
    total: Number(item.line_total),
  })) || [];

  const subtotal = quote ? Number(quote.subtotal) : 0;
  const taxRate = quote ? Number(quote.tax_rate) : 0;
  const taxAmount = quote ? Number(quote.tax_amount) : 0;
  const grandTotal = quote ? Number(quote.total_amount) : 0;

  const statusMap: Record<string, { status: string; color: string }> = {
    'open': { status: 'Needs Analysis', color: '#3498db' },
    'in_progress': { status: 'Proposal Sent', color: '#e67e22' },
    'quote_generated': { status: 'Proposal Sent', color: '#e67e22' },
    'closed': { status: 'Closed - Won', color: '#27ae60' },
  };

  const statusInfo = statusMap[thread.status] || { status: 'Open', color: '#95a5a6' };

  return {
    id: String(thread.thread_id),
    opportunityId: quote?.quote_number || `OP-${thread.thread_id}`,
    name: thread.subject,
    status: statusInfo.status,
    statusColor: statusInfo.color,
    description: thread.summary || 'Email conversation',
    timestamp: formatTimestamp(thread.last_message_at || thread.created_at),
    items,
    subtotal,
    taxRate,
    taxAmount,
    grandTotal,
  };
}

/**
 * Transform backend email thread to frontend client
 */
export function transformThreadToClient(thread: EmailThreadWithMessages): Client | null {
  if (!thread.customer_name || !thread.customer_email) {
    return null;
  }

  // Generate abbreviation from customer name
  const nameParts = thread.customer_name.split(' ');
  const abbreviation = nameParts.length > 1
    ? nameParts[0][0] + nameParts[nameParts.length - 1][0]
    : thread.customer_name.substring(0, 2);

  // Transform messages to conversation format
  const messages: Message[] = thread.messages.map((msg, idx) => ({
    id: `msg-${msg.message_id || idx}`,
    sender: msg.direction === 'inbound' 
      ? `${msg.from_name || thread.customer_name} (Client)`
      : `${msg.from_name || 'Sales Rep'} (You)`,
    senderType: msg.direction === 'inbound' ? 'client' : 'user',
    content: msg.body_text,
    timestamp: formatTimestamp(msg.sent_at),
  }));

  const conversation: Conversation = {
    id: `conv-${thread.thread_id}`,
    opportunityId: `opp-${thread.thread_id}`,
    opportunityName: thread.subject,
    messages,
  };

  return {
    id: String(thread.thread_id),
    name: thread.customer_name,
    abbreviation: abbreviation.toUpperCase(),
    abbreviationColor: '#3b82f6',
    opportunityCount: 1,
    opportunityLabel: 'Active Opportunity',
    industry: 'Unknown',
    location: 'Unknown',
    website: thread.customer_email.split('@')[1] || '',
    associatedOpportunities: [{
      id: `opp-${thread.thread_id}`,
      name: thread.subject,
      stage: thread.status === 'closed' ? 'Closed - Won' : 'Proposal',
      value: 0,
      probability: 50,
    }],
    keyContacts: [{
      id: `contact-${thread.thread_id}`,
      name: thread.customer_name,
      title: 'Contact',
      avatarColor: '#e5e7eb',
    }],
    conversations: [conversation],
  };
}

/**
 * Format timestamp for display
 */
function formatTimestamp(timestamp: string): string {
  const date = new Date(timestamp);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

  if (diffDays === 0) {
    return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  } else if (diffDays === 1) {
    return 'Yesterday';
  } else if (diffDays < 7) {
    return `${diffDays} days ago`;
  } else {
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  }
}
