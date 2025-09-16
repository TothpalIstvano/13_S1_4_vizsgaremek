<script setup>
import Navbar from '@/components/navbar.vue';
import Footer from '@/components/footer.vue';
</script>

<template>
  <div>
    <Navbar />
    <main>
      <RouterView />
    </main>
    <Footer />
  </div>
</template>

<style>

</style>