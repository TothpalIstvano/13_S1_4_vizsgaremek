<script setup>
import { RouterLink, RouterView, useRouter } from 'vue-router'
import logo_kalapacs from '@/components/icons/logo_kalapacs.png'
import logo_reszelo from '@/components/icons/logo_reszelo.png'
import { ref, onMounted, onUnmounted } from 'vue';

const router = useRouter();
const latszik = ref(false);
const logoKalapacs = logo_kalapacs
const logoReszelo = logo_reszelo
const xbeValtas = ref(false);
const navbarRef = ref(null)

function open() {
  if (window.innerWidth > 1200) {
      router.push('/');
  }
  else{ 
    latszik.value = !latszik.value;
    xbeValtas.value = !xbeValtas.value;
  }
}
function handleResize() {
  if (window.innerWidth > 1200 && latszik.value) {
    latszik.value = false;
    xbeValtas.value = false;
  }
}
// --- Add this function ---
function handleClickOutside(event) {
  if (
    latszik.value &&
    navbarRef.value &&
    !navbarRef.value.contains(event.target)
  ) {
    latszik.value = false;
    xbeValtas.value = false;
  }
}

onMounted(() => {
  window.addEventListener('resize', handleResize);
  document.addEventListener('mousedown', handleClickOutside);
});
onUnmounted(() => {
  window.removeEventListener('resize', handleResize);
  document.removeEventListener('mousedown', handleClickOutside);
});

</script>

<template>
  <div>
    <div id="felsoGap"></div>
    <header>
      <nav class="navbar" ref="navbarRef">
        <div id="nevDiv">
          <div id="logoDiv">
            <img
              alt="Placeholder"
              type="image/svg+xml"
              :src="logoReszelo"
              width="12"
              height="50"
              class="logo"
              id="reszelo"
              :style="latszik ? 'transform: rotate(45deg); left: 10px; right: 5px;' : ''"
              style="cursor: pointer;"
              @click=open();
            />
            <img  
              alt="Placeholder"
              type="image/png"
              :src="logoKalapacs"
              width="20"
              height="50"
              class="logo"
              id="kalapacs"
              :style="latszik ? 'transform: rotate(-45deg); left: -10px; rigth: 5px; ' : ''"
              style="cursor: pointer;"
              @click=open();
            />       
          </div>
            <RouterLink to="/" id="nev">
              <h1>Hobbitár</h1>
            </RouterLink>
        </div>
        <RouterLink 
          class="menu_link" 
          id="balraTolas" 
          to="/"
          :class="{ hamburgerElem: !latszik }"
        >Főoldal</RouterLink>

        <RouterLink 
          class="menu_link" 
          to="/aruhaz"
          :class="{ hamburgerElem: !latszik }"
        >Áruház</RouterLink>

        <RouterLink 
          class="menu_link"  
          to="/blog"
          :class="{ hamburgerElem: !latszik }"
        >Blog</RouterLink>

        <RouterLink 
          class="menu_link" 
          to="/mintakeszito"

          :class="{ hamburgerElem: !latszik }"
        >Mintakészítő</RouterLink> 


        <RouterLink 
          class="menu_link" 
          to="/rolunk"
          :class="{ hamburgerElem: !latszik }"
        >Rólunk</RouterLink>

        <RouterLink 
          class="vonal"  
          style="float: right;" 
          to="/kosar"
          :class="{ hamburgerElem: !latszik }"
          ><img
            alt="Kosár"
            class="kosarLogo"
            src="@/components/icons/Cart.png"
            width="50"
            height="50"
        /></RouterLink>

        <RouterLink 
          class="menu_link" 
          to="/belepes"
          :class="{ hamburgerElem: !latszik }"
        >Belépés</RouterLink>

      </nav>
    </header>
  </div>
</template>

<style scoped>
/* logo stílusa */
#logoDiv{
  display: flex;
  align-items: center;
  margin-left: 10rem;
  flex-direction: row;
  gap: 5px;
  transition: transform 0.7s;
}
.logo {
  /*color: #ff8a65;*/
  float: left;
  text-decoration: none;
  transition: transform 0.7s;
  cursor: pointer;
}

#reszelo{
  z-index: 2;
  position: relative; 
  left: 0px;
  right: 0px;
  
}
#kalapacs{
  z-index: 1;
  position: relative;
  left: 0px;
  right: 0px;
}

#nevDiv{
  display: flex;
  align-items: center;
  margin-left: 1rem;
  gap: 15px;
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
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 70px;
  padding: 10px;
  z-index: 1;
  box-shadow: 0px 10px 10px rgba(2, 2, 2, 0.274);
  border-bottom:2px solid #ff8a65;
}

#balraTolas{
  margin-left: auto;
}

.vonal{
  border-left: #ff8a65 2px solid;
  margin-left: 10px;
  padding-left: 10px;
  margin-right: 15px;
}
.menu_link {
  position: static;
  padding-bottom: 4px;
  text-decoration: none;
  color: #c68b59;
  margin: 0 10px;
}
.menu_link:last-child {
  margin-right: 10rem;
}
.menu_link::after {
  content: '';
  position: relative;
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
#felsoGap{
  height: 90px;
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
    height: auto;
  }
  #logoDiv {
    margin-left: 20px;
    margin-bottom: 10px;
    align-items: center;
    transform: rotate(90deg);
    float: left;
    position: static;
    left: auto;
  }
  .logo {
    float: none;
    margin-left: 0;
    display: flex;
  }
  .reszelo{
    transition: left 0.7s ease-in-out;
  }
  .kalapacs{ 
    transition: left 0.7s ease-in-out;
  }
  #nevDiv{
    display: flex;
    justify-content: space-between; /* This will push logo left and name right */
    align-items: center;
    width: 100%;
    margin-left: 0;
    padding: 0 20px; /* Add some padding on sides */
    position: relative;
  }
  #nev {
    margin-right: 52px;
    width: auto;
    text-align: center;
    margin-bottom: 0;
    float: none;    
    position: static;
    left: auto;
  }
  .menu_link.hamburgerElem, .vonal {
    float: none !important;
    margin: 0 0 10px 0;
    padding: 0;
    width: 100%;
    text-align: center;
    display: none;
  }
  .menu_link {
    font-size: 1.1rem;
  }
  .vonal {
    display: none !important;
  }
  #balraTolas{
    margin-left: 0;
    margin-right: 0;
  }
  #felsoGap{
    height: 160px;
  }
}
</style>

