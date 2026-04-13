<script setup>
import Navbar from '@/components/navbar.vue';
import ToastPortal from '@/components/ToastPortal.vue';
import Footer from '@/components/footer.vue';
import { onMounted, provide, ref, onBeforeUnmount } from 'vue';
import { RouterView, useRouter } from 'vue-router';
import axios from 'axios';
import { useAuthStore } from '@/stores/auth'
import AppLoader from '@/components/AppLoader.vue'

const authStore = useAuthStore();
const router = useRouter();
const loggedIn = ref(false);
const user = ref(null); 
const appUrl = import.meta.env.VITE_APP_URL || 'http://localhost:5173'

const toast = ref(null)

provide('toast', {
  showToast: (...args) => toast.value?.showToast(...args),
  showErrorModal: (...args) => toast.value?.showErrorModal(...args),
})

// Email verifikáció kezelése
const handleVerifyMessage = async (event) => {
    if (event.origin !== appUrl) return
    if (event.data?.type === 'EMAIL_VERIFIED') {
        await authStore.fetchUser()
        const redirectTo = localStorage.getItem('redirect_after_verify')
        localStorage.removeItem('redirect_after_verify')
        if (redirectTo) router.push(redirectTo)
    }
}

// ── Csak a loggedIn provide-hoz kell, a checkAuth már lefutott main.js-ben ──
onMounted(async () => {
  try {
    await axios.get('/sanctum/csrf-cookie')
    loggedIn.value = authStore.isAuthenticated
  } catch {
    loggedIn.value = false
  }
})

onMounted(() => window.addEventListener('message', handleVerifyMessage))
onBeforeUnmount(() => window.removeEventListener('message', handleVerifyMessage))

provide('loggedIn', loggedIn);
provide('user', user);

</script>

<template>
  <div id="app">
    <Navbar></Navbar>
    <ToastPortal ref="toast" />
    <main class="main-content">
      <RouterView></RouterView>
      <div v-if="!authStore.authChecked" class="app-loader">
        <AppLoader />
      </div>
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
