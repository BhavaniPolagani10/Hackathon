import { TrendingUp, ChevronDown } from 'lucide-react';
import './Header.css';

interface HeaderProps {
  viewType: string;
}

function Header({ viewType }: HeaderProps) {
  return (
    <header className="header">
      <div className="header-left">
        <div className="logo">
          <TrendingUp size={24} className="logo-icon" />
          <span className="logo-text">Sales Tracker</span>
        </div>
        <div className="view-selector">
          <span>View: {viewType}</span>
          <ChevronDown size={16} />
        </div>
      </div>
      <div className="header-right">
        <div className="user-avatar">
          <svg viewBox="0 0 36 36" fill="none" xmlns="http://www.w3.org/2000/svg">
            <circle cx="18" cy="18" r="18" fill="#e5e7eb"/>
            <circle cx="18" cy="14" r="6" fill="#9ca3af"/>
            <path d="M6 32c0-6.627 5.373-12 12-12s12 5.373 12 12" fill="#9ca3af"/>
          </svg>
        </div>
      </div>
    </header>
  );
}

export default Header;
