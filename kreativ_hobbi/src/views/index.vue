<script setup>
import Carousel from '@/components/carousel.vue';
import { ref, onMounted, onUnmounted,nextTick } from 'vue';

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
    { threshold: 1 } // 100% visible
  );
  if (featureTitleRef.value) io.observe(featureTitleRef.value);
});

onUnmounted(() => {
  if (io) io.disconnect();
});

// Sample blog data
const blogPosts = [
  {
    title: "Horgolt táskák trendjei 2024-ben",
    date: "2024-05-10",
    author: "John Doe",
    description: "Fedezd fel a legújabb horgolt táska trendeket és stílusokat ebben az évben.",
    tag:["Horgolás", "Hímzés",  "Kötés"]
  },
  {
    title: "Kötés kezdőknek: Az első lépések",
    date: "2024-04-22",
    author: "Jane Smith",
    description: "Ismerd meg a kötés alapjait és kezdj el alkotni még ma!",
    tag:["Horgolás", "Hímzés",  "Kötés"]
  },
  {
    title: "Hímzés minták inspirációi",
    date: "2024-03-15",
    author: "Bob Johnson",
    description: "Meríts ihletet a legszebb hímzés mintákból és alkoss valami egyedit.",
    tag: "Hímzés"
  }
];

function BlogCardequalizer() {
  let maxHeight = 0;
    const blogCards = document.querySelectorAll('.blog-card');
    // Find the tallest card
    blogCards.forEach(card => {
      const cardHeight = card.offsetHeight;
      if (cardHeight > maxHeight) {
        maxHeight = cardHeight;
      }
    });

    // Apply the maximum height to all cards
    if (maxHeight > 0) {
      blogCards.forEach(card => {
        card.style.height = `${maxHeight}px`;
      });
    };
};

onMounted(() => {
  // Wait for all images and other resources to load
  window.addEventListener('load', () => {
    // Use nextTick to ensure the DOM is fully updated
    nextTick(() => {
      BlogCardequalizer();
    });
  });
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

    
    <div class="blog-main-title-container">
      <h2 class="blog-main-title">A hét kiemelt blogposztjai</h2>
    </div>
    <section class="blog-section">
        <div class="blog-card-grid-space"v-for="n in blogPosts" :key="n">
          <div class="blog-card">
            <div class="blog-card-img-holder">
              <img src="https://encrypted-tbn3.gstatic.com/shopping?q=tbn:ANd9GcRgRsQXzqdCz0aktVRQGM4CFdzOW1BRRw7GA0OldqTWcIh2qRCuQZJIrmMHYPNFV6iJ5f63CqYFxbEQysznAsKudp02KEBeahEC3BipCJcip1HLs8J_dlY0DB9DPBwTZjuB1LUgAQ&usqp=CAc" alt="HTML Syntax">
            </div>
            <h3 class="blog-title">{{ n.title }}</h3>
            <div class="blog-meta">
              <span class="blog-time">{{ n.date }}</span>
              <span class="blog-author"><strong>{{ n.author }}</strong></span>
            </div>
            <p class="blog-description">
              {{ n.description }}
            </p>
            <div class="blog-tags">
              <div class="blog-tag" >{{ n.tag[0] }}</div>
            </div>
            <div class="blog-options">
              <span>
                Read Full Blog
              </span>
              <button class="btn" @click="$router.push('/blog')">Blog</button>
            </div>
          </div>
        </div>
    </section>
  </main>
</template>

<style scoped>
/*#region Imports*/
@import url('https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css?family=Heebo:400,700|Open+Sans:400,700');
/*#endregion*/

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
#featureTitle {
  max-width: 650px;
  width: 100%;
  text-align: center;
  font-size: 2.5rem;
  justify-self: center;
  margin: 10rem 1rem 1.5rem 1rem;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  padding: 0.6rem 1rem;
  color: transparent; /* keep this if animation sets color */
  border-bottom: 5px solid var(--navbar-bg);
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
/* Cards Grid */
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
.blog-section {
  display: grid;
  justify-content: center;
  align-items: center;
  grid-template-columns: 1fr 1fr 1fr;
  grid-gap: 4rem;
  padding: 4rem;
  margin: 0 auto;
  width: max-content;
}

.blog-card-grid-space {
  position: relative;
}

/* Hybrid Card Styles */
.blog-card {
  width: 30rem;
  height:auto;
  background: #fff;
  border-radius: 1.5rem;
  padding: 1.5rem;
  overflow: hidden;
  position: relative;
  font-family: 'Rubik', sans-serif;
  box-sizing: border-box;
  box-shadow: 0 0 5em -1em rgba(0,0,0,0.1);
  transition: all, var(--transition-time);
  /* border: 10px solid #f0f0f0; */
}

.blog-card:hover {
  transform: translateY(-5px);
  box-shadow: var(--shadow-hover);
  border-color: var(--color);
}


.blog-card-img-holder {
  width: 100%;
  height: auto;
  position: relative;
  overflow: hidden;
  border-radius: 1.5rem;
  margin-bottom: 1rem;
}

.blog-card-img-holder img {
  width: 100%;
  height: auto;
  max-height: 15rem;
  object-fit: cover;
  transition: all, var(--transition-time);
}

.blog-card:hover .blog-card-img-holder img {
  transform: scale(1.05);
}

.blog-meta {
    display: flex;
    align-items: center;
    gap: 12rem;
}

.blog-title {
  border-top: 1px solid #ff0000;
  color: #22215B;
  padding: 1rem 0 0.5rem 0;
  font-size: 1.5rem;
  margin: 0;
  transition: all, var(--transition-time);
}

.blog-card:hover .blog-title {
  color: var(--color);
}

.blog-description {
  padding: 1rem 0;
  color: #22215B80;
  font-size: 1rem;
  margin: 0;
  line-height: 1.6;
}

.blog-time {
  font-size: .8rem;
  color: #22215B;
  display: block;
  opacity: 0.7;
}

.blog-author {
  font-size: .8rem;
  color: #22215B;
  display: block;
}

.blog-tags {
  display: flex;
  margin: 1rem 0;
}

.blog-tags .blog-tag {
  font-size: 0.75em;
  background: rgba(60, 49, 99, 0.1);
  color: var(--color);
  border-radius: 0.3rem;
  padding: 0.3em 0.8em;
  margin-right: 0.5em;
  line-height: 1.5em;
  transition: all, var(--transition-time);
  font-weight: 500;
}

.blog-card:hover .blog-tags .blog-tag {
    background: violet; /* Change color on hover */
    color: rgb(255, 255, 255); /* Change text color on hover */
    transform: translateY(-2px);
}

.blog-options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 1rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #f0f0f0;
}

.blog-options span {
  font-weight: 600;
  color: #22215B;
  transition: all, var(--transition-time);
}

.blog-card:hover .blog-options span {
  color: var(--color);
}

.btn {
  font-size: 1rem;
  padding: .5rem 1.5rem;
  border-radius: .5rem;
  font-weight: 400;
  background: #EEF7FE;
  color: #22215B;
  cursor: pointer;
  border: none;
  transition: all, var(--transition-time);
}

.btn:hover {
  background: var(--color);
  color: white;
  transform: translateY(-2px);
}

/* Card hover effects */
.blog-card:before, .blog-card:after {
  content: '';
  transform: scale(0);
  transform-origin: top left;
  border-radius: 50%;
  position: absolute;
  left: -50%;
  top: -50%;
  z-index: -1;
  transition: all, var(--transition-time);
  transition-timing-function: ease-in-out;
}

.blog-card:before {
  background: rgba(60, 49, 99, 0.05);
  width: 250%;
  height: 250%;
}

.blog-card:after {
  background: rgba(255,255,255,0.5);
  width: 200%;
  height: 200%;
}

.blog-card:hover:before, .blog-card:hover:after {
  transform: scale(1);
}

/* MEDIA QUERIES */
@media screen and (max-width: 1660px) {
  .blog-section {
    grid-template-columns: 1fr 1fr;
  }
  .blog-card {
    width: 30rem;
  }
}
@media screen and (max-width: 1100px) {
  .blog-card {
    width: 25rem;
  }
}

@media screen and (max-width: 945px) {
  .blog-section {
    grid-template-columns: 1fr;
  }
  .blog-card {
    width: 26rem;
  }
}

@media screen and (max-width: 768px) {
  .blog-card {
    font-size: 15px;
  }
}

@media screen and (max-width: 500px) {
  .blog-section {
    padding: 4rem 2rem;
  }
  .blog-card {
    max-width: calc(90vw - 4rem);
  }
}

@media screen and (max-width: 465px) {
  .blog-card {
    font-size: 14px;
  }
}
/*#endregion*/
</style>


