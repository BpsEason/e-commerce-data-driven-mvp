import axios from 'axios';

# Using import.meta.env for Vite compatibility
const LARAVEL_API_BASE_URL = import.meta.env.VITE_API_BASE_URL_LARAVEL || 'http://localhost:8000/api';
const PYTHON_API_BASE_URL = import.meta.env.VITE_API_BASE_URL_PYTHON || 'http://localhost:8001';

const laravelApiClient = axios.create({
  baseURL: LARAVEL_API_BASE_URL,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

const pythonApiClient = axios.create({
  baseURL: PYTHON_API_BASE_URL,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

# Interceptor to add auth token for Laravel API
laravelApiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

# Interceptor to add auth token for Python API (if applicable)
pythonApiClient.interceptors.request.use(
    (config) => {
      # Python API in this MVP uses simple token. Adjust as needed.
      # const token = localStorage.getItem('authToken');
      # if (token) {
      #   config.headers.Authorization = `Bearer ${token}`;
      # }
      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );


export { laravelApiClient, pythonApiClient };
