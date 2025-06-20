import { pythonApiClient } from './api';

export const getSalesTrends = async () => {
  try {
    const response = await pythonApiClient.get('/sales/trends');
    return response.data;
  } catch (error) {
    console.error('Error fetching sales trends:', error.response?.data || error.message);
    throw error;
  }
};

export const getProductRecommendations = async (productId) => {
  try {
    const response = await pythonApiClient.get(`/recommendations/product/${productId}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching product recommendations for ${productId}:`, error.response?.data || error.message);
    throw error;
  }
};

export const getUserRecommendations = async (userId) => {
  try {
    const response = await pythonApiClient.get(`/recommendations/user/${userId}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching user recommendations for ${userId}:`, error.response?.data || error.message);
    throw error;
  }
};

# Add other data analysis calls as needed
