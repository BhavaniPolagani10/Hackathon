// Backend API types
export interface EmailMessage {
  message_id?: number;
  thread_id?: number;
  direction: 'inbound' | 'outbound';
  from_email: string;
  from_name?: string;
  to_emails: string[];
  subject: string;
  body_text: string;
  sent_at: string;
  is_read: boolean;
}

export interface EmailThread {
  thread_id?: number;
  subject: string;
  customer_name?: string;
  customer_email?: string;
  status: 'open' | 'in_progress' | 'quote_generated' | 'closed';
  message_count: number;
  first_message_at?: string;
  last_message_at?: string;
  summary?: string;
  quote_id?: number;
  created_at: string;
  updated_at: string;
}

export interface EmailThreadWithMessages extends EmailThread {
  messages: EmailMessage[];
}

export interface EmailSummary {
  thread_id: number;
  summary_text: string;
  requested_products: string[];
  quantities: Record<string, number>;
  urgency: string;
  shipping_address?: string;
  delivery_deadline?: string;
  customer_comments?: string;
  estimated_budget?: number;
  confidence_score?: number;
  created_at: string;
}

export interface QuoteLineItem {
  line_number: number;
  product_code: string;
  product_name: string;
  description?: string;
  quantity: number;
  unit_price: number;
  discount_percent: number;
  line_total: number;
  lead_time_days?: number;
}

export interface Quote {
  quote_id?: number;
  quote_number: string;
  thread_id?: number;
  customer_name: string;
  customer_email: string;
  customer_company?: string;
  quote_date: string;
  valid_until: string;
  subtotal: number;
  discount_amount: number;
  tax_rate: number;
  tax_amount: number;
  shipping_amount: number;
  total_amount: number;
  shipping_address?: string;
  payment_terms: string;
  delivery_terms?: string;
  notes?: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface QuoteWithLineItems extends Quote {
  line_items: QuoteLineItem[];
}

export interface ProductPricing {
  product_code: string;
  product_name: string;
  category?: string;
  base_price: number;
  discount_percent: number;
  final_price: number;
  currency: string;
  last_purchase_date?: string;
  last_purchase_quantity?: number;
  lead_time_days?: number;
}
