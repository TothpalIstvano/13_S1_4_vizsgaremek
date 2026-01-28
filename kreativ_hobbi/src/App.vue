<script setup>
import Navbar from '@/components/navbar.vue';
import Footer from '@/components/footer.vue';
import { onMounted, onUnmounted, provide, ref, watch } from 'vue';
import { RouterView } from 'vue-router';
import axios from 'axios';

const loggedIn = ref(false);
const user = ref(null);
onMounted(async () => {
  try {
    await axios.get('/sanctum/csrf-cookie');

    const response = await axios.get('/api/user/check', { withCredentials: true });
    if (response.data.loggedIn === true) {
      loggedIn.value = true;
    } else {
        loggedIn.value = false;
      }
  } catch (error) {
   loggedIn.value = false;
  }
});
onUnmounted(async () => {
    try {
    await axios.get('/sanctum/csrf-cookie');

    const response = await axios.get('/api/user/check', { withCredentials: true });
    if (response.data.loggedIn === true) {
      loggedIn.value = true;
      user.value = response.data.user;
    } else {
      loggedIn.value = false;
        user.value = null;
      }
  } catch (error) {
      loggedIn.value = false;
   user.value = null;
  }
});
/*>
watch(loggedIn, (newValue) => {;
});*/
provide('loggedIn', loggedIn);
provide('user', user);

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
