import { Pencil, FileText, FileIcon, Link, FileSpreadsheet, MessageSquare, Quote } from 'lucide-react';
import { useState, useEffect } from 'react';
import { Opportunity } from '../types';
import { useQuoteGeneration } from '../hooks/useEmailData';
import './OpportunityDetail.css';

interface OpportunityDetailProps {
  opportunity: Opportunity;
  showSidebar?: boolean;
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 2,
  }).format(value);
}

function OpportunityDetail({ opportunity, showSidebar = true }: OpportunityDetailProps) {
  const [showQuote, setShowQuote] = useState(false);
  const threadId = Number(opportunity.id);
  const { quote, loading, error, generateQuote } = useQuoteGeneration(threadId || null);

  // Generate quote when the quote icon is clicked
  useEffect(() => {
    if (showQuote && !quote && !loading && !error) {
      generateQuote();
    }
  }, [showQuote, quote, loading, error, generateQuote]);

  const handleQuoteClick = () => {
    setShowQuote(!showQuote);
  };

  return (
    <div className="opportunity-detail">
      <div className="detail-content">
        <div className="detail-header">
          <div className="detail-info">
            <h1 className="detail-title">{opportunity.name}</h1>
            <span className="detail-id">Opportunity ID: {opportunity.opportunityId}</span>
          </div>
          <div className="detail-actions">
            <button className="action-btn secondary">
              <Pencil size={16} />
              Edit Opportunity
            </button>
          </div>
        </div>

        {showQuote && quote ? (
          <section className="items-section">
            <h2 className="section-title">AI Generated Quote Details</h2>
            <div className="quote-info">
              <div className="quote-header-info">
                <div className="info-field">
                  <span className="info-label">Quote Number:</span>
                  <span className="info-value">{quote.quote_number}</span>
                </div>
                <div className="info-field">
                  <span className="info-label">Customer:</span>
                  <span className="info-value">{quote.customer_name}</span>
                </div>
                <div className="info-field">
                  <span className="info-label">Valid Until:</span>
                  <span className="info-value">{new Date(quote.valid_until).toLocaleDateString()}</span>
                </div>
              </div>
            </div>
            
            <table className="items-table">
              <thead>
                <tr>
                  <th className="col-item">PRODUCT</th>
                  <th className="col-quantity">QUANTITY</th>
                  <th className="col-price">UNIT PRICE</th>
                  <th className="col-total">TOTAL</th>
                </tr>
              </thead>
              <tbody>
                {quote.line_items.map((item: any) => (
                  <tr key={item.line_number}>
                    <td className="col-item">{item.product_name}</td>
                    <td className="col-quantity">{item.quantity}</td>
                    <td className="col-price">{formatCurrency(Number(item.unit_price))}</td>
                    <td className="col-total">{formatCurrency(Number(item.line_total))}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            <div className="totals-section">
              <div className="total-row">
                <span className="total-label">Subtotal</span>
                <span className="total-value">{formatCurrency(Number(quote.subtotal))}</span>
              </div>
              <div className="total-row">
                <span className="total-label">Tax ({Number(quote.tax_rate)}%)</span>
                <span className="total-value">{formatCurrency(Number(quote.tax_amount))}</span>
              </div>
              {quote.shipping_amount > 0 && (
                <div className="total-row">
                  <span className="total-label">Shipping</span>
                  <span className="total-value">{formatCurrency(Number(quote.shipping_amount))}</span>
                </div>
              )}
              <div className="total-row grand-total">
                <span className="total-label">Grand Total</span>
                <span className="total-value">{formatCurrency(Number(quote.total_amount))}</span>
              </div>
            </div>
          </section>
        ) : showQuote && loading ? (
          <section className="items-section">
            <div className="quote-loading">Generating quote from AI...</div>
          </section>
        ) : showQuote && error ? (
          <section className="items-section">
            <div className="quote-error">Error loading quote: {error}</div>
          </section>
        ) : (
          <section className="items-section">
            <h2 className="section-title">Items</h2>
            <table className="items-table">
              <thead>
                <tr>
                  <th className="col-item">ITEM</th>
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
                    <td className="col-price">{formatCurrency(item.unitPrice)}</td>
                    <td className="col-total">{formatCurrency(item.total)}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            <div className="totals-section">
              <div className="total-row">
                <span className="total-label">Subtotal</span>
                <span className="total-value">{formatCurrency(opportunity.subtotal)}</span>
              </div>
              <div className="total-row">
                <span className="total-label">Tax ({opportunity.taxRate}%)</span>
                <span className="total-value">{formatCurrency(opportunity.taxAmount)}</span>
              </div>
              <div className="total-row grand-total">
                <span className="total-label">Grand Total</span>
                <span className="total-value">{formatCurrency(opportunity.grandTotal)}</span>
              </div>
            </div>
          </section>
        )}
      </div>

      {showSidebar && (
        <aside className="detail-sidebar">
          <button className="sidebar-action" aria-label="Notes">
            <FileIcon size={20} />
          </button>
          <button className="sidebar-action" aria-label="Documents">
            <FileText size={20} />
          </button>
          <button className="sidebar-action" aria-label="Links">
            <Link size={20} />
          </button>
          <button className="sidebar-action" aria-label="Spreadsheet">
            <FileSpreadsheet size={20} />
          </button>
          <button className="sidebar-action" aria-label="Comments">
            <MessageSquare size={20} />
          </button>
          <button 
            className={`sidebar-action ${showQuote ? 'active' : ''}`}
            aria-label="Quote" 
            onClick={handleQuoteClick}
          >
            <Quote size={20} />
          </button>
        </aside>
      )}
    </div>
  );
}

export default OpportunityDetail;
