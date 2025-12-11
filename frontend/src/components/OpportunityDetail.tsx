import { Pencil, FileText, FileIcon, Link, FileSpreadsheet, MessageSquare } from 'lucide-react';
import { Opportunity } from '../types';
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
        </aside>
      )}
    </div>
  );
}

export default OpportunityDetail;
