<script setup>
import Carousel from '@/components/carousel.vue';
import { ref, onMounted, onUnmounted } from 'vue';

const featureTitleRef = ref(null);
const isInView = ref(false);
let io = null;

onMounted(() => {
  io = new IntersectionObserver(
    ([entry]) => {
      // play animation when at least 50% visible; change threshold as needed
      isInView.value = entry.isIntersecting;
      // if you want the animation to run only once, uncomment:
      if (entry.isIntersecting) io.unobserve(entry.target);
    },
    { threshold: 1 }
  );
  if (featureTitleRef.value) io.observe(featureTitleRef.value);
});

onUnmounted(() => {
  if (io) io.disconnect();
});
</script>

<template>
  <main>
    <carousel></carousel>
    <div id="mottoContainer">
      <div class="mottoInner">
        <h1>Webáruházunk vmije</h1>
        <p>
          "Lorem ipsum dolor sit amet consectetur adipisicing elit. Magnam rerum beatae sunt, laboriosam minima nam sapiente reprehenderit quisquam repellat asperiores minus quis, fuga natus ipsum ipsam quod molestiae corporis incidunt!
          Lorem ipsum dolor sit amet consectetur adipisicing elit. Quisquam, natus.LOREM ipsum dolor sit amet consectetur adipisicing elit."
        </p>
      </div>
    </div>

    <!-- add ref, tabindex so it can receive keyboard focus, and class binding -->
    <h1
      id="featureTitle"
      ref="featureTitleRef"
      tabindex="0"
      :class="{ 'in-view': isInView }"
    >
      Miért válassz minket?
    </h1>

    <section class="feature-section">
      <div class="feature-grid">
        <router-link class="feature-link" to="/mintakeszito"  :class="{ 'in-view': isInView }">
          <article class="feature-card">
            <div class="feature-icon" aria-hidden="true">🎨</div>
            <h3 class="feature-title">Mintakészítő</h3>
            <p class="feature-desc">
              Készíts személyre szabott mintákat saját képeid alapján. Kötés, horgolás és hímzés egy helyen.
            </p>
          </article>
        </router-link>

        <router-link class="feature-link" to="/aruhaz"  :class="{ 'in-view': isInView }">      
          <article class="feature-card">
            <div class="feature-icon" aria-hidden="true">📦</div>
            <h3 class="feature-title">Minőségi termékek</h3>
            <p class="feature-desc">
              Prémium alapanyagok és eszközök a legszebb alkotásokhoz. Raktárról, gyors szállítással.
            </p>
          </article>
        </router-link>

        <router-link class="feature-link" to="/blog"  :class="{ 'in-view': isInView }">
          <article class="feature-card">
            <div class="feature-icon" aria-hidden="true">📚</div>
            <h3 class="feature-title">Blog és közösség</h3>
            <p class="feature-desc">
              Oszd meg tapasztalataidat, tanulj másoktól és inspirálódj a közösségünk által.
            </p>
          </article>
        </router-link>

        <router-link class="feature-link" to="/rolunk"  :class="{ 'in-view': isInView }">
          <article class="feature-card">
            <div class="feature-icon" aria-hidden="true">👥</div>
            <h3 class="feature-title">Szakértő segítség</h3>
            <p class="feature-desc">
              Tapasztalt kézművesek állnak rendelkezésedre, hogy segítsenek a projektjeidben.
            </p>
          </article>
        </router-link>

        <router-link class="feature-link" to="/"  :class="{ 'in-view': isInView }">
          <article class="feature-card">
            <div class="feature-icon" aria-hidden="true">⭐</div>
            <h3 class="feature-title">Elégedettség garancia</h3>
            <p class="feature-desc">
              Ha nem vagy elégedett a termékkel, 30 napon belül visszaküldheted.
            </p>
          </article>
        </router-link>

        <router-link class="feature-link" to="/" :class="{ 'in-view': isInView }">
            <article class="feature-card">
              <div class="feature-icon" aria-hidden="true">🚚</div>
              <h3 class="feature-title">Gyors szállítás</h3>
              <p class="feature-desc">
                Rendeléseket 2–3 munkanapon belül házhoz szállítjuk országszerte.
              </p>
            </article>
        </router-link>
      </div>
    </section>
    <section class="blog-section">

      

    </section>
  </main>
</template>

<style scoped>
/*#region Motto Container*/
#mottoContainer {
  text-align: center;
  margin: 1rem auto;
  width: 60%;
  position: relative; /* needed for pseudo-lines */
  padding: 2rem 1rem;
  z-index: 1;
}
.mottoInner {
  position: relative; /* allow inner pseudo-elements */
  z-index: 2; /* keep text above lines */
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
  background: rgba(122,64,45,1);
  border-radius: 2px;
  z-index: 1;
}

/* container: top line A (0% -> 75%) */
#mottoContainer::before{
  content: "";
  position: absolute;
  height: 3px;
  background: rgba(122,64,45,1);
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
  background: rgba(122,64,45,1);
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
  background: rgba(122,64,45,1);
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
  background: rgba(122,64,45,1);
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

/*#region At Container*/
#featureTitle {
  text-align: center;
  font-size: 2.5rem;
  margin: 10rem 1rem 1.5rem 1rem;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 0.6rem 1rem;
  color: transparent; /* keep this if animation sets color */
  /* no animation here */
}

/* trigger animation only when in-view OR when focused via keyboard */
#featureTitle.in-view,
#featureTitle:focus-visible {
  animation: feature-title-appear 1s ease both;
}

/*#region existing keyframes */
@keyframes feature-title-appear {
  0% {
    color: transparent;
    transform: translateY(20px);
    opacity: 0;
  }
  100% {
    color: black;
    transform: translateY(0);
    opacity: 1;
  }
}
/*#endregion*/

.feature-section{
  background: var(--bg);
  padding: 32px 64px;
}

.feature-grid{
  max-width: 1400px;
  margin: 0 auto;
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 32px 70px;
}

@media (max-width: 800px){
  .feature-grid{ grid-template-columns: 1fr; }
  #featureTitle {
  font-size: clamp(1.6rem, 5.5vw, 2.2rem);
  margin: 4rem 1rem 1rem;
  padding: 0.4rem 0.6rem;
  }
}

.feature-link{
  text-decoration: none;
}
@keyframes feature-card-appear-left {
  0% {
    color: transparent;
    transform: translatex(-125px);
    opacity: 0;
  }
  100% {
    color: black;
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes feature-card-appear-right {
  0% {
    color: transparent;
    transform: translatex(125px);
    opacity: 0;
  }
  100% {
    color: black;
    transform: translateX(0);
    opacity: 1;
  }
}

.feature-card{
  background: var(--card);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  min-height: 150px;
  padding: 60px ;
  text-align: center;
  transition: transform .15s ease, box-shadow .15s ease;
}
.feature-link:nth-child(odd).in-view{
  animation: feature-card-appear-left 1s ease both;
}
.feature-link:nth-child(even).in-view{
  animation: feature-card-appear-right 1s ease both;
}

.feature-card:hover{
  transform: translateY(-2px);
  box-shadow: 0 12px 28px rgba(17, 24, 39, 0.08);
}

.feature-icon{
  width: 56px;
  height: 56px;
  margin: 0 auto 14px;
  border-radius: 14px;
  display: grid;
  place-items: center;
  background: var(--accent-soft);
  color: var(--accent);
  font-size: 26px; /* swap emoji for SVG if desired */
}

.feature-title{
  margin: 6px 0 8px;
  font-size: 20px;
  line-height: 1.2;
  color: var(--text);
  font-weight: 700;
}

.feature-desc{
  margin: 0;
  color: var(--muted);
  font-size: 15px;
  line-height: 1.6;
}
/*#endregion*/

/*#region Blog cards*/


/*#endregion*/
</style>


