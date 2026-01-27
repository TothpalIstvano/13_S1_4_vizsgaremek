<script setup>
import { RouterLink, useRouter } from 'vue-router'
import logo_kalapacs from '@/components/icons/logo_kalapacs.png'
import logo_reszelo from '@/components/icons/logo_reszelo.png'
import { ref, onMounted, onUnmounted, inject } from 'vue';
import axios from 'axios';

const router = useRouter();
const latszik = ref(false);
const logoKalapacs = logo_kalapacs
const logoReszelo = logo_reszelo
const xbeValtas = ref(false);
const navbarRef = ref(null)
const userPath = ref('/Belepes');
const isLoggedIn = ref('Bejelentkezés');
const logged = inject('loggedIn');

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


//response limitálása
async function checkUser() {
  try {
    const response = await axios.get('/api/user', { withCredentials: true });

    console.log("Navbar user:", response.data);
    const baseUrl = import.meta.env.VITE_API_URL;
    const hasProfileImage = response.data.profilKep_id;

    if (response.data && hasProfileImage) {
      console.log('Has profile image:', response.data);
      userPath.value = '/Profil';
      isLoggedIn.value = `${baseUrl}/storage/profilKepek/kep_${hasProfileImage}.jpg`;
      
    } 
    else if (response.data) {
      userPath.value = '/Profil';
      isLoggedIn.value = `${baseUrl}/storage/profilKepek/default.jpg`;
    } 
    else {
      userPath.value = '/Belepes';
      isLoggedIn.value = 'Bejelentkezés';
    }
  } catch (error) {
    console.error('Error checking user:', error);
    userPath.value = '/Belepes';
    isLoggedIn.value = 'Bejelentkezés';
  }
}

onMounted(() => {
  //if (logged.value) {
    checkUser();
  //}
  window.addEventListener('user-logged-in', checkUser);
  window.addEventListener('resize', handleResize);
  document.addEventListener('mousedown', handleClickOutside); 
});
onUnmounted(() => { 
  window.removeEventListener('user-logged-in', checkUser);
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
          :class="{ hamburgerElem: !latszik }"
          :to="userPath"
        ><p v-if="isLoggedIn === 'Bejelentkezés'">{{ isLoggedIn }}</p> <img id="profilkep" v-else :src="isLoggedIn" /></RouterLink>

      </nav>
    </header>
  </div>
</template>

<style scoped>
/*#region logo stílusa */
#logoDiv{
  display: flex;
  align-items: center;
  margin-left: 10rem;
  flex-direction: row;
  gap: 5px;
  transition: transform 0.7s;
}
.logo {
  /*color: var(--router-link-color);*/
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
  color: var(--router-link-color);
  text-decoration: none;
}
/*#endregion*/

/*#region Naviágációs menű stílusa */
.navbar {
  display: flex;
  align-items: center;
  background-color: var(--navbar-bg);
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 70px;
  padding: 43px 10px;
  z-index: 10;
  box-shadow: var(--shadow);
  border-bottom:2px solid var(--router-link-color);
}

#balraTolas{
  margin-left: auto;
}

.vonal{
  border-left: var(--router-link-color) 2px solid;
  margin-left: 10px;
  padding-left: 10px;
  margin-right: 15px;
}
.menu_link {
  position: relative;
  padding-bottom: 4px;
  text-decoration: none;
  color: var(--router-link-muted-color);
  margin: 0 10px; 
  transition: color 0.3s, border-bottom 0.3s;
  border-bottom: 0px solid transparent;
}

.menu_link.router-link-exact-active {
  color: var(--router-link-color);
  border-bottom: 2px solid var(--router-link-color);
}
.menu_link:hover {
  color: var(--router-link-hover-color);
  transition: color 0.4s;
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
  background-color: var(--router-link-color);
}
.menu_link.router-link-exact-active::after {
  width: 100%;
  left: 0;
}
.menu_link.router-link-exact-active {
  color: var(--router-link-color);
  font-weight: 600;
  border-bottom: 2px solid var(--router-link-color);
  transition: border-color 0.5s;
}
#felsoGap{
  height: 90px;
}

#profilkep{
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  position: relative;
  top: 5px;
}
/*#endregion*/

/*#region Reszponzív nav bar + hamburger menü */
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
  .menu_link:last-child {
    margin-right: 10px;
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
/*#endregion*/
</style>

