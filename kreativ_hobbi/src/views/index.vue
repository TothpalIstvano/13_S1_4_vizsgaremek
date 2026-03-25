<script setup>
//imports
import Carousel from '@/components/carousel.vue';
import { ref, onMounted, onUnmounted, watch } from 'vue';
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCalendar, faHeart, faArrowRight, faArrowCircleUp, faThumbsUp, faThumbsDown} from '@fortawesome/free-solid-svg-icons'

library.add(faCalendar, faHeart, faArrowRight, faArrowCircleUp, faThumbsUp, faThumbsDown)

//variables
const featureTitleRef = ref(null);
const isInView = ref(false);
const isHeroVisible = ref(true);
let io = null;
const baseURL = import.meta.env.VITE_API_URL;
const blogPosts = ref([]);

onMounted(async () => {
  blogPosts.value = await fetchBlogPosts();
});

onMounted( () => {
  io = new IntersectionObserver(
    ([entry]) => {
      // play animation when at least 50% visible; change threshold as needed
      isInView.value = entry.isIntersecting;
      // if you want the animation to run only once, uncomment:
      if (entry.isIntersecting) io.unobserve(entry.target);
    },
    { threshold: 1 } // 100% visible
  );
  if (featureTitleRef.value) io.observe(featureTitleRef.value);

  const heroEl = document.querySelector('.hero-banner');
    if (heroEl) {
      const heroObserver = new IntersectionObserver(
        ([entry]) => {
          isHeroVisible.value = entry.isIntersecting;
          const navbar = document.querySelector('.navbar');
          if (navbar) {
            if (entry.isIntersecting) {
              navbar.classList.add('hero-mode');
            } else {
              navbar.classList.remove('hero-mode');
            }
          }
        },
        { threshold: 0 }
      );
      heroObserver.observe(heroEl);
    }
});

onUnmounted(() => {
  if (io) io.disconnect();
});


// blog data
async function fetchBlogPosts() {
  try {
    const response = await fetch(`${baseURL}/api/blog/main`);
    if (!response.ok) {
      throw new Error('Hiba a blogposztok lekérése során');
    }
    const data = await response.json();
    console.log('Fetched blog posts:', data);
    return data;
  } catch (error) {
    console.error('Error fetching blog posts:', error);
  }
}

function formatDate(dateString) {
  const datePart = dateString.split('T')[0]; 
  const [year, month, day] = datePart.split('-'); // ["2026", "01", "21"]
  const formattedDate = `${day} ${month} ${year}`;

  return formattedDate;
}

</script>

<template>
  <main>

    <!-- Hero Banner Section -->
    <section class="hero-banner">
      <div class="hero-overlay"></div>
      <div class="hero-content">
        <div class="hero-text">
          <h1 class="hero-title">
            <span class="hero-title-line">Kreatív</span>
            <span class="hero-title-line highlight">Alkotás</span>
            <span class="hero-title-line">Minden nap</span>
          </h1>
          <p class="hero-subtitle">
            Fedezd fel a kreatív lehetőségeket prémium alapanyagokkal, 
            szakértő útmutatásokkal és egy támogató közösséggel.
          </p>
          <div class="hero-buttons">
            <router-link to="/aruhaz" class="hero-btn primary">
              <span>Vásárlás</span>
              <svg class="btn-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </router-link>
            <router-link to="/mintakeszito" class="hero-btn secondary">
              <span>Mintakészítő</span>
              <svg class="btn-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                <line x1="9" y1="9" x2="15" y2="9"></line>
                <line x1="9" y1="15" x2="15" y2="15"></line>
              </svg>
            </router-link>
          </div>
        </div>
        <div class="hero-image">
          <div class="floating-card card-1">
            <div class="card-image">
              <img src="https://picsum.photos/seed/craft1/200/150" alt="Kötés" />
            </div>
            <div class="card-content">
              <h4>Kötés</h4>
              <p>Minőségi fonalak</p>
            </div>
          </div>
          <div class="floating-card card-2">
            <div class="card-image">
              <img src="https://picsum.photos/seed/craft2/200/150" alt="Horgolás" />
            </div>
            <div class="card-content">
              <h4>Horgolás</h4>
              <p>Kreatív ötletek</p>
            </div>
          </div>
          <div class="floating-card card-3">
            <div class="card-image">
              <img src="https://picsum.photos/seed/craft3/200/150" alt="Hímzés" />
            </div>
            <div class="card-content">
              <h4>Hímzés</h4>
              <p>Szép minták</p>
            </div>
          </div>
        </div>
      </div>
      <div class="scroll-indicator">
        <span>Görgess le a továbbiakért</span>
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M7 10l5 5 5-5"/>
        </svg>
      </div>
    </section>
    
    <div id="mottoContainer">
      <div class="mottoInner">
        <h1>Webáruházunk vmije</h1>
        <p>
          "Lorem ipsum dolor sit amet consectetur adipisicing elit. Magnam rerum beatae sunt, laboriosam minima nam sapiente reprehenderit quisquam repellat asperiores minus quis, fuga natus ipsum ipsam quod molestiae corporis incidunt!
          Lorem ipsum dolor sit amet consectetur adipisicing elit. Quisquam, natus.LOREM ipsum dolor sit amet consectetur adipisicing elit."
        </p>
      </div>
    </div>

    <carousel></carousel>

    <!-- add ref, tabindex so it can receive keyboard focus, and class binding -->
    <section class="features-wrapper">
      <div class="features-header">
        <p class="features-subtitle">Előnyeink</p>
        <h1
          id="featureTitle"
          ref="featureTitleRef"
          tabindex="0"
          :class="{ 'in-view': isInView }"
        >
          Miért válassz <span>minket?</span>
        </h1>
        <div class="features-divider">
          <div class="divider-line"></div>
          <div class="divider-dot"></div>
          <div class="divider-line"></div>
        </div>
      </div>

      <section class="feature-section">
        <div class="feature-grid">

          <router-link
            class="feature-link"
            to="/mintakeszito"
            :class="{ 'in-view': isInView }"
            style="--delay: 0.1s"
          >
            <article class="feature-card">
              <span class="feature-number">01</span>
              <div class="feature-icon-wrapper">
                <div class="feature-icon-bg"></div>
                <div class="feature-icon" aria-hidden="true">🎨</div>
              </div>
              <h3 class="feature-title">Mintakészítő</h3>
              <p class="feature-desc">
                Készíts személyre szabott mintákat saját képeid alapján.
                Kötés, horgolás és hímzés egy helyen.
              </p>
              <div class="feature-arrow">→</div>
            </article>
          </router-link>

          <router-link
            class="feature-link"
            to="/aruhaz"
            :class="{ 'in-view': isInView }"
            style="--delay: 0.2s"
          >
            <article class="feature-card">
              <span class="feature-number">02</span>
              <div class="feature-icon-wrapper">
                <div class="feature-icon-bg"></div>
                <div class="feature-icon" aria-hidden="true">📦</div>
              </div>
              <h3 class="feature-title">Minőségi termékek</h3>
              <p class="feature-desc">
                Prémium alapanyagok és eszközök a legszebb alkotásokhoz.
                Raktárról, gyors szállítással.
              </p>
              <div class="feature-arrow">→</div>
            </article>
          </router-link>

          <router-link
            class="feature-link"
            to="/blog"
            :class="{ 'in-view': isInView }"
            style="--delay: 0.3s"
          >
            <article class="feature-card">
              <span class="feature-number">03</span>
              <div class="feature-icon-wrapper">
                <div class="feature-icon-bg"></div>
                <div class="feature-icon" aria-hidden="true">📚</div>
              </div>
              <h3 class="feature-title">Blog és közösség</h3>
              <p class="feature-desc">
                Oszd meg tapasztalataidat, tanulj másoktól és inspirálódj
                a közösségünk által.
              </p>
              <div class="feature-arrow">→</div>
            </article>
          </router-link>

          <router-link
            class="feature-link"
            to="/rolunk"
            :class="{ 'in-view': isInView }"
            style="--delay: 0.4s"
          >
            <article class="feature-card">
              <span class="feature-number">04</span>
              <div class="feature-icon-wrapper">
                <div class="feature-icon-bg"></div>
                <div class="feature-icon" aria-hidden="true">👥</div>
              </div>
              <h3 class="feature-title">Szakértő segítség</h3>
              <p class="feature-desc">
                Tapasztalt kézművesek állnak rendelkezésedre, hogy
                segítsenek a projektjeidben.
              </p>
              <div class="feature-arrow">→</div>
            </article>
          </router-link>

          <router-link
            class="feature-link"
            to="/"
            :class="{ 'in-view': isInView }"
            style="--delay: 0.5s"
          >
            <article class="feature-card">
              <span class="feature-number">05</span>
              <div class="feature-icon-wrapper">
                <div class="feature-icon-bg"></div>
                <div class="feature-icon" aria-hidden="true">⭐</div>
              </div>
              <h3 class="feature-title">Elégedettség garancia</h3>
              <p class="feature-desc">
                Ha nem vagy elégedett a termékkel, 30 napon belül
                visszaküldheted.
              </p>
              <div class="feature-arrow">→</div>
            </article>
          </router-link>

          <router-link
            class="feature-link"
            to="/"
            :class="{ 'in-view': isInView }"
            style="--delay: 0.6s"
          >
            <article class="feature-card">
              <span class="feature-number">06</span>
              <div class="feature-icon-wrapper">
                <div class="feature-icon-bg"></div>
                <div class="feature-icon" aria-hidden="true">🚚</div>
              </div>
              <h3 class="feature-title">Gyors szállítás</h3>
              <p class="feature-desc">
                Rendeléseket 2–3 munkanapon belül házhoz szállítjuk
                országszerte.
              </p>
              <div class="feature-arrow">→</div>
            </article>
          </router-link>

        </div>
      </section>
    </section>

    
    <div class="blog-main-title-container">
      <h2 class="blog-main-title">A hét kiemelt blogposztjai</h2>
    </div>
    <div class="content-wrapper">
      <section class="cards-wrapper">
        <div class="card-grid-space" v-for="n in blogPosts" :key="n">
          <div class="card">
            <div class="card-glow"></div>
            <div class="card-img-holder">
              <img 
                :src="n.fo_kep.url_Link" 
                :alt="n.cim"
                @error="handleImageError"
                loading="lazy"
              />
            </div>
                
            <div class="card-content">
              <div class="meta-info">
                <span class="blog-time"> 
                  <div class="icon-wrapper">
                    <font-awesome-icon icon="fa-solid fa-calendar"/> 
                  </div>
                  {{ formatDate(n.letrehozas_datuma) }}
                </span>
              </div>

              <div class="card-header">
                <h3 class="blog-title">{{ n.cim }}</h3>
              </div>

              <p class="description">
                {{ n.kivonat || 'Nincs leírás' }}
                <span v-if="(n.kivonat || n.tartalom)?.length > 150">...</span>
              </p>
                  
              <div class="tags">
                <div class="tag" v-for="cimke in n.cimkek" :key="cimke.id">
                  <span class="tag-hash">#</span>{{ cimke.nev }}
                </div>
              </div>
                  
              <div class="card-footer">
                <button class="view-btn" @click="navigateToBlog(n.id)">
                  <span>Megtekintés</span>
                  <div class="arrow-icon">
                        <font-awesome-icon icon="fa-solid fa-arrow-right"/>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>

  </main>
</template>

<style scoped>
/*#region Imports*/
@import url('https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css?family=Heebo:400,700|Open+Sans:400,700');
/*#endregion*/

/*#region Hero Banner*/
.hero-banner {
  position: relative;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #ff8a65b8 0%, #632a17cf 100%);
  overflow: hidden;
}

.hero-banner::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: url('https://texturelabs.org/wp-content/uploads/Texturelabs_Fabric_155thumbnail.jpg');
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
  opacity: 0.2;
  z-index: 0;
}

.hero-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, 
    #ff8a655c 0%, 
    #33100466 100%);
  z-index: 1;
}

.hero-content {
  position: relative;
  z-index: 2;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 60px;
  max-width: 1200px;
  width: 100%;
  padding: 0 40px;
  align-items: center;
}

.hero-text {
  animation: slideInLeft 1s ease-out;
}

.hero-title {
  font-size: clamp(3rem, 8vw, 5rem);
  font-weight: 800;
  line-height: 1.1;
  margin-bottom: 24px;
  color: white;
  text-transform: uppercase;
  letter-spacing: -2px;
}

.hero-title-line {
  display: block;
  opacity: 0;
  animation: fadeInUp 0.8s ease-out forwards;
}

.hero-title-line:nth-child(1) { animation-delay: 0.1s; }
.hero-title-line:nth-child(2) { animation-delay: 0.3s; }
.hero-title-line:nth-child(3) { animation-delay: 0.5s; }

.hero-title-line.highlight {
  display: inline-block;
  background: linear-gradient(90deg, #6f3826 52.5%, #f9b798 48.5%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: 1.25rem;
  line-height: 1.6;
  color: rgba(255, 255, 255, 0.9);
  margin-bottom: 40px;
  max-width: 500px;
  animation: fadeInUp 1s ease-out 0.7s forwards;
  opacity: 0;
}

.hero-buttons {
  display: flex;
  gap: 20px;
  animation: fadeInUp 1s ease-out 0.9s forwards;
  opacity: 0;
}

.hero-btn {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 16px 32px;
  border-radius: 50px;
  font-size: 1.1rem;
  font-weight: 600;
  text-decoration: none;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
  overflow: hidden;
}

.hero-btn.primary {
  background: white;
  color: #a2644b;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.hero-btn.primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
}

.hero-btn.secondary {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10px);
}

.hero-btn.secondary:hover {
  background: rgba(255, 255, 255, 0.2);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateY(-3px);
}

.btn-icon {
  transition: transform 0.3s ease;
}

.hero-btn:hover .btn-icon {
  transform: translateX(5px);
}

.hero-image {
  position: relative;
  height: 500px;
  animation: slideInRight 1s ease-out;
}

.floating-card {
  position: absolute;
  background: white;
  border-radius: 20px;
  padding: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  cursor: pointer;
}

.floating-card:hover {
  transform: translateY(-10px) scale(1.05);
  box-shadow: 0 30px 60px rgba(0, 0, 0, 0.2);
}

.card-1 {
  top: 20px;
  right: 50px;
  animation: float 6s ease-in-out infinite;
}

.card-2 {
  top: 200px;
  left: 20px;
  animation: float 6s ease-in-out infinite 2s;
}

.card-3 {
  bottom: 50px;
  right: 20px;
  animation: float 6s ease-in-out infinite 4s;
}

.card-image {
  width: 200px;
  height: 150px;
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 12px;
}

.card-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.card-content h4 {
  font-size: 1.2rem;
  font-weight: 700;
  color: #333;
  margin-bottom: 4px;
}

.scroll-indicator {
  position: absolute;
  bottom: 30px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  color: white;
  font-size: 0.9rem;
  z-index: 2;
  animation: bounce 2s infinite;
}

@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInRight {
  from {
    opacity: 0;
    transform: translateX(50px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-20px);
  }
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {
    transform: translateX(-50%) translateY(0);
  }
  40% {
    transform: translateX(-50%) translateY(-10px);
  }
  60% {
    transform: translateX(-50%) translateY(-5px);
  }
}

/* Responsive Hero Banner */
@media (max-width: 968px) {
  .hero-content {
    grid-template-columns: 1fr;
    gap: 40px;
    text-align: center;
  }
  
  .hero-image {
    height: 400px;
  }
  
  .hero-buttons {
    justify-content: center;
  }
  
  .floating-card {
    transform: scale(0.8);
  }
  
  .card-1 { top: 0; right: 10px; }
  .card-2 { top: 150px; left: 50px; }
  .card-3 { bottom: 0; right: 50px; }
}

@media (max-width: 640px) {
  .hero-banner {
    min-height: 90vh;
  }
  
  .hero-content {
    padding: 0 20px;
  }
  
  .hero-title {
    font-size: clamp(2.5rem, 10vw, 4rem);
  }
  
  .hero-subtitle {
    font-size: 1.1rem;
  }
  
  .hero-buttons {
    flex-direction: column;
    align-items: center;
  }
  
  .hero-btn {
    width: 100%;
    max-width: 300px;
    justify-content: center;
  }
  
  .hero-image {
    display: none;
  }
}
/*#endregion*/

/*#region Motto Container*/
#mottoContainer {
  text-align: center;
  margin: 4rem auto;
  width: 60%;
  position: relative; 
  padding: 2rem 1rem;
  z-index: 1;
}
.mottoInner {
  position: relative; 
  z-index: 2; 
}
#mottoContainer h1 {
  font-size: 2.5rem;
  margin-bottom: 2rem;
  margin-top: 1rem;
}
#mottoContainer p {
  font-size: 1.2rem;
  font-style: italic;
  line-height: 1.6;
}

/* Base line style */
.motto-line {
  content: "";
  position: absolute;
  height: 3px;
  background: var(--navbar-bg);
  border-radius: 2px;
  z-index: 1;
}

/* container: top line A (0% -> 75%) */
#mottoContainer::before{
  content: "";
  position: absolute;
  height: 3px;
  background: var(--navbar-bg);
  top: -1.1rem;
  left: 0;
  width: 75%;
  border-radius: 2px;
  z-index: 1;
}

/* container: bottom line A (25% -> 100%) */
#mottoContainer::after{
  content: "";
  position: absolute;
  height: 3px;
  background: var(--navbar-bg);
  bottom: -1.1rem;
  left: 25%;
  width: 75%;
  border-radius: 2px;
  z-index: 1;
}

/* inner wrapper: top line B (25% -> 100%) */
.mottoInner::before{
  content: "";
  position: absolute;
  height: 3px;
  background: var(--navbar-bg);
  top: -1.6rem;   /* slightly above the container::before */
  left: 25%;
  width: 75%;
  border-radius: 2px;
  z-index: 0;
}

/* inner wrapper: bottom line B (0% -> 75%) */
.mottoInner::after{
  content: "";
  position: absolute;
  height: 3px;
  background: var(--navbar-bg);
  bottom: -1.6rem; /* slightly below the container::after */
  left: 0;
  width: 75%;
  border-radius: 2px;
  z-index: 0;
}

/* responsive: on small screens make lines full width and reduce gap */
@media (max-width: 800px) {
  #mottoContainer { width: 90%; padding: 1.2rem 0.8rem; }
  #mottoContainer::before,
  #mottoContainer::after,
  .mottoInner::before,
  .mottoInner::after {
    left: 0;
    width: 100%;
    height: 2px;
  }
  #mottoContainer::before { top: -0.8rem; }
  #mottoContainer::after  { bottom: -0.8rem; }
  .mottoInner::before { top: -1.2rem; }
  .mottoInner::after  { bottom: -1.2rem; }
}
/*#endregion*/

/*#region Feature Container*/
.features-wrapper {
  position: relative;
  padding: 100px 0 80px;
  overflow: hidden;
}

.features-wrapper::before {
  content: '';
  position: absolute;
  inset: 0;
  pointer-events: none;
}

/* ── Header ── */
.features-header {
  text-align: center;
  margin-bottom: 72px;
  position: relative;
  z-index: 2;
  padding: 0 24px;
}

.features-subtitle {
  font-size: 13px;
  font-weight: 700;
  letter-spacing: 4px;
  text-transform: uppercase;
  color: var(--accent, #667eea);
  margin-bottom: 14px;
  opacity: 0;
  animation: fadeInUp 0.8s ease 0.1s forwards;
}

/* ── Cím: Vue animációs rendszer + első doc tipográfia ── */
#featureTitle {
  font-size: clamp(2.2rem, 5vw, 3.6rem);
  font-weight: 800;
  margin: 0;
  line-height: 1.1;
  color: transparent;          /* animáció állítja be */
  letter-spacing: -0.02em;
  border-bottom: none;         /* az első doc nem használ border-bottom-ot */
  opacity: 0;
  animation: none;             /* .in-view váltja ki */
}

#featureTitle span {
  background: linear-gradient(90deg,#914f04 0%,  #ff6800 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

#featureTitle.in-view,
#featureTitle:focus-visible {
  animation: feature-title-appear 0.9s ease both;
}

@keyframes feature-title-appear {
  0%   { color: transparent; opacity: 0; transform: translateY(24px); }
  100% { color: #2d3748;     opacity: 1; transform: translateY(0);    }
}

/* ── Elválasztó ── */
.features-divider {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 28px;
  opacity: 0;
  animation: fadeInUp 0.8s ease 0.4s forwards;
}

.divider-line {
  width: 600px;
  height: 3px;
  background: linear-gradient(90deg, transparent, #cbd5e0, transparent);
}

.divider-dot {
  width: 8px;
  height: 8px;
  background: #ad6801;
  border-radius: 50%;
  margin: 0 16px;
  box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.15);
}

/* ── Section & Grid ── */
.feature-section {
  position: relative;
  z-index: 2;
  padding: 0 24px;
}

.feature-grid {
  max-width: 1200px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(340px, 1fr));
  gap: 28px;
}

/* ── Link wrapper animáció (Vue-s odd/even + első doc delay) ── */
.feature-link {
  text-decoration: none;
  display: block;
  opacity: 0;
  transform: translateY(30px);
}

.feature-link.in-view {
  animation: fadeInUp 0.75s ease forwards;
  animation-delay: var(--delay, 0.1s);
}

@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(30px); }
  to   { opacity: 1; transform: translateY(0);    }
}

/* ── Kártya ── */
.feature-card {
  position: relative;
  background: white;
  border-radius: 24px;
  padding: 40px 32px 32px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.07);
  transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275),
              box-shadow 0.4s ease;
  overflow: hidden;
  height: 100%;
  display: flex;
  flex-direction: column;
  text-align: center;
}

/* Felső gradient csík (első doc) */
.feature-card::before {
  content: '';
  position: absolute;
  top: 0; left: 0; right: 0;
  height: 4px;
  background: linear-gradient(135deg, #ff6a00, #680000);
  transform: scaleX(0);
  transform-origin: left;
  transition: transform 0.4s ease;
}

.feature-link:hover .feature-card {
  transform: translateY(-8px);
  box-shadow: 0 24px 60px rgba(0, 0, 0, 0.11);
}

.feature-link:hover .feature-card::before {
  transform: scaleX(1);
}

/* Sorszám (első doc) */
.feature-number {
  position: absolute;
  top: 18px; right: 22px;
  font-size: 46px;
  font-weight: 800;
  color: #edf2f7;
  line-height: 1;
  user-select: none;
}

/* ── Ikon ── */
.feature-icon-wrapper {
  position: relative;
  width: 80px;
  height: 80px;
  margin: 0 auto 22px;
}

.feature-icon-bg {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg,
    rgba(248, 104, 8, 0.199),
    rgba(221, 27, 13, 0.199));
  border-radius: 20px;
  transition: transform 0.4s ease, background 0.4s ease;
}

.feature-link:hover .feature-icon-bg {
  transform: scale(1.12) rotate(6deg);
  background: linear-gradient(135deg,
    rgba(255, 142, 98, 0.459),
    rgba(253, 115, 115, 0.5));
}

.feature-icon {
  position: relative;
  z-index: 2;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 30px;
  border-radius: 20px;
}

/* ── Szövegek ── */
.feature-title {
  font-size: 21px;
  font-weight: 700;
  color: #2d3748;
  margin: 0 0 14px;
  line-height: 1.3;
  transition: color 0.3s ease;
}

.feature-link:hover .feature-title {
  color: var(--accent, #667eea);
}

.feature-desc {
  font-size: 15px;
  line-height: 1.65;
  color: #718096;
  margin: 0 0 24px;
  flex-grow: 1;
}

/* ── Nyíl gomb (első doc arrow) ── */
.feature-arrow {
  width: 46px;
  height: 46px;
  background: linear-gradient(135deg, #f97316, #680000);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 20px;
  margin: auto auto 0;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.feature-link:hover .feature-arrow {
  transform: translateX(8px);
  box-shadow: 0 8px 20px rgba(102, 126, 234, 0.35);
}

/* ── Responsive ── */
@media (max-width: 800px) {
  .features-wrapper  { padding: 60px 0; }
  .features-header   { margin-bottom: 48px; }
  .feature-grid      { grid-template-columns: 1fr; gap: 20px; }
  #featureTitle      { font-size: clamp(1.7rem, 6vw, 2.4rem); }
}

@media (max-width: 480px) {
  .feature-card          { padding: 28px 20px 24px; }
  .feature-icon-wrapper  { width: 64px; height: 64px; }
  .feature-icon          { font-size: 26px; }
  .feature-number        { font-size: 36px; }
}
/*#endregion*/

/*#region Blog cards*/
.blog-main-title-container {
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
  padding: 0 1rem;
  border-bottom: 5px solid var(--navbar-bg);
}
.blog-main-title{
  text-align: center;
  font-size: 2.5rem;
  margin: 10rem 1rem 1.5rem 1rem;
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.content-wrapper {
  max-width: 1800px;
  margin: 0 auto;
  padding: 0 32px;
}

.cards-wrapper {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(480px, 1fr));
  gap: 64px;
  padding: 48px 0;
}

.card-grid-space {
  position: relative;
}

.card {
  background: var(--b-kartya);
  border-radius: 20px;
  padding: 15px;
  overflow: hidden;
  position: relative;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 0 0 3px rgba(237, 58, 58, 0.1);
  height: 100%;
  display: flex;
  flex-direction: column;
  border: 1px solid #e5e7eb;
  text-align: left;
}

.card-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  opacity: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  color: var(--b-text-dark);
}

.card:hover .card-glow {
  opacity: 1;
  height: 3px;
}

.card-img-holder {
  height: 240px;
  position: relative;
  overflow: hidden;
  border-radius: 20px;
}

.card-img-holder::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 50%, rgba(0, 0, 0, 0.3));
  z-index: 1;
}

.card-img-holder img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: all, var(--b-transition-time);
}

.card:hover .card-img-holder img {
  transform: scale(1.10);
}

.card-content {
  padding: 18px;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.card-header {
  margin-bottom: 16px;
}

.blog-title {
  padding: 16px 0 8px 0;
  font-size: 24px;
  margin: 0;
  transition: all, var(--b-transition-time);
  display: inline-block;
  background-image: linear-gradient(90deg, #b39999, #cacaca);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 3px;
}

.card:hover .blog-title {
  color: var(--b-text-dark);
}

.meta-info {
  margin-bottom: 16px;
}

.blog-time {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #494d55;
  background: #eedada;
  padding: 6px 12px;
  border-radius: 20px;
  font-weight: 500;
}

.icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
}

.description {
  padding: 16px 0;
  font-size: 14px;
  margin: 0;
  line-height: 1.6;
  min-height: 80px;
  overflow: hidden;
}

.card:hover .description {
  color: var(--b-text-dark);  
}

.tags {
  display: flex;
  flex-wrap: wrap;
  margin: 16px 0;
  gap: 8px;
}

.tag {
  font-size: 12px;
  background: var(--b-tag);
  color: var(--b-text-light);
  border-radius: 20px;
  padding: 5px 13px;
  line-height: 24px;
  transition: all, var(--b-transition-time);
  font-weight: 500;
  box-shadow: inset 0px 0px 10px 1px rgba(80, 33, 0, 0.5);
  display: inline-flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid #e5e7eb;
}

.tag:hover {
  background: var(--b-tag-hover);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 0 0 3px rgba(237, 58, 58, 0.1);
}

.tag-hash {
  opacity: 0.7;
  font-size: 14px;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
  padding-top: 20px;
  border-top: 1px solid #d8c7c7;
}

.view-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--b-gomb);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 500;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 6px -1px rgba(237, 58, 58, 0.2);
}

.view-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(237, 58, 58, 0.3);
  background: var(--b-gomb-hover);
}

.arrow-icon {
  transition: transform 0.3s ease;
}

.view-btn:hover .arrow-icon {
  transform: translateX(3px);
}

/*#endregion*/

/* MEDIA QUERIES */

@media screen and (max-width: 1100px) {

  .cards-wrapper {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 24px;
  }
}


@media screen and (max-width: 768px) {
  .cards-wrapper {
    grid-template-columns: 1fr;
    gap: 24px;
    padding: 32px 0;
  }
}

@media screen and (max-width: 500px) {

  .cards-wrapper {
    grid-template-columns: 1fr;
  }
  .card {
    max-width: 100%;
  }
}
/*#endregion*/
</style>


