import { Pencil, FileText, FileIcon, Link, FileSpreadsheet, MessageSquare, Quote, Paperclip } from 'lucide-react';
import { useState } from 'react';
import { Opportunity } from '../types';
import { QuoteWithLineItems } from '../types/backend';
import { quoteService } from '../services/quoteService';
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
  const [quoteData, setQuoteData] = useState<QuoteWithLineItems | null>(null);
  const [loadingQuote, setLoadingQuote] = useState(false);
  const [quoteError, setQuoteError] = useState<string | null>(null);

  const handleQuoteClick = async () => {
    setShowQuote(!showQuote);
    
    // Only fetch quote if we're opening the quote view and don't have data yet
    if (!showQuote && !quoteData) {
      setLoadingQuote(true);
      setQuoteError(null);
      
      try {
        // For demo purposes, using a mock thread_id
        // In production, this would come from the opportunity data
        const threadId = 1; // This should be dynamic based on the opportunity
        const quote = await quoteService.generateQuote(threadId);
        setQuoteData(quote);
      } catch (error) {
        console.error('Error fetching quote:', error);
        setQuoteError(error instanceof Error ? error.message : 'Failed to load quote');
      } finally {
        setLoadingQuote(false);
      }
    }
  };

  const handleAttachmentsClick = () => {
    // Placeholder for attachments functionality
    console.log('Attachments clicked - functionality to be implemented');
  };

  return (
    <div className="opportunity-detail">
      <div className="detail-content">
        {showQuote ? (
          <div className="quote-view">
            <div className="detail-header">
              <div className="detail-info">
                <h1 className="detail-title">Quote Details</h1>
                <span className="detail-id">Opportunity ID: {opportunity.opportunityId}</span>
              </div>
            </div>
            
            {loadingQuote ? (
              <div className="quote-loading">
                <p>Loading quote...</p>
              </div>
            ) : quoteError ? (
              <div className="quote-error">
                <p>Error loading quote: {quoteError}</p>
              </div>
            ) : quoteData ? (
              <section className="items-section">
                <h2 className="section-title">Quote Information</h2>
                
                <div className="quote-info">
                  <div className="info-row">
                    <span className="info-label">Quote Number:</span>
                    <span className="info-value">{quoteData.quote_number}</span>
                  </div>
                  <div className="info-row">
                    <span className="info-label">Customer:</span>
                    <span className="info-value">{quoteData.customer_name}</span>
                  </div>
                  <div className="info-row">
                    <span className="info-label">Email:</span>
                    <span className="info-value">{quoteData.customer_email}</span>
                  </div>
                  <div className="info-row">
                    <span className="info-label">Quote Date:</span>
                    <span className="info-value">{quoteData.quote_date}</span>
                  </div>
                  <div className="info-row">
                    <span className="info-label">Valid Until:</span>
                    <span className="info-value">{quoteData.valid_until}</span>
                  </div>
                  {quoteData.notes && (
                    <div className="info-row">
                      <span className="info-label">Notes:</span>
                      <span className="info-value">{quoteData.notes}</span>
                    </div>
                  )}
                </div>

                <h2 className="section-title" style={{ marginTop: '2rem' }}>Line Items</h2>
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
                    {quoteData.line_items.map((item) => (
                      <tr key={item.line_number}>
                        <td className="col-item">
                          <div>{item.product_name}</div>
                          {item.description && (
                            <div style={{ fontSize: '0.875rem', color: '#6b7280', marginTop: '0.25rem' }}>
                              {item.description}
                            </div>
                          )}
                        </td>
                        <td className="col-quantity">{item.quantity}</td>
                        <td className="col-price">${item.unit_price.toFixed(2)}</td>
                        <td className="col-total">${item.line_total.toFixed(2)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>

                <div className="totals-section">
                  <div className="total-row">
                    <span className="total-label">Subtotal</span>
                    <span className="total-value">${quoteData.subtotal.toFixed(2)}</span>
                  </div>
                  <div className="total-row">
                    <span className="total-label">Tax ({quoteData.tax_rate}%)</span>
                    <span className="total-value">${quoteData.tax_amount.toFixed(2)}</span>
                  </div>
                  <div className="total-row grand-total">
                    <span className="total-label">Grand Total</span>
                    <span className="total-value">${quoteData.total_amount.toFixed(2)}</span>
                  </div>
                </div>
              </section>
            ) : null}
          </div>
        ) : (
          <>
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
          </>
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
          <button 
            className="sidebar-action"
            aria-label="Attachments"
            onClick={handleAttachmentsClick}
          >
            <Paperclip size={20} />
          </button>
        </aside>
      )}
    </div>
  );
}

export default OpportunityDetail;
