import { useState, useEffect } from 'react';
import Header from '../components/Header';
import Sidebar from '../components/Sidebar';
import OpportunityDetail from '../components/OpportunityDetail';
import ClientSidebar from '../components/ClientSidebar';
import ClientDetail from '../components/ClientDetail';
import { opportunities as mockOpportunities } from '../data/opportunities';
import { clients as mockClients } from '../data/clients';
import { useEmailData } from '../hooks/useEmailData';
import './SalesTrackerPage.css';

function SalesTrackerPage() {
  const { opportunities: backendOpportunities, clients: backendClients, loading, error } = useEmailData();
  
  // Use backend data if available, otherwise fall back to mock data
  const opportunities = backendOpportunities.length > 0 ? backendOpportunities : mockOpportunities;
  const clients = backendClients.length > 0 ? backendClients : mockClients;

  const [viewType, setViewType] = useState<string>('Opportunities');
  const [selectedOpportunityId, setSelectedOpportunityId] = useState(opportunities[0]?.id || '');
  const [selectedClientId, setSelectedClientId] = useState(clients[0]?.id || '');

  // Update selected IDs when data changes
  useEffect(() => {
    if (opportunities.length > 0 && !selectedOpportunityId) {
      setSelectedOpportunityId(opportunities[0].id);
    }
  }, [opportunities, selectedOpportunityId]);

  useEffect(() => {
    if (clients.length > 0 && !selectedClientId) {
      setSelectedClientId(clients[0].id);
    }
  }, [clients, selectedClientId]);

  const selectedOpportunity = opportunities.find((opp) => opp.id === selectedOpportunityId);
  const selectedClient = clients.find((client) => client.id === selectedClientId);

  const handleViewChange = (view: string) => {
    setViewType(view);
  };

  return (
    <div className="sales-tracker-page">
      <Header viewType={viewType} onViewChange={handleViewChange} />
      {loading && (
        <div style={{ padding: '20px', textAlign: 'center' }}>
          Loading data from backend...
        </div>
      )}
      {error && (
        <div style={{ padding: '20px', color: '#e74c3c', backgroundColor: '#fef5f5', borderRadius: '4px', margin: '20px' }}>
          <strong>Backend Error:</strong> {error}. Showing mock data as fallback.
        </div>
      )}
      <div className="page-content">
        {viewType === 'Opportunities' ? (
          <>
            <Sidebar
              opportunities={opportunities}
              selectedId={selectedOpportunityId}
              onSelect={setSelectedOpportunityId}
            />
            {selectedOpportunity && (
              <OpportunityDetail opportunity={selectedOpportunity} showSidebar={true} />
            )}
          </>
        ) : (
          <>
            <ClientSidebar
              clients={clients}
              selectedId={selectedClientId}
              onSelect={setSelectedClientId}
            />
            {selectedClient && <ClientDetail client={selectedClient} />}
          </>
        )}
      </div>
    </div>
  );
}

export default SalesTrackerPage;
