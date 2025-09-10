<script setup>
import { RouterLink, RouterView } from 'vue-router'
import Kosar from './views/Kosar.vue';
</script>

<template>
  <div>
    <header>
      <nav class="navbar">
        <RouterLink to="/" id="logo">
        <embed
          alt="Placeholder"
          type="image/svg+xml"
          src="https://duyn491kcolsw.cloudfront.net/files/1i/1i2/1i217j.svg?border=ffa184&outline=ff6433&color=ff8a65"
          width="50"
          height="50"
          style="pointer-events:all;"
        />
        </RouterLink>
        <RouterLink to="/" id="nev">
        <h1>Hobbitár</h1>
        </RouterLink>

        <RouterLink class="menu_link" id="balraTolas" to="/">Főoldal</RouterLink>
        <RouterLink class="menu_link" to="/aruhaz">Áruház</RouterLink>
        <RouterLink class="menu_link"  to="/blog">Blog</RouterLink>
        <RouterLink class="menu_link" to="/mintakeszito">Mintakeszítő</RouterLink>  
        <RouterLink class="menu_link" to="/rolunk">Rólunk</RouterLink>
        <RouterLink class="vonal"  style="float: right;" to="/kosar"
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
  </div>
</template>

<style scoped>
/* logo stílusa */
#logo {
  /*color: #ff8a65;*/
  float: left;
  margin-left: 10rem;
  text-decoration: none;

}
#nev {
  float: left;
  color: #ff8a65;
  text-decoration: none;
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

#balraTolas{
  margin-left: 50rem;
}

.vonal{
  border-left: #ff8a65 2px solid;
  margin-left: 10px;
  padding-left: 10px;
  margin-right: 15px;
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
@media (max-width: 1200px) {
  .navbar {
    flex-direction: column;
    align-items: center;
    flex-wrap: wrap;
    justify-content: center;
    gap: 10px;
    padding: 10px 0;
  }
  #logo {
    float: none;
    margin-left: 0;
    margin-bottom: 10px;
    justify-content: center;
    display: flex;
  }
  #nev {
    margin-right: 0;
    width: 100%;
    text-align: center;
    margin-bottom: 10px;
    float: none;
  }
  .menu_link, .vonal, #kocsi {
    float: none !important;
    margin: 0 0 10px 0;
    padding: 0;
    width: 100%;
    text-align: center;
    display: block;
  }
  .vonal {
    display: none !important;
  }
  #balraTolas{
    margin-left: 0;
  }
}
</style>
