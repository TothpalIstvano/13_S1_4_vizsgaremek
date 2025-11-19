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
    // get CSRF cookie
    await axios.get('/sanctum/csrf-cookie');

    // then login (cookies and XSRF header will be handled automatically)
    const loginResp = await axios.post('/login', {
      email: 'teszt@user.hu',
      password: 'titkos'
    });

    console.log('login response', loginResp.data);

    // now request protected api (cookies are sent)
    const response = await axios.get('/api/user');
    console.log('protected user', response.data);
  } catch (err) {
    console.error('Auth error', err.response?.status, err.response?.data || err);
  }
});
</script>