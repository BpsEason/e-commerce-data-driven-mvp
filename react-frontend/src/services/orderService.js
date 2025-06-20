import { laravelApiClient } from './api';

export const getOrders = async () => {
  try {
    const response = await laravelApiClient.get('/orders');
    return response.data;
  } catch (error) {
    console.error('Error fetching orders:', error.response?.data || error.message);
    throw error;
  }
};

export const createOrder = async (orderData) => {
  try {
    const response = await laravelApiClient.post('/orders', orderData);
    return response.data;
  } catch (error) {
    console.error('Error creating order:', error.response?.data || error.message);
    throw error;
  }
};

export const getOrderById = async (id) => {
  try {
    const response = await laravelApiClient.get(`/orders/${id}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching order ${id}:`, error.response?.data || error.message);
    throw error;
  }
};

# Add update, delete order functions if needed (e.g., for admin)
