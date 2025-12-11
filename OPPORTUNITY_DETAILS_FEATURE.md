# Opportunity Details Feature

## Overview

This feature allows users to view detailed opportunity/quote information from the backend CRM database when clicking the quote icon in the client detail page.

## Architecture

### Backend API

**Endpoint:** `GET /api/v1/opportunities/{opportunity_number}`

Fetches detailed opportunity information including:
- Basic opportunity details (name, stage, amount, probability, dates)
- Associated customer information
- Quote details (if available)
- Quote line items with products, quantities, and pricing
- Calculated totals (subtotal, tax, grand total)

**Example Response:**
```json
{
  "id": "428",
  "opportunityId": "OPP-001",
  "name": "Thompson Excavating - CAT 320",
  "customerName": "Thompson Excavating",
  "stage": "Closed Won",
  "amount": 288000.00,
  "probability": 100,
  "items": [
    {
      "id": "1",
      "name": "CAT 320 Next Gen Hydraulic Excavator",
      "quantity": 1,
      "unitPrice": 288000.00,
      "total": 288000.00
    }
  ],
  "subtotal": 288000.00,
  "taxRate": 0.00,
  "taxAmount": 0.00,
  "grandTotal": 288000.00
}
```

### Frontend Integration

The frontend fetches opportunity details when the user clicks the quote/opportunity icon:

1. **Service Layer**: `opportunityService.ts` handles API communication
2. **Component**: `ClientDetail.tsx` manages state and rendering
3. **Configuration**: `opportunityConfig.ts` maps frontend opportunity names to backend IDs

### Loading States

- **Loading**: Shows a spinner while fetching data
- **Error**: Displays error message if fetch fails
- **Fallback**: Uses basic data if backend is unavailable

## Configuration

### Opportunity Name Mapping

Edit `frontend/src/config/opportunityConfig.ts` to map frontend opportunity names to backend opportunity numbers:

```typescript
export const OPPORTUNITY_NAME_MAPPING: Record<string, string> = {
  'Innovate Corp Software Upgrade': 'OPP-001',
  'Q3 Infrastructure Overhaul': 'OPP-002',
  // Add more mappings...
};
```

### Tax Rate

Default tax rate is configured in `opportunityConfig.ts`:

```typescript
export const DEFAULT_TAX_RATE = 8.5; // 8.5%
```

## Database Schema

The backend queries the following CRM tables:

- `crm.crm_opportunity` - Opportunity details
- `crm.crm_customer` - Customer information
- `crm.crm_opportunity_stage` - Opportunity stages
- `crm.crm_quotation` - Quote headers
- `crm.crm_quote_line_item` - Quote line items

## Error Handling

The implementation includes robust error handling:

1. **Network Errors**: Caught and logged, fallback data displayed
2. **Missing Data**: Returns 404 if opportunity not found
3. **Database Errors**: Returns 500 with error details
4. **Frontend Fallback**: Shows basic data from client object if backend fails

## Testing

### Backend
```bash
cd backend
python -c "from app.api.opportunities import router; print('✓ OK')"
```

### Frontend
```bash
cd frontend
npm run build
```

## Future Enhancements

1. **Caching**: Add client-side caching to reduce API calls
2. **Real-time Updates**: Implement WebSocket for live updates
3. **Edit Capability**: Allow inline editing of opportunity details
4. **Export**: Add PDF export functionality for quotes
5. **Activity Feed**: Show opportunity timeline and history
