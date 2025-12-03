import axios from 'axios';

const api = axios.create({
    baseURL: 'http://localhost:8000',
    withCredentials: true,
    headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
    }
});

// Request interceptor to add CSRF token
api.interceptors.request.use(async (config) => {
    // For GET requests, we don't need CSRF token
    if (config.method.toLowerCase() !== 'get') {
        try {
            // Get CSRF token from Laravel Sanctum
            await axios.get('http://localhost:8000/sanctum/csrf-cookie', {
                withCredentials: true
            });
            
            // The token is automatically set in the cookie by Laravel
            // Axios will send it automatically with withCredentials: true
        } catch (error) {
            console.error('Error fetching CSRF token:', error);
        }
    }
    return config;
});

export default api;