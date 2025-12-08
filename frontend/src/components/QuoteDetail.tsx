import { Opportunity } from '../types';
import { formatCurrency } from '../utils/formatCurrency';
import './QuoteDetail.css';

interface QuoteDetailProps {
  opportunity: Opportunity;
  clientName: string;
}

function QuoteDetail({ opportunity }: QuoteDetailProps) {
  return (
    <div className="quote-detail">
      <div className="quote-detail-content">
        <div className="quote-detail-header">
          <div className="quote-detail-info">
            <h1 className="quote-detail-title">{opportunity.name}</h1>
            <span className="quote-detail-subtitle">Opportunity ID: {opportunity.opportunityId}</span>
          </div>
        </div>

        <section className="items-section">
          <h2 className="section-title">Items</h2>
          <table className="items-table">
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
                  <td className="col-price">{formatCurrency(item.unitPrice)}</td>
                  <td className="col-total">{formatCurrency(item.total)}</td>
                </tr>
              ))}
            </tbody>
          </table>

          <div className="totals-section">
            <div className="total-row">
              <span className="total-label">Subtotal:</span>
              <span className="total-value">{formatCurrency(opportunity.subtotal)}</span>
            </div>
            <div className="total-row">
              <span className="total-label">Tax ({opportunity.taxRate}%):</span>
              <span className="total-value">{formatCurrency(opportunity.taxAmount)}</span>
            </div>
            <div className="total-row grand-total">
              <span className="total-label">Grand Total:</span>
              <span className="total-value">{formatCurrency(opportunity.grandTotal)}</span>
            </div>
          </div>
        </section>
      </div>
    </div>
  );
}

export default QuoteDetail;
