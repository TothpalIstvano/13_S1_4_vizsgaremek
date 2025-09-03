<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <header>
    <div>
      <nav class="navbar">
        <embed
          alt="Placeholder"
          class="logo"
          type="image/svg+xml"
          src="https://duyn491kcolsw.cloudfront.net/files/1i/1i2/1i217j.svg?border=ffa184&outline=ff6433&color=ff8a65"
          width="50"
          height="50"
        />
        <RouterLink to="/">Főoldal</RouterLink>
        <RouterLink to="/aruhaz">Áruház</RouterLink>
        <RouterLink to="/blog">Blog</RouterLink>
        <RouterLink to="/mintakeszito">Mintakeszítő</RouterLink>
        <RouterLink to="/rolunk">Rólunk</RouterLink>
        <RouterLink to="/kosar"
          ><img
            alt="Kosár"
            class="kosarLogo"
            src="@/components/icons/kosar.svg"
            width="30"
            height="30"
        /></RouterLink>
        <RouterLink to="/belepes">Belépés</RouterLink>
      </nav>
    </div>
  </header>

  <RouterView />
</template>

<style scoped>
.navbar {
  display: flex;
  align-items: center;
  background-color: #7a402d;
  padding: 10px;
}
.navbar a {
  color: #c68b59;
  text-decoration: none;
  margin: 0 10px;
}
.logo {
  color: #ff8a65;
  border-top-color: rgb(255, 161, 132);
  border-right-color: rgb(255, 161, 132);
  border-bottom-color: rgb(255, 161, 132);
  border-left-color: rgb(255, 161, 132);
}
</style>
