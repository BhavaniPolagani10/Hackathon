import { useState } from 'react';
import Header from '../components/Header';
import Sidebar from '../components/Sidebar';
import OpportunityDetail from '../components/OpportunityDetail';
import { opportunities as initialOpportunities } from '../data/opportunities';
import './SalesTrackerPage.css';

function SalesTrackerPage() {
  const [opps, setOpps] = useState(initialOpportunities);
  const [selectedOpportunityId, setSelectedOpportunityId] = useState(opps[0]?.id || '');

  const selectedOpportunity = opps.find((opp) => opp.id === selectedOpportunityId);

  function handleUpdate(updated: typeof opps[number]) {
    setOpps((prev) => prev.map((o) => (o.id === updated.id ? updated : o)));
  }

  return (
    <div className="sales-tracker-page">
      <Header viewType="Opportunities" />
      <div className="page-content">
        <Sidebar
          opportunities={opps}
          selectedId={selectedOpportunityId}
          onSelect={setSelectedOpportunityId}
        />
        {selectedOpportunity && (
          <OpportunityDetail opportunity={selectedOpportunity} onUpdate={handleUpdate} />
        )}
      </div>
    </div>
  );
}

export default SalesTrackerPage;
