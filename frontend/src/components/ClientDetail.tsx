import { FileIcon, FileText, Link, FileSpreadsheet, MessageSquare } from 'lucide-react';
import { Client } from '../types';
import './ClientDetail.css';

interface ClientDetailProps {
  client: Client;
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0,
  }).format(value);
}

function ClientDetail({ client }: ClientDetailProps) {
  return (
    <div className="client-detail">
      <div className="client-detail-content">
        <div className="client-detail-header">
          <div className="client-detail-info">
            <h1 className="client-detail-title">{client.name}</h1>
            <span className="client-detail-subtitle">Client Details</span>
          </div>
        </div>

        <div className="client-detail-grid">
          <section className="company-info-section">
            <h2 className="section-title">Company Information</h2>
            
            <div className="info-field">
              <span className="info-label">Industry</span>
              <span className="info-value">{client.industry}</span>
            </div>
            
            <div className="info-field">
              <span className="info-label">Location</span>
              <span className="info-value">{client.location}</span>
            </div>
            
            <div className="info-field">
              <span className="info-label">Website</span>
              <a href={`https://${client.website}`} className="info-link" target="_blank" rel="noopener noreferrer">
                {client.website}
              </a>
            </div>
          </section>

          <section className="opportunities-section">
            <h2 className="section-title">Associated Opportunities</h2>
            
            <div className="opportunities-list">
              {client.associatedOpportunities.map((opp) => (
                <div key={opp.id} className="opportunity-row">
                  <div className="opportunity-info">
                    <span className="opportunity-name">{opp.name}</span>
                    <span className="opportunity-stage">Stage: {opp.stage}</span>
                  </div>
                  <div className="opportunity-value-info">
                    <span className="opportunity-value">{formatCurrency(opp.value)}</span>
                    {opp.probability !== undefined ? (
                      <span 
                        className="opportunity-probability"
                        style={{ 
                          color: opp.probability >= 70 ? '#10b981' : 
                                 opp.probability >= 50 ? '#f59e0b' : '#6b7280' 
                        }}
                      >
                        {opp.probability}% Probability
                      </span>
                    ) : opp.signedDate ? (
                      <span className="opportunity-signed-date">Signed {opp.signedDate}</span>
                    ) : null}
                  </div>
                </div>
              ))}
            </div>
          </section>
        </div>

        <section className="contacts-section">
          <h2 className="section-title">Key Contacts</h2>
          
          <div className="contacts-list">
            {client.keyContacts.map((contact) => (
              <div key={contact.id} className="contact-item">
                <div className="contact-avatar" aria-label={`${contact.name} avatar`}>
                  <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                    <circle cx="18" cy="18" r="18" fill={contact.avatarColor}/>
                    <circle cx="18" cy="14" r="6" fill="#9ca3af"/>
                    <path d="M6 32c0-6.627 5.373-12 12-12s12 5.373 12 12" fill="#9ca3af"/>
                  </svg>
                </div>
                <div className="contact-info">
                  <span className="contact-name">{contact.name}</span>
                  <span className="contact-title">{contact.title}</span>
                </div>
              </div>
            ))}
          </div>
        </section>
      </div>

      <aside className="client-detail-sidebar">
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
    </div>
  );
}

export default ClientDetail;
