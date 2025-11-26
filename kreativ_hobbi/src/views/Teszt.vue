<template>
  <div>Check console for auth test results</div>
</template>

<script setup>
import { onMounted } from 'vue';
import axios from 'axios';

// If backend runs on another origin, set baseURL to it; otherwise leave empty
axios.defaults.baseURL = 'http://127.0.0.1:8000';
axios.defaults.withCredentials = true; // critical: send cookies

onMounted(async () => {
  try {
    // 1. get CSRF cookie to establish the session
    await axios.get('/sanctum/csrf-cookie');

    // 2. Manually get the token from the cookie
    // This is a simple helper function to read a cookie by name
    const getCookie = (name) => {
      const value = `; ${document.cookie}`;
      console.log('value', value);
      const parts = value.split(`; ${name}=`);
      console.log('parts', parts);
      if (parts.length === 2) return parts.pop().split(';').shift();
    };

    const xsrfToken = getCookie('XSRF-TOKEN');
    console.log('xsrf token', xsrfToken);
    // 3. then login, manually setting the header
    const loginResp = await axios.post('/login', {
      email: 'test@example.com', // Make sure this user exists from your seeder
      password: 'password'       // Make sure this password is correct
    }, {
      headers: {
        // THIS IS THE CRITICAL CHANGE: We manually set the header
        'X-XSRF-TOKEN': xsrfToken
      }
    });

    console.log('login response', loginResp.data);

    // 4. now request protected api (cookies are sent)
    const response = await axios.get('/api/user');
    console.log('protected user', response.data);
  } catch (err) {
    console.error('Auth error', err.response?.status, err.response?.data || err);
  }
});
</script>