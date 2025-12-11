/**
 * Configuration for mapping frontend opportunity names to backend opportunity numbers
 * This allows the frontend mock data to connect with real database opportunities
 */

// Default tax rate used for calculations when not provided by backend
export const DEFAULT_TAX_RATE = 8.5;

// Mapping of frontend opportunity names to database opportunity numbers
// Update this mapping to match your CRM database opportunity numbers
export const OPPORTUNITY_NAME_MAPPING: Record<string, string> = {
  'Innovate Corp Software Upgrade': 'OPP-001',
  'Q3 Infrastructure Overhaul': 'OPP-002',
  'Global Tech Expansion': 'OPP-003',
  // Add more mappings as needed
};

// Fallback opportunity data when backend is unavailable
export const createFallbackOpportunity = (
  activeOpportunity: { id: string; name: string; stage: string; value: number },
  description = 'Details not available'
) => ({
  id: activeOpportunity.id,
  opportunityId: activeOpportunity.id,
  name: activeOpportunity.name,
  status: activeOpportunity.stage,
  statusColor: '#3498db',
  description,
  timestamp: '',
  items: [],
  subtotal: activeOpportunity.value,
  taxRate: DEFAULT_TAX_RATE,
  taxAmount: activeOpportunity.value * (DEFAULT_TAX_RATE / 100),
  grandTotal: activeOpportunity.value * (1 + DEFAULT_TAX_RATE / 100),
});
