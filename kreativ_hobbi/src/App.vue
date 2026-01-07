<script setup>
import Navbar from '@/components/navbar.vue';
import Footer from '@/components/footer.vue';
import { onMounted, provide, ref } from 'vue';
import { RouterView } from 'vue-router';
import axios from 'axios';

const loggedIn = ref(false);

onMounted(async () => {
  try {
    await axios.get('/sanctum/csrf-cookie');

    const response = await axios.get('/api/user/check', { withCredentials: true });
    console.log(response);
    if (response.data.loggedIn) {
      loggedIn.value = true;
       window.dispatchEvent(new Event('user-logged-in'));
    } else {
        loggedIn.value = false;
      }
  } catch (error) {
    console.error('Error during initial user check:', error);
  }
});

provide('loggedIn', loggedIn);
</script>

<template>
  <div>
    <Navbar></Navbar>
    <main>
      <RouterView></RouterView>
    </main>
    <Footer></Footer>
  </div>
</template>

<style>

</style>
