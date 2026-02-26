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

const getCookie = (name) => {
    const match = document.cookie
        .split('; ')
        .find(row => row.startsWith(name + '='));
    return match ? decodeURIComponent(match.split('=')[1]) : null;
};

api.interceptors.request.use(async (config) => {
    if (config.method.toLowerCase() !== 'get') {
        try {
            // Only fetch if we don't already have the cookie
            if (!getCookie('XSRF-TOKEN')) {
                await axios.get('http://localhost:8000/sanctum/csrf-cookie', {
                    withCredentials: true
                });
            }

            // Explicitly set the token as a header — Axios doesn't always do this automatically
            const token = getCookie('XSRF-TOKEN');
            if (token) {
                config.headers['X-XSRF-TOKEN'] = token;
            }
        } catch (error) {
            console.error('Error fetching CSRF token:', error);
        }
    }
    return config;
});

export default api;