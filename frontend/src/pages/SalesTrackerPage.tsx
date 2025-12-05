import { useState } from 'react';
import Header from '../components/Header';
import Sidebar from '../components/Sidebar';
import OpportunityDetail from '../components/OpportunityDetail';
import ClientSidebar from '../components/ClientSidebar';
import ConversationDetail from '../components/ConversationDetail';
import { opportunities } from '../data/opportunities';
import { clients } from '../data/clients';
import { conversations } from '../data/conversations';
import './SalesTrackerPage.css';

function SalesTrackerPage() {
  const [viewType, setViewType] = useState<string>('Clients');
  const [selectedOpportunityId, setSelectedOpportunityId] = useState(opportunities[0]?.id || '');
  const [selectedClientId, setSelectedClientId] = useState(clients[0]?.id || '');

  const selectedOpportunity = opportunities.find((opp) => opp.id === selectedOpportunityId);
  const selectedClient = clients.find((client) => client.id === selectedClientId);
  const selectedConversation = conversations.find((conv) => conv.clientId === selectedClientId);

  const handleViewChange = (view: string) => {
    setViewType(view);
  };

  return (
    <div className="sales-tracker-page">
      <Header viewType={viewType} onViewChange={handleViewChange} />
      <div className="page-content">
        {viewType === 'Opportunities' ? (
          <>
            <Sidebar
              opportunities={opportunities}
              selectedId={selectedOpportunityId}
              onSelect={setSelectedOpportunityId}
            />
            {selectedOpportunity && <OpportunityDetail opportunity={selectedOpportunity} />}
          </>
        ) : (
          <>
            <ClientSidebar
              clients={clients}
              selectedId={selectedClientId}
              onSelect={setSelectedClientId}
            />
            {selectedClient && selectedConversation && (
              <ConversationDetail client={selectedClient} conversation={selectedConversation} />
            )}
          </>
        )}
      </div>
    </div>
  );
}

export default SalesTrackerPage;
