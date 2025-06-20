import React, { useState, useEffect } from 'react';
import { getSalesTrends, getUserRecommendations } from '../../services/dataAnalysisService'; # Create this service
import Sidebar from '../../components/Sidebar';

function Dashboard() {
  const [salesTrends, setSalesTrends] = useState([]);
  const [userRecommendations, setUserRecommendations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const currentUser = JSON.parse(localStorage.getItem('user')); # Get current user info

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setError('');
      try {
        # Fetch sales trends from Python backend
        const trends = await getSalesTrends();
        setSalesTrends(trends);

        # Fetch user recommendations from Python backend (if user is logged in)
        if (currentUser && currentUser.id) {
          const recommendations = await getUserRecommendations(currentUser.id);
          setUserRecommendations(recommendations);
        }

      } catch (err) {
        console.error('Dashboard data fetch error:', err);
        setError('Failed to load dashboard data. Please try again.');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [currentUser]);

  if (loading) return <div>Loading dashboard...</div>;
  if (error) return <div className="error-message">{error}</div>;

  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="dashboard-content">
        <h2>Welcome to Your Dashboard, {currentUser ? currentUser.name : 'Guest'}!</h2>

        <section className="sales-trends">
          <h3>Sales Trends (from Python Backend)</h3>
          {salesTrends.length > 0 ? (
            <ul>
              {salesTrends.map((trend, index) => (
                <li key={index}>Date: {trend.date}, Sales: ${trend.daily_sales.toFixed(2)}</li>
              ))}
            </ul>
          ) : (
            <p>No sales trend data available.</p>
          )}
        </section>

        <section className="user-recommendations">
          <h3>Recommended Products for You (from Python Backend)</h3>
          {userRecommendations.length > 0 ? (
            <div className="product-recommendations-grid">
              {userRecommendations.map((product) => (
                <div key={product.id} className="recommendation-card">
                  <h4>{product.name}</h4>
                  <p>{product.description}</p>
                  <p>Price: ${product.price.toFixed(2)}</p>
                  <p>Relevance Score: {product.score.toFixed(2)}</p>
                </div>
              ))}
            </div>
          ) : (
            <p>No personalized recommendations available at the moment. Explore more products!</p>
          )}
        </section>

        {/* Add more dashboard widgets here (e.g., recent orders, popular products from Laravel) */}
      </div>
    </div>
  );
}

export default Dashboard;
