import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import SalesTrackerPage from './pages/SalesTrackerPage'

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<SalesTrackerPage />} />
        <Route path="/opportunities" element={<SalesTrackerPage />} />
        <Route path="/clients" element={<SalesTrackerPage />} />
      </Routes>
    </Router>
  )
}

export default App
