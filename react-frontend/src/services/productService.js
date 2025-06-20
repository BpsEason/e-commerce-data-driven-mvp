import { laravelApiClient } from './api';

export const getProducts = async () => {
  try {
    const response = await laravelApiClient.get('/products');
    return response.data;
  } catch (error) {
    console.error('Error fetching products:', error.response?.data || error.message);
    throw error;
  }
};

export const getProductById = async (id) => {
  try {
    const response = await laravelApiClient.get(`/products/${id}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching product ${id}:`, error.response?.data || error.message);
    throw error;
  }
};

# Add create, update, delete product functions if needed for admin panel
