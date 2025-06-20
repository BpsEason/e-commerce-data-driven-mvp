import { laravelApiClient } from './api';

export const loginUser = async (credentials) => {
  try {
    const response = await laravelApiClient.post('/login', credentials);
    return response.data;
  } catch (error) {
    console.error('Login error:', error.response?.data || error.message);
    throw error;
  }
};

export const registerUser = async (userData) => {
  try {
    const response = await laravelApiClient.post('/register', userData);
    return response.data;
  } catch (error) {
    console.error('Register error:', error.response?.data || error.message);
    throw error;
  }
};

export const logoutUser = async () => {
  try {
    await laravelApiClient.post('/logout');
    localStorage.removeItem('authToken');
    localStorage.removeItem('user');
  } catch (error) {
    console.error('Logout error:', error.response?.data || error.message);
    # Even if logout fails on server, clear local storage
    localStorage.removeItem('authToken');
    localStorage.removeItem('user');
    throw error;
  }
};

export const getCurrentUser = async () => {
  try {
    const response = await laravelApiClient.get('/user');
    return response.data;
  } catch (error) {
    console.error('Fetch current user error:', error.response?.data || error.message);
    throw error;
  }
};
