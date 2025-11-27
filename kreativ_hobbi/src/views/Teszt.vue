<template>
  <div v-if="alma">{{ alma }}</div>
</template>
<script setup>
import axios from 'axios';
import { ref, onMounted } from 'vue';

    let alma = ref("");

onMounted(async () => {
  try {


    axios.defaults.baseURL = 'http://localhost:8000';
    axios.defaults.withCredentials = true;
    
    axios.defaults.headers.common['X-CSRF-TOKEN'] = await axios.get('/sanctum/csrf-cookie').then(response => response.data.csrf_token);
    console.log(axios.defaults.headers.common['X-CSRF-TOKEN']);

    let response = await axios.get('api/teszt');
    console.log(response);
    alma.value = response.data;
  } catch (error) {
    console.error(error);
  }
});
</script>

