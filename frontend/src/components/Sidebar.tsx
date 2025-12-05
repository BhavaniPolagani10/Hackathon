import { Opportunity } from '../types';
import './Sidebar.css';

interface SidebarProps {
  opportunities: Opportunity[];
  selectedId: string;
  onSelect: (id: string) => void;
}

function Sidebar({ opportunities, selectedId, onSelect }: SidebarProps) {
  return (
    <aside className="sidebar">
      <div className="sidebar-header">
        <h2 className="sidebar-title">Opportunities</h2>
      </div>
      <div className="opportunities-list">
        {opportunities.map((opp) => (
          <div
            key={opp.id}
            className={`opportunity-item ${selectedId === opp.id ? 'selected' : ''}`}
            onClick={() => onSelect(opp.id)}
          >
            <div className="opportunity-header">
              <span className="opportunity-name">{opp.name}</span>
              <span className="opportunity-time">{opp.timestamp}</span>
            </div>
            <div className="opportunity-status" style={{ color: opp.statusColor }}>
              Status: {opp.status}
            </div>
            <div className="opportunity-description">{opp.description}</div>
          </div>
        ))}
      </div>
    </aside>
  );
}

export default Sidebar;
