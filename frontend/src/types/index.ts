export interface OpportunityItem {
  id: string;
  name: string;
  quantity: number;
  unitPrice: number;
  total: number;
}

export interface Opportunity {
  id: string;
  opportunityId: string;
  name: string;
  status: string;
  statusColor: string;
  description: string;
  timestamp: string;
  items: OpportunityItem[];
  subtotal: number;
  taxRate: number;
  taxAmount: number;
  grandTotal: number;
}

export interface Contact {
  id: string;
  name: string;
  title: string;
  avatarColor: string;
}

export interface AssociatedOpportunity {
  id: string;
  name: string;
  stage: string;
  value: number;
  probability?: number;
  signedDate?: string;
}

export interface Message {
  id: string;
  sender: string;
  senderType: 'user' | 'client';
  content: string;
  timestamp: string;
  isNote?: boolean;
  noteTitle?: string;
}

export interface Conversation {
  id: string;
  opportunityId: string;
  opportunityName: string;
  messages: Message[];
}

export interface Client {
  id: string;
  name: string;
  abbreviation: string;
  abbreviationColor: string;
  opportunityCount: number;
  opportunityLabel: string;
  industry: string;
  location: string;
  website: string;
  associatedOpportunities: AssociatedOpportunity[];
  keyContacts: Contact[];
  conversations?: Conversation[];
}
