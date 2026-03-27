<template>
  <div class="carousel-outer">
    <div class="carousel-wrapper">

      <!-- Track -->
      <div class="carousel-track">
        <transition :name="slideDir" mode="out-in">
          <div
            class="carousel-slide"
            :key="currentIndex"
            :style="{ '--accent': accentColor }"
          >
            <!-- Left: image -->
            <div class="slide-image-col">
              <div class="slide-image-frame">
                <div class="frame-deco top-left"></div>
                <div class="frame-deco bottom-right"></div>
                <img
                  :src="kepek[currentIndex].termek_fo_kep?.url_Link || fallbackImg"
                  :alt="kepek[currentIndex].nev"
                  class="slide-img"
                />

              </div>
            </div>

            <!-- Right: info -->
            <div class="slide-info-col">
              <!-- index indicator -->
              <div class="slide-index-row">
                <span class="slide-index-current">{{ String(currentIndex + 1).padStart(2, '0') }}</span>
                <span class="slide-index-sep">/</span>
                <span class="slide-index-total">{{ String(kepek.length).padStart(2, '0') }}</span>
              </div>

              <h2 class="slide-title">{{ kepek[currentIndex].nev || 'Termék neve' }}</h2>

              <p class="slide-price" v-if="kepek[currentIndex].ar">
                {{ Number(kepek[currentIndex].ar).toLocaleString('hu-HU') }} Ft
              </p>

              <p class="slide-desc">
                {{ kepek[currentIndex].leiras || 'Ez egy fantasztikus termék, amelyet érdemes megtekinteni!' }}
              </p>

              <!-- Color swatches -->
              <div class="slide-colors" v-if="kepek[currentIndex].termek_szinek?.length">
                <p class="colors-label">Elérhető színek</p>
                <div class="color-row">
                  <button
                    v-for="szin in kepek[currentIndex].termek_szinek"
                    :key="szin.id"
                    class="color-swatch"
                    :class="{ active: selectedColor?.id === szin.id }"
                    :style="{ backgroundColor: szin.hex_kod || '#ccc' }"
                    :title="szin.szin_nev"
                    @click="selectedColor = szin"
                  >
                    <span class="swatch-tooltip">{{ szin.szin_nev }}</span>
                  </button>
                </div>
                <p class="selected-color-name" v-if="selectedColor">{{ selectedColor.szin_nev }}</p>
              </div>

              <!-- Fallback color dots if no termek_szinek -->
              <div class="slide-colors" v-else>
                <p class="colors-label">Elérhető árnyalatok</p>
                <div class="color-row">
                  <span
                    v-for="(color, i) in bgColors"
                    :key="i"
                    class="color-swatch static"
                    :style="{ backgroundColor: color }"
                  ></span>
                </div>
              </div>

              <button
                class="slide-cta"
                @click="router.push(`/aruhaz/${kepek[currentIndex].id}`)"
              >
                <span>Termék megtekintése</span>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                  <path d="M5 12h14M12 5l7 7-7 7"/>
                </svg>
              </button>
            </div>
          </div>
        </transition>
      </div>

      <!-- Nav buttons -->
      <button class="nav-btn nav-prev" @click="prevSlide" aria-label="Előző">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
      </button>
      <button class="nav-btn nav-next" @click="nextSlide" aria-label="Következő">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <path d="M5 12h14M12 5l7 7-7 7"/>
        </svg>
      </button>
    </div>

    <!-- Progress dots -->
    <div class="carousel-dots">
      <button
        v-for="(_, i) in kepek"
        :key="i"
        class="dot-btn"
        :class="{ active: i === currentIndex }"
        @click="goTo(i)"
        :aria-label="`${i + 1}. termék`"
      ></button>
    </div>

    <!-- Progress bar -->
    <div class="progress-bar">
      <div class="progress-fill" :style="{ width: progressPct + '%' }"></div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

const router = useRouter();

const fallbackImg = 'http://localhost:8000/storage/termekkepek/default.jpg';

const bgColors = ['#946609', '#944309', '#c7590a', '#c45529', '#912b03'];

const kepek = ref([
  { nev: '', leiras: '', termek_fo_kep: null, ar: null, termek_szinek: [] },
  { nev: '', leiras: '', termek_fo_kep: null, ar: null, termek_szinek: [] },
  { nev: '', leiras: '', termek_fo_kep: null, ar: null, termek_szinek: [] },
  { nev: '', leiras: '', termek_fo_kep: null, ar: null, termek_szinek: [] },
  { nev: '', leiras: '', termek_fo_kep: null, ar: null, termek_szinek: [] },
]);

const currentIndex = ref(0);
const slideDir = ref('slide-left');
const selectedColor = ref(null);

// Pick accent color from bgColors cycling with index
const accentColor = computed(() => bgColors[currentIndex.value % bgColors.length]);

// Progress for the autoplay bar
const AUTOPLAY_MS = 8000;
const progressPct = ref(0);
let progressRaf = null;
let progressStart = null;
let autoplayTimer = null;

function startProgress() {
  progressPct.value = 0;
  progressStart = performance.now();
  cancelAnimationFrame(progressRaf);
  progressRaf = requestAnimationFrame(tickProgress);
}

function tickProgress(now) {
  const elapsed = now - progressStart;
  progressPct.value = Math.min((elapsed / AUTOPLAY_MS) * 100, 100);
  if (elapsed < AUTOPLAY_MS) {
    progressRaf = requestAnimationFrame(tickProgress);
  }
}

function resetAutoplay() {
  clearTimeout(autoplayTimer);
  cancelAnimationFrame(progressRaf);
  startProgress();
  autoplayTimer = setTimeout(nextSlide, AUTOPLAY_MS);
}

function nextSlide() {
  slideDir.value = 'slide-left';
  currentIndex.value = (currentIndex.value + 1) % kepek.value.length;
  resetAutoplay();
}

function prevSlide() {
  slideDir.value = 'slide-right';
  currentIndex.value = (currentIndex.value - 1 + kepek.value.length) % kepek.value.length;
  resetAutoplay();
}

function goTo(i) {
  slideDir.value = i > currentIndex.value ? 'slide-left' : 'slide-right';
  currentIndex.value = i;
  resetAutoplay();
}

// Reset selectedColor when slide changes
watch(currentIndex, () => {
  const szinek = kepek.value[currentIndex.value]?.termek_szinek;
  selectedColor.value = szinek?.length ? szinek[0] : null;
});

async function fetchCarouselImages() {
  try {
    const response = await axios.get('/api/carousel/termekek');
    return response.data;
  } catch (error) {
    console.error('Error fetching carousel images:', error);
    return [];
  }
}

onMounted(async () => {
  const data = await fetchCarouselImages();
  if (data?.length) {
    kepek.value = data;
    const szinek = data[0]?.termek_szinek;
    selectedColor.value = szinek?.length ? szinek[0] : null;
  }
  resetAutoplay();
});

onUnmounted(() => {
  clearTimeout(autoplayTimer);
  cancelAnimationFrame(progressRaf);
});
</script>

<style scoped>
/* ── Outer wrapper ── */
.carousel-outer {
  width: 97%;
  margin: 5px auto 0;
  font-family: 'Rubik', sans-serif;
}

/* ── Main wrapper: warm gradient matching the site ── */
.carousel-wrapper {
  position: relative;
  border-radius: 28px;
  background: linear-gradient(135deg, #3d1a0a 0%, #7a3410 50%, #a84e1e 100%);
  overflow: hidden;
  box-shadow: 0 24px 60px rgba(100, 30, 5, 0.35);
}

/* Subtle fabric texture overlay */
.carousel-wrapper::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url('https://texturelabs.org/wp-content/uploads/Texturelabs_Fabric_155thumbnail.jpg');
  background-size: cover;
  opacity: 0.06;
  z-index: 0;
  pointer-events: none;
}

/* Decorative top-right glow */
.carousel-wrapper::after {
  content: '';
  position: absolute;
  top: -80px;
  right: -80px;
  width: 300px;
  height: 300px;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(255,138,80,0.25) 0%, transparent 70%);
  pointer-events: none;
  z-index: 0;
}

/* ── Slide ── */
.carousel-track {
  position: relative;
  z-index: 1;
  width: 100%;
  height: clamp(280px, 38vw, 550px);
  overflow: hidden;
}

.carousel-slide {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  display: grid;
  grid-template-columns: 1fr 1fr;
  align-items: center;
  gap: 0;
  padding: clamp(24px, 4vw, 56px) clamp(24px, 5vw, 72px);
  box-sizing: border-box;
}

/* ── Slide transitions ── */
.slide-left-enter-active,
.slide-left-leave-active,
.slide-right-enter-active,
.slide-right-leave-active {
  transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1),
              opacity 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.slide-left-enter-from  { transform: translateX(60px); opacity: 0; }
.slide-left-leave-to    { transform: translateX(-60px); opacity: 0; }
.slide-right-enter-from { transform: translateX(-60px); opacity: 0; }
.slide-right-leave-to   { transform: translateX(60px); opacity: 0; }

/* ── Image column ── */
.slide-image-col {
  display: flex;
  align-items: center;
  justify-content: center;
  padding-right: clamp(16px, 3vw, 40px);
}

.slide-image-frame {
  position: relative;
  width: 100%;
  max-width: 340px;
  aspect-ratio: 1 / 1;
}

/* Decorative corner brackets */
.frame-deco {
  position: absolute;
  width: 28px;
  height: 28px;
  border-color: rgba(255,255,255,0.3);
  border-style: solid;
  z-index: 2;
}
.frame-deco.top-left {
  top: -6px; left: -6px;
  border-width: 2px 0 0 2px;
  border-radius: 4px 0 0 0;
}
.frame-deco.bottom-right {
  bottom: -6px; right: -6px;
  border-width: 0 2px 2px 0;
  border-radius: 0 0 4px 0;
}

.slide-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: 20px;
  filter: drop-shadow(0 20px 40px rgba(0,0,0,0.4));
  transition: transform 0.4s ease;
}

.carousel-slide:hover .slide-img {
  transform: scale(1.03) translateY(-4px);
}

/* Price in info column */
.slide-price {
  font-size: clamp(1.1rem, 2vw, 1.5rem);
  font-weight: 800;
  color: #ffd4a8;
  margin: 0;
  letter-spacing: -0.01em;
}

/* ── Info column ── */
.slide-info-col {
  display: flex;
  flex-direction: column;
  gap: clamp(10px, 1.5vw, 18px);
  color: white;
  padding-left: clamp(16px, 3vw, 40px);
  border-left: 1px solid rgba(255,255,255,0.12);
}

.slide-index-row {
  display: flex;
  align-items: baseline;
  gap: 4px;
  margin-bottom: 4px;
}
.slide-index-current {
  font-size: clamp(28px, 4vw, 44px);
  font-weight: 800;
  color: white;
  line-height: 1;
  letter-spacing: -0.03em;
}
.slide-index-sep {
  font-size: 18px;
  color: rgba(255,255,255,0.35);
  margin: 0 2px;
}
.slide-index-total {
  font-size: 14px;
  color: rgba(255,255,255,0.45);
  font-weight: 500;
}

.slide-title {
  font-size: clamp(1.2rem, 2.4vw, 1.9rem);
  font-weight: 700;
  margin: 0;
  line-height: 1.2;
  color: white;
  letter-spacing: -0.01em;
}

.slide-desc {
  font-size: clamp(0.78rem, 1.1vw, 0.95rem);
  line-height: 1.65;
  color: rgba(255,255,255,0.72);
  margin: 0;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* ── Colors ── */
.slide-colors {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.colors-label {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: rgba(255,255,255,0.5);
  margin: 0;
}

.color-row {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.color-swatch {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  border: 2px solid rgba(255,255,255,0.25);
  cursor: pointer;
  position: relative;
  transition: all 0.2s ease;
  outline: none;
  padding: 0;
  flex-shrink: 0;
}

.color-swatch.static {
  pointer-events: none;
  cursor: default;
}

.color-swatch:hover {
  transform: scale(1.18);
  border-color: rgba(255,255,255,0.7);
}

.color-swatch.active {
  border-color: white;
  box-shadow: 0 0 0 3px rgba(255,255,255,0.35);
  transform: scale(1.15);
}

/* Tooltip */
.swatch-tooltip {
  position: absolute;
  bottom: calc(100% + 8px);
  left: 50%;
  transform: translateX(-50%);
  background: rgba(20,10,5,0.9);
  color: white;
  font-size: 11px;
  font-weight: 500;
  padding: 4px 10px;
  border-radius: 6px;
  white-space: nowrap;
  pointer-events: none;
  opacity: 0;
  transition: opacity 0.2s ease;
  z-index: 10;
}
.color-swatch:hover .swatch-tooltip {
  opacity: 1;
}

.selected-color-name {
  font-size: 12px;
  color: rgba(255,255,255,0.6);
  margin: 0;
  font-style: italic;
  min-height: 16px;
}

/* ── CTA button ── */
.slide-cta {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  background: white;
  color: #7a3410;
  border: none;
  padding: clamp(10px, 1.5vw, 14px) clamp(18px, 2.5vw, 28px);
  border-radius: 50px;
  font-size: clamp(13px, 1.3vw, 15px);
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  align-self: flex-start;
  margin-top: 4px;
  letter-spacing: 0.01em;
  font-family: inherit;
  box-shadow: 0 8px 24px rgba(0,0,0,0.25);
}

.slide-cta:hover {
  background: #fff5ee;
  transform: translateY(-2px);
  box-shadow: 0 14px 32px rgba(0,0,0,0.3);
  gap: 14px;
}

.slide-cta svg {
  transition: transform 0.3s ease;
}
.slide-cta:hover svg {
  transform: translateX(4px);
}

/* ── Nav buttons ── */
.nav-btn {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  z-index: 10;
  width: 44px;
  height: 44px;
  border-radius: 50%;
  border: 1.5px solid rgba(255,255,255,0.25);
  background: rgba(255,255,255,0.1);
  backdrop-filter: blur(10px);
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.25s ease;
}

.nav-btn:hover {
  background: rgba(255,255,255,0.22);
  border-color: rgba(255,255,255,0.5);
  transform: translateY(-50%) scale(1.08);
}

.nav-prev { left: 16px; }
.nav-next { right: 16px; }

/* ── Dots ── */
.carousel-dots {
  display: flex;
  justify-content: center;
  gap: 8px;
  margin-top: 18px;
}

.dot-btn {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  border: none;
  background: rgba(122, 52, 16, 0.3);
  cursor: pointer;
  padding: 0;
  transition: all 0.3s ease;
}

.dot-btn.active {
  background: #a84e1e;
  width: 28px;
  border-radius: 4px;
}

/* ── Progress bar ── */
.progress-bar {
  height: 3px;
  background: rgba(122, 52, 16, 0.15);
  border-radius: 2px;
  margin-top: 12px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #c7590a, #ff8a65);
  border-radius: 2px;
  transition: width 0.1s linear;
}

/* ── Responsive ── */
@media (max-width: 820px) {
  .carousel-slide {
    grid-template-columns: 1fr;
    grid-template-rows: auto auto;
    padding: 32px 24px 28px;
    gap: 24px;
  }

  .slide-image-col {
    padding-right: 0;
  }

  .slide-image-frame {
    max-width: 220px;
    margin: 0 auto;
  }

  .slide-info-col {
    padding-left: 0;
    border-left: none;
    border-top: 1px solid rgba(255,255,255,0.12);
    padding-top: 20px;
  }

  .slide-index-current { font-size: 28px; }

  .nav-prev { left: 8px; }
  .nav-next { right: 8px; }
}

@media (max-width: 480px) {
  .carousel-wrapper {
    border-radius: 20px;
    min-height: auto;
  }

  .slide-title {
    font-size: 1.2rem;
  }

  .slide-desc {
    -webkit-line-clamp: 2;
  }

  .color-swatch {
    width: 24px;
    height: 24px;
  }
}
</style>