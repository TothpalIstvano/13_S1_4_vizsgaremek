<script setup>
import { RouterLink, RouterView } from 'vue-router'
import Kosar from './views/Kosar.vue';
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
      <RouterLink class="menu_link"  to="/">Főoldal</RouterLink>
      <RouterLink class="menu_link" to="/aruhaz">Áruház</RouterLink>
      <RouterLink class="menu_link"  to="/blog">Blog</RouterLink>
      <RouterLink class="menu_link" to="/mintakeszito">Mintakeszítő</RouterLink>  
      <RouterLink class="menu_link" to="/rolunk">Rólunk</RouterLink>
      <RouterLink class="vonal" id="kocsi" style="float: right;" to="/kosar" onclick="changePic()"
        ><img
          alt="Kosár"
          class="kosarLogo"
          src="@/components/icons/cart.svg"
          width="50"
          height="50"
      /></RouterLink>
      <RouterLink class="menu_link" to="/belepes">Belépés</RouterLink>
    </nav>
  </header>
  <main>
    <RouterView />
  </main>
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
  margin-right: 55%;
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
.vonal{
  border-left: #ff8a65 2px solid;
  margin-left: 10px;
  padding-left: 10px;
  margin-right: 15px;
}
#kocsi{
  
}
.menu_link {
  position: relative;
  padding-bottom: 4px;
  text-decoration: none;
  color: #c68b59;
  margin: 0 10px;
}
.menu_link::after {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  width: 0;
  height: 2px;
  background-color: #ff8a65;
  transition: all 0.3s ease-in-out;
}
.menu_link.router-link-exact-active::after {
  width: 100%;
  left: 0;
}
.menu_link.router-link-exact-active {
  color: #ff8a65;
  font-weight: 600;
}

/* Reszponzív nav bar */
@media (max-width: 900px) {
  .navbar {
    flex-wrap: wrap;
    justify-content: center;
  }
  
  #nev {
    margin-right: 0;
    width: 100%;
    text-align: center;
    margin-bottom: 10px;
  }
}

</style>
