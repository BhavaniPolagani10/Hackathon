import { useState } from 'react';
import Header from '../components/Header';
import Sidebar from '../components/Sidebar';
import OpportunityDetail from '../components/OpportunityDetail';
import { opportunities } from '../data/opportunities';
import './SalesTrackerPage.css';

function SalesTrackerPage() {
  const [selectedOpportunityId, setSelectedOpportunityId] = useState(opportunities[0]?.id || '');

  const selectedOpportunity = opportunities.find((opp) => opp.id === selectedOpportunityId);

  return (
    <div className="sales-tracker-page">
      <Header viewType="Opportunities" />
      <div className="page-content">
        <Sidebar
          opportunities={opportunities}
          selectedId={selectedOpportunityId}
          onSelect={setSelectedOpportunityId}
        />
        {selectedOpportunity && <OpportunityDetail opportunity={selectedOpportunity} />}
      </div>
    </div>
  );
}

export default SalesTrackerPage;
