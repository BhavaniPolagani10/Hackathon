import { Opportunity } from '../types';
import { formatCurrency } from '../utils/formatCurrency';
import './QuoteView.css';

interface QuoteViewProps {
  opportunity: Opportunity;
}

function QuoteView({ opportunity }: QuoteViewProps) {
  return (
    <div className="quote-view">
      <div className="quote-content">
        <div className="quote-header">
          <div className="quote-info">
            <h1 className="quote-title">{opportunity.name}</h1>
            <span className="quote-id">Opportunity ID: {opportunity.opportunityId}</span>
          </div>
          <div className="quote-actions">
            <button className="action-btn secondary">Edit Opportunity</button>
            <button className="action-btn primary">Generate Document</button>
          </div>
        </div>

        <section className="quote-items-section">
          <h2 className="section-title">Items</h2>
          <table className="quote-items-table">
            <thead>
              <tr>
                <th className="col-product">PRODUCT / SERVICE</th>
                <th className="col-quantity">QUANTITY</th>
                <th className="col-price">UNIT PRICE</th>
                <th className="col-total">TOTAL</th>
              </tr>
            </thead>
            <tbody>
              {opportunity.items.map((item) => (
                <tr key={item.id}>
                  <td className="col-product">{item.name}</td>
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
    </div>
  );
}

export default QuoteView;
