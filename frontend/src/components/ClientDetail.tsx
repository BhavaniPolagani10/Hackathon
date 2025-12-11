import { MessageSquare, BookOpen, FileText, Briefcase } from 'lucide-react';
import { useState, useEffect } from 'react';
import { Client, Opportunity } from '../types';
import { formatCurrency } from '../utils/formatCurrency';
import OpportunitySummary from './OpportunitySummary';
import ConversationView from './ConversationView';
import QuoteDetail from './QuoteDetail';
import { opportunityService } from '../services';
import './ClientDetail.css';

interface ClientDetailProps {
  client: Client;
}

function ClientDetail({ client }: ClientDetailProps) {
  const [showSummary, setShowSummary] = useState(false);
  const [showConversations, setShowConversations] = useState(false);
  const [showQuote, setShowQuote] = useState(false);
  const [quoteOpportunity, setQuoteOpportunity] = useState<Opportunity | null>(null);
  const [loadingOpportunity, setLoadingOpportunity] = useState(false);
  const [opportunityError, setOpportunityError] = useState<string | null>(null);
  
  // Get the first active opportunity for the summary view
  const activeOpportunity = client.associatedOpportunities.find(
    opp => opp.stage !== 'Closed - Won'
  ) || client.associatedOpportunities[0];
  
  // Only show summary button if there are opportunities
  const hasOpportunities = client.associatedOpportunities && client.associatedOpportunities.length > 0;
  
  // Get the first conversation (or find one matching the active opportunity)
  const conversation = client.conversations && client.conversations.length > 0 
    ? client.conversations[0] 
    : null;
  
  // Fetch opportunity details when quote view is shown
  useEffect(() => {
    const fetchOpportunityDetails = async () => {
      if (showQuote && activeOpportunity) {
        setLoadingOpportunity(true);
        setOpportunityError(null);
        
        try {
          // Extract opportunity ID from the name or use a mapping
          // For now, we'll try to match by name to get the opportunity number
          // In a real scenario, the client data should include the opportunity number
          const oppIdMatch = activeOpportunity.name.match(/OP-\d{4}-\d{3}/);
          const opportunityNumber = oppIdMatch ? oppIdMatch[0] : null;
          
          if (opportunityNumber) {
            const details = await opportunityService.getOpportunityDetails(opportunityNumber);
            setQuoteOpportunity(details);
          } else {
            // Fallback: create a basic opportunity object from available data
            console.warn('Opportunity number not found in name, using basic data');
            setQuoteOpportunity({
              id: activeOpportunity.id,
              opportunityId: activeOpportunity.id,
              name: activeOpportunity.name,
              status: activeOpportunity.stage,
              statusColor: '#3498db',
              description: '',
              timestamp: '',
              items: [],
              subtotal: activeOpportunity.value,
              taxRate: 8.5,
              taxAmount: activeOpportunity.value * 0.085,
              grandTotal: activeOpportunity.value * 1.085,
            });
          }
        } catch (error) {
          console.error('Failed to fetch opportunity details:', error);
          setOpportunityError('Failed to load opportunity details');
          // Fallback to basic data
          setQuoteOpportunity({
            id: activeOpportunity.id,
            opportunityId: activeOpportunity.id,
            name: activeOpportunity.name,
            status: activeOpportunity.stage,
            statusColor: '#3498db',
            description: '',
            timestamp: '',
            items: [],
            subtotal: activeOpportunity.value,
            taxRate: 8.5,
            taxAmount: activeOpportunity.value * 0.085,
            grandTotal: activeOpportunity.value * 1.085,
          });
        } finally {
          setLoadingOpportunity(false);
        }
      }
    };
    
    fetchOpportunityDetails();
  }, [showQuote, activeOpportunity]);
  
  const handleConversationToggle = () => {
    setShowConversations(!showConversations);
    if (!showConversations) {
      setShowSummary(false);
      setShowQuote(false);
    }
  };
  
  const handleSummaryToggle = () => {
    setShowSummary(!showSummary);
    if (!showSummary) {
      setShowConversations(false);
      setShowQuote(false);
    }
  };
  
  const handleQuoteToggle = () => {
    setShowQuote(!showQuote);
    if (!showQuote) {
      setShowConversations(false);
      setShowSummary(false);
    }
  };

  return (
    <div className="client-detail">
      {showConversations ? (
        conversation ? (
          <ConversationView conversation={conversation} clientName={client.name} />
        ) : (
          <div className="conversation-empty">
            <div className="empty-icon">
              <MessageSquare size={28} />
            </div>
            <div className="empty-text">No conversations yet for this client.</div>
          </div>
        )
      ) : showQuote ? (
        loadingOpportunity ? (
          <div className="loading-state">
            <div className="loading-spinner"></div>
            <div className="loading-text">Loading opportunity details...</div>
          </div>
        ) : opportunityError && !quoteOpportunity ? (
          <div className="error-state">
            <div className="error-text">{opportunityError}</div>
          </div>
        ) : quoteOpportunity ? (
          <QuoteDetail opportunity={quoteOpportunity} />
        ) : null
      ) : showSummary && hasOpportunities ? (
        <OpportunitySummary opportunity={activeOpportunity} clientName={client.name} />
      ) : (
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
      )}

      <aside className="client-detail-sidebar">
        {hasOpportunities && (
          <button 
            className={`sidebar-action ${showSummary ? 'active' : ''}`}
            aria-label="Summary"
            onClick={handleSummaryToggle}
          >
            <BookOpen size={20} />
          </button>
        )}
        <button 
          className={`sidebar-action ${showConversations ? 'active' : ''}`}
          aria-label="Conversations"
          onClick={handleConversationToggle}
        >
          <MessageSquare size={20} />
        </button>
        <button 
          className={`sidebar-action ${showQuote ? 'active' : ''}`}
          aria-label="Quote"
          onClick={handleQuoteToggle}
        >
          <FileText size={20} />
        </button>
      </aside>
    </div>
  );
}

export default ClientDetail;
