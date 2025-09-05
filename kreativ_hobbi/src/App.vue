<script setup>
import { RouterLink, RouterView } from 'vue-router'
</script>

<template>
  <header>
    <nav class="navbar">
      <embed
        alt="Placeholder"
        id="logo"
        type="image/svg+xml"
        src="https://duyn491kcolsw.cloudfront.net/files/1i/1i2/1i217j.svg?border=ffa184&outline=ff6433&color=ff8a65"
        width="50"
        height="50"
      />
      <h1 id="nev">Hobbitár</h1>
      <RouterLink :class="{ 'active-link': $route.path === '/' }"  to="/">Főoldal</RouterLink>
      <RouterLink :class="{ 'active-link': $route.path === '/aruhaz' }" to="/aruhaz">Áruház</RouterLink>
      <RouterLink :class="{ 'active-link': $route.path === '/blog' }"  to="/blog">Blog</RouterLink>
      <RouterLink :class="{ 'active-link': $route.path === '/mintakeszito' }" to="/mintakeszito">Mintakeszítő</RouterLink>  
      <RouterLink :class="{ 'active-link': $route.path === '/rolunk' }" to="/rolunk">Rólunk</RouterLink>
      <RouterLink :class="{ 'active-link': $route.path === '/kosar' }" style="float: right;" to="/kosar" class="vonal"
        ><img
          alt="Kosár"
          class="kosarLogo"
          src="@/components/icons/kosar.svg"
          width="30"
          height="30"
      /></RouterLink>
      <RouterLink :class="{ 'active-link': $route.path === '/belepes' }" to="/belepes">Belépés</RouterLink>
    </nav>
  </header>

  <RouterView />
</template>

<style scoped>
/* logo stílusa */
#logo {
  /*color: #ff8a65;*/
  float: left;
  margin-left: 5%;

}
#nev {
  float: left;
  color: #ff8a65;
  margin-right: 57%;
}

/* Naviágációs menű stílusa */
.navbar {
  display: flex;
  align-items: center;
  background-color: #7a402d;
  position:fixed;
  top: 0;
  left: 0;
  width: 100%;
  padding: 10px;
  
}
.navbar a {
  color: #c68b59;
  text-decoration: none;
  margin: 0 10px;
}
.navbar a:hover {

}
.vonal{
  border-left: #ff8a65 2px solid;
  padding-left: 10px;
  margin-left: 10px;
}
.active-link {
  position: relative;
  padding-bottom: 4px;
  font-weight: bold;
}
</style>
