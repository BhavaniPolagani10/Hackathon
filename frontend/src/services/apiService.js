// API service for communicating with the backend
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

/**
 * Make an API request to the backend
 */
const apiRequest = async (endpoint, options = {}) => {
  const url = `${API_URL}${endpoint}`;
  
  const defaultOptions = {
    headers: {
      'Content-Type': 'application/json',
    },
  };
  
  const mergedOptions = {
    ...defaultOptions,
    ...options,
    headers: {
      ...defaultOptions.headers,
      ...options.headers,
    },
  };
  
  const response = await fetch(url, mergedOptions);
  const data = await response.json();
  
  if (!response.ok) {
    throw new Error(data.error || 'API request failed');
  }
  
  return data;
};

/**
 * Register user in backend after Firebase registration
 */
export const registerUserInBackend = async (firebaseUid, email, firstName = '', lastName = '') => {
  return apiRequest('/api/auth/register', {
    method: 'POST',
    body: JSON.stringify({
      firebase_uid: firebaseUid,
      email: email,
      first_name: firstName,
      last_name: lastName,
    }),
  });
};

/**
 * Sync user login with backend
 */
export const syncUserLogin = async (firebaseUid) => {
  return apiRequest('/api/auth/login', {
    method: 'POST',
    body: JSON.stringify({
      firebase_uid: firebaseUid,
    }),
  });
};

/**
 * Get user profile from backend
 */
export const getUserProfile = async (firebaseUid) => {
  return apiRequest(`/api/auth/profile?firebase_uid=${firebaseUid}`);
};

/**
 * Update user profile in backend
 */
export const updateUserProfile = async (firebaseUid, profileData) => {
  return apiRequest('/api/auth/profile', {
    method: 'PUT',
    body: JSON.stringify({
      firebase_uid: firebaseUid,
      ...profileData,
    }),
  });
};

/**
 * Check API health
 */
export const checkApiHealth = async () => {
  return apiRequest('/api/health');
};

export default {
  registerUserInBackend,
  syncUserLogin,
  getUserProfile,
  updateUserProfile,
  checkApiHealth,
};
