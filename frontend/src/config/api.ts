// API configuration
// When using Vite proxy, the API_BASE_URL should be empty (proxied)
// When connecting directly (production), set VITE_API_BASE_URL env variable
export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '';
export const API_PREFIX = '/api/v1';

export const getApiUrl = (endpoint: string) => {
  return `${API_BASE_URL}${API_PREFIX}${endpoint}`;
};
