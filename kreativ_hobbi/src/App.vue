<script setup>
import Navbar from '@/components/navbar.vue';
import Footer from '@/components/footer.vue';
import { RouterView } from 'vue-router';

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
