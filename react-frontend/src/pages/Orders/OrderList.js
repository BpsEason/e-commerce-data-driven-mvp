import React, { useState, useEffect } from 'react';
import { getOrders } from '../../services/orderService'; # Create this service

function OrderList() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchOrders = async () => {
      setLoading(true);
      setError('');
      try {
        const data = await getOrders();
        setOrders(data);
      } catch (err) {
        console.error('Error fetching orders:', err);
        setError('Failed to load orders. Please log in or try again.');
      } finally {
        setLoading(false);
      }
    };
    fetchOrders();
  }, []);

  if (loading) return <div>Loading orders...</div>;
  if (error) return <div className="error-message">{error}</div>;

  return (
    <div className="orders-container">
      <h2>Your Orders</h2>
      {orders.length === 0 ? (
        <p>You haven't placed any orders yet.</p>
      ) : (
        <div className="order-list">
          {orders.map((order) => (
            <div key={order.id} className="order-card">
              <h3>Order #{order.id}</h3>
              <p>Total: ${order.total_amount.toFixed(2)}</p>
              <p>Status: {order.status}</p>
              <p>Ordered On: {new Date(order.created_at).toLocaleString()}</p>
              <h4>Items:</h4>
              <ul>
                {order.items && order.items.map(item => (
                  <li key={item.id}>
                    {item.product ? item.product.name : 'Unknown Product'} (x{item.quantity}) - ${item.price.toFixed(2)} each
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default OrderList;
