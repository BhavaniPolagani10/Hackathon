import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { logoutUser, subscribeToAuthChanges } from '../services/authService';
import './Dashboard.css';

const Dashboard = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const unsubscribe = subscribeToAuthChanges((currentUser) => {
      if (currentUser) {
        setUser(currentUser);
      } else {
        navigate('/login');
      }
      setLoading(false);
    });

    return () => unsubscribe();
  }, [navigate]);

  const handleLogout = async () => {
    await logoutUser();
    navigate('/login');
  };

  if (loading) {
    return (
      <div className="dashboard-loading">
        <div className="spinner"></div>
        <p>Loading...</p>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <div className="header-content">
          <h1>Dealer Management System</h1>
          <div className="user-info">
            <span>{user?.email}</span>
            <button onClick={handleLogout} className="logout-btn">
              Sign Out
            </button>
          </div>
        </div>
      </header>

      <main className="dashboard-main">
        <div className="welcome-section">
          <h2>Welcome to the Dashboard</h2>
          <p>Manage your sales, customers, quotes, and inventory from one place.</p>
        </div>

        <div className="dashboard-grid">
          <div className="dashboard-card">
            <div className="card-icon">📧</div>
            <h3>Email Management</h3>
            <p>View and manage customer emails with AI-powered classification</p>
            <span className="card-stat">Coming Soon</span>
          </div>

          <div className="dashboard-card">
            <div className="card-icon">👥</div>
            <h3>Customers</h3>
            <p>360° view of customer information, history, and documents</p>
            <span className="card-stat">Coming Soon</span>
          </div>

          <div className="dashboard-card">
            <div className="card-icon">📝</div>
            <h3>Quotes</h3>
            <p>Generate quotes with machine configuration and pricing</p>
            <span className="card-stat">Coming Soon</span>
          </div>

          <div className="dashboard-card">
            <div className="card-icon">📦</div>
            <h3>Inventory</h3>
            <p>Real-time stock availability across all warehouses</p>
            <span className="card-stat">Coming Soon</span>
          </div>

          <div className="dashboard-card">
            <div className="card-icon">🛒</div>
            <h3>Purchase Orders</h3>
            <p>Automated PO generation and vendor management</p>
            <span className="card-stat">Coming Soon</span>
          </div>

          <div className="dashboard-card">
            <div className="card-icon">📊</div>
            <h3>Sales Pipeline</h3>
            <p>Track deals and forecast sales performance</p>
            <span className="card-stat">Coming Soon</span>
          </div>
        </div>
      </main>
    </div>
  );
};

export default Dashboard;
