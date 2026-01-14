<script setup>
import Navbar from '@/components/navbar.vue';
import Footer from '@/components/footer.vue';
import { onMounted, provide, ref, watch } from 'vue';
import { RouterView } from 'vue-router';
import axios from 'axios';

const loggedIn = ref(false);
onMounted(async () => {
  try {
    await axios.get('/sanctum/csrf-cookie');

    const response = await axios.get('/api/user/check', { withCredentials: true });
    if (response.data.loggedIn) {
      loggedIn.value = true;
    } else {
        loggedIn.value = false;
      }
  } catch (error) {
   loggedIn.value = false;
  }
  
});
/*>
watch(loggedIn, (newValue) => {;
});*/
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
