<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
const response = await axios.get(`${import.meta.env.VITE_API_URL}/api/posts`);

// A reactive variable to store our posts
const posts = ref([]);

// A function to fetch data from the API
const fetchPosts = async () => {
  try {
    // The URL of your Laravel API endpoint
    const response = await axios.get('http://localhost:8000/api/posts');
    posts.value = response.data;
  } catch (error) {
    console.error("Error fetching posts:", error);
  }
};

// The onMounted hook runs when the component is first displayed
onMounted(() => {
  fetchPosts();
});
</script>

<template>
  <div class="container">
    <h1>Kreativ Hobbi Posztok</h1>
    <div v-if="posts.length > 0" class="post-list">
      <div v-for="post in posts" :key="post.id" class="post-item">
        <h2>{{ post.cim }}</h2>
        <p><strong>Szerző:</strong> {{ post.szerzo ? post.szerzo.felhasz_nev : 'Ismeretlen' }}</p>
        <p>{{ post.kivonat }}</p>
        <!-- You can display the image later if you have the URL -->
      </div>
    </div>
    <div v-else>
      <p>Posztok betöltése...</p>
    </div>
  </div>
</template>

<style scoped>
  .container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
    font-family: sans-serif;
  }
  .post-item {
    border: 1px solid #ccc;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 16px;
    background-color: #f9f9f9;
  }
  h1 {
    text-align: center;
    color: #333;
  }
  h2 {
    color: #007bff;
  }
</style>