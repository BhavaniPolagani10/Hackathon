import { useState, useRef, useEffect } from 'react';
import { TrendingUp, ChevronDown } from 'lucide-react';
import './Header.css';

interface HeaderProps {
  viewType: string;
  onViewChange: (view: string) => void;
}

const viewOptions = ['Opportunities', 'Clients'];

function Header({ viewType, onViewChange }: HeaderProps) {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  const handleViewSelect = (view: string) => {
    onViewChange(view);
    setIsDropdownOpen(false);
  };

  return (
    <header className="header">
      <div className="header-left">
        <div className="logo">
          <TrendingUp size={24} className="logo-icon" />
          <span className="logo-text">Sales Tracker</span>
        </div>
        <div className="view-selector-container" ref={dropdownRef}>
          <div 
            className="view-selector"
            onClick={() => setIsDropdownOpen(!isDropdownOpen)}
          >
            <span>View: {viewType}</span>
            <ChevronDown size={16} />
          </div>
          {isDropdownOpen && (
            <div className="view-dropdown">
              {viewOptions.map((option) => (
                <div
                  key={option}
                  className={`view-dropdown-item ${viewType === option ? 'selected' : ''}`}
                  onClick={() => handleViewSelect(option)}
                >
                  {option}
                </div>
              ))}
            </div>
          )}
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
