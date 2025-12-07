import { Opportunity } from '../types';
import { formatCurrency } from '../utils/formatCurrency';
import './OpportunityQuote.css';

interface OpportunityQuoteProps {
  opportunity: Opportunity;
}

function OpportunityQuote({ opportunity }: OpportunityQuoteProps) {
  return (
    <div className="opportunity-quote">
      <div className="quote-header">
        <h1 className="quote-title">{opportunity.name}</h1>
        <span className="quote-subtitle">Opportunity ID: {opportunity.opportunityId}</span>
      </div>

      <div className="quote-actions">
        <button className="action-btn primary">
          Generate Document
        </button>
      </div>

      <section className="quote-items-section">
        <h2 className="section-title">Items</h2>
        <table className="quote-items-table">
          <thead>
            <tr>
              <th className="col-item">PRODUCT / SERVICE</th>
              <th className="col-quantity">QUANTITY</th>
              <th className="col-price">UNIT PRICE</th>
              <th className="col-total">TOTAL</th>
            </tr>
          </thead>
          <tbody>
            {opportunity.items.map((item) => (
              <tr key={item.id}>
                <td className="col-item">{item.name}</td>
                <td className="col-quantity">{item.quantity}</td>
                <td className="col-price">{formatCurrency(item.unitPrice, 2)}</td>
                <td className="col-total">{formatCurrency(item.total, 2)}</td>
              </tr>
            ))}
          </tbody>
        </table>

        <div className="quote-totals-section">
          <div className="quote-total-row">
            <span className="quote-total-label">Subtotal:</span>
            <span className="quote-total-value">{formatCurrency(opportunity.subtotal, 2)}</span>
          </div>
          <div className="quote-total-row">
            <span className="quote-total-label">Tax ({opportunity.taxRate}%):</span>
            <span className="quote-total-value">{formatCurrency(opportunity.taxAmount, 2)}</span>
          </div>
          <div className="quote-total-row quote-grand-total">
            <span className="quote-total-label">Grand Total:</span>
            <span className="quote-total-value">{formatCurrency(opportunity.grandTotal, 2)}</span>
          </div>
        </div>
      </section>
    </div>
  );
}

export default OpportunityQuote;
