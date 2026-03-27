<script setup>
import Navbar from '@/components/navbar.vue';
import Footer from '@/components/footer.vue';
import { onMounted, onUnmounted, provide, ref, onBeforeUnmount } from 'vue';
import { RouterView } from 'vue-router';
import axios from 'axios';
import { useAuthStore } from '@/stores/auth'

const loggedIn = ref(false);
const user = ref(null);


const authStore = useAuthStore()
const appUrl = import.meta.env.VITE_APP_URL || 'http://localhost:5173'

const handleVerifyMessage = async (event) => {
    if (event.origin !== appUrl) return
    if (event.data?.type === 'EMAIL_VERIFIED') {
        await authStore.fetchUser()
        const redirectTo = localStorage.getItem('redirect_after_verify')
        localStorage.removeItem('redirect_after_verify')
        if (redirectTo) router.push(redirectTo)
    }
}

onMounted(() => window.addEventListener('message', handleVerifyMessage))
onBeforeUnmount(() => window.removeEventListener('message', handleVerifyMessage))

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
  <div id="app">
    <Navbar></Navbar>
    <main class="main-content">
      <RouterView></RouterView>
    </main>
    <Footer></Footer>
  </div>
</template>

<style>
#app {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.main-content {
  flex: 1; 
}
</style>
