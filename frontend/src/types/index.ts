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
