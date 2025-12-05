import { Client } from '../types';
import './ClientSidebar.css';

interface ClientSidebarProps {
  clients: Client[];
  selectedId: string;
  onSelect: (id: string) => void;
}

function ClientSidebar({ clients, selectedId, onSelect }: ClientSidebarProps) {
  return (
    <aside className="client-sidebar">
      <div className="client-sidebar-header">
        <h2 className="client-sidebar-title">Clients</h2>
      </div>
      <div className="clients-list">
        {clients.map((client) => (
          <div
            key={client.id}
            className={`client-item ${selectedId === client.id ? 'selected' : ''}`}
            onClick={() => onSelect(client.id)}
          >
            <div
              className="client-abbreviation"
              style={{ backgroundColor: client.abbreviationColor }}
            >
              {client.abbreviation}
            </div>
            <div className="client-info">
              <span className="client-name">{client.name}</span>
              <span className="client-opportunity-count">
                {client.opportunityCount} {client.opportunityLabel}
              </span>
            </div>
          </div>
        ))}
      </div>
    </aside>
  );
}

export default ClientSidebar;
