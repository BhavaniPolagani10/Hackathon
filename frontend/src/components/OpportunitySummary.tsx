import { AssociatedOpportunity } from '../types';
import './OpportunitySummary.css';

interface OpportunitySummaryProps {
  opportunity: AssociatedOpportunity;
  clientName: string;
}

function formatCurrency(value: number): string {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: 0,
  }).format(value);
}

function OpportunitySummary({ opportunity, clientName }: OpportunitySummaryProps) {
  return (
    <div className="opportunity-summary">
      <div className="summary-header">
        <h1 className="summary-title">{clientName} {opportunity.name}</h1>
        <span className="summary-subtitle">Opportunity Summary</span>
      </div>

      <div className="summary-metrics">
        <div className="metric-card">
          <span className="metric-label">Value</span>
          <span className="metric-value">{formatCurrency(opportunity.value)}</span>
        </div>

        <div className="metric-card">
          <span className="metric-label">Stage</span>
          <span className="metric-value">{opportunity.stage}</span>
        </div>

        <div className="metric-card">
          <span className="metric-label">Est. Close Date</span>
          <span className="metric-value">
            {opportunity.signedDate || 'Dec 15, 2023'}
          </span>
        </div>
      </div>

      <section className="overview-section">
        <h2 className="section-title">Overview</h2>
        <p className="overview-text">
          {clientName} is looking to upgrade their entire software stack to improve efficiency and
          scalability. We have submitted a comprehensive proposal that addresses their key pain
          points, including legacy system integration and user experience challenges. The current
          stage is "{opportunity.stage}", and we are awaiting feedback from their technical review committee.
          The estimated value is {formatCurrency(opportunity.value)} with a {opportunity.probability || 75}% probability of closing. Next steps involve a
          follow-up call scheduled for next week to discuss the proposal details and address any
          questions.
        </p>
      </section>
    </div>
  );
}

export default OpportunitySummary;
