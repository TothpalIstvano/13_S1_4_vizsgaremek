<script setup>
import { RouterLink, RouterView, useRouter } from 'vue-router'
import hamburger from '@/components/icons/hamburger_menu.png'
import logo from '@/components/icons/logo.png'
import { ref, onMounted, onUnmounted } from 'vue';

const router = useRouter();
const latszik = ref(false);
const nyitva = hamburger
const zart = logo
function open() {
  if (window.innerWidth > 1200) {
      router.push('/');
  }
  else{ 
    latszik.value = !latszik.value;
  }
}
function handleResize() {
  if (window.innerWidth > 1200 && latszik.value) {
    latszik.value = false;
  }
}
onMounted(() => {
  window.addEventListener('resize', handleResize);
});
onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
});

</script>

<template>
  <div>
    <header>
      <nav class="navbar">
        <img
          alt="Placeholder"
          type="image/svg+xml"
          :src="latszik ? nyitva : zart"
          width="50"
          height="50"
          id="logo"
          style="cursor: pointer;"
          @click=open();
        />
        <RouterLink to="/" id="nev">
        <h1>Hobbitár</h1>
        </RouterLink>

        <RouterLink 
          class="menu_link" 
          id="balraTolas" 
          to="/"
          :class="{ hamburgerElem: latszik }"
        >Főoldal</RouterLink>
        <RouterLink 
          class="menu_link" 
          to="/aruhaz"
          :class="{ hamburgerElem: latszik }"
        >Áruház</RouterLink>
        <RouterLink 
          class="menu_link"  
          to="/blog"
          :class="{ hamburgerElem: latszik }"
        >Blog</RouterLink>
        <RouterLink 
          class="menu_link" 
          to="/mintakeszito"
          :class="{ hamburgerElem: latszik }"
        >Mintakeszítő</RouterLink>  
        <RouterLink 
          class="menu_link" 
          to="/rolunk"
          :class="{ hamburgerElem: latszik }"
        >Rólunk</RouterLink>
        <RouterLink 
          class="vonal"  
          style="float: right;" 
          to="/kosar"
          :class="{ hamburgerElem: latszik }"
          ><img
            alt="Kosár"
            class="kosarLogo"
            src="@/components/icons/cart.svg"
            width="50"
            height="50"
        /></RouterLink>
        <RouterLink 
          class="menu_link" 
          to="/belepes"
          :class="{ hamburgerElem: latszik }"
        >Belépés</RouterLink>

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
  transition: transform 0.7s;
}
.logo-fade-enter-active, .logo-fade-leave-active {
  transition: opacity 0.4s;
}
.logo-fade-enter-from, .logo-fade-leave-to {
  opacity: 0;
}
.logo-fade-enter-to, .logo-fade-leave-from {
  opacity: 1;
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

/* Reszponzív nav bar + hamburger menü */
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
    display: flex;
    transform: rotate(90deg);
  }
  #nev {
    margin-right: 0;
    width: 100%;
    text-align: center;
    margin-bottom: 10px;
    float: none;
  }
  .menu_link.hamburgerElem, .vonal {
    float: none !important;
    margin: 0 0 10px 0;
    padding: 0;
    width: 100%;
    text-align: center;
    display: none;

  }
  .vonal {
    display: none !important;
  }
  #balraTolas{
    margin-left: 0;
  }
}
</style>
