<template>
<div class="item-page">
    <button @click="goBack" class="back-btn">
      <span class="back-arrow">←</span> Vissza
    </button>

    <CartModal ref="cartModal" />

    <div v-if="loading" class="loading">
      <div class="spinner"></div>
      <span>Betöltés...</span>
    </div>

    <div v-else-if="product" class="product-detail">

      <!-- IMAGE GALLERY -->
      <div class="product-images">
        <div class="main-image-wrap">
          <transition name="fade" mode="out-in">
            <img
              :key="activeImage"
              :src="activeImage"
              :alt="product.nev"
              class="main-image"
            />
          </transition>

          <template v-if="allImages.length > 1">
            <button class="gallery-arrow left" @click="prevImage">&#8249;</button>
            <button class="gallery-arrow right" @click="nextImage">&#8250;</button>
          </template>

          <!-- Dot indicators -->
          <div v-if="allImages.length > 1" class="dots">
            <span
              v-for="(img, i) in allImages"
              :key="i"
              class="dot"
              :class="{ active: activeIndex === i }"
              @click="activeIndex = i"
            ></span>
          </div>
        </div>

        <!-- Thumbnails -->
        <div v-if="allImages.length > 1" class="thumbnails">
          <div
            v-for="(img, i) in allImages"
            :key="i"
            class="thumb-wrap"
            :class="{ active: activeIndex === i }"
            @click="activeIndex = i"
          >
            <img :src="img" :alt="product.nev + ' ' + (i + 1)" class="thumb" />
          </div>
        </div>
      </div>

      <!-- PRODUCT INFO -->
      <div class="product-info">
        <div class="category-label" v-if="product.termek_kategoria">
          {{ product.termek_kategoria.nev }}
        </div>

        <h1>{{ product.nev }}</h1>

        <p class="price">{{ Number(product.ar).toLocaleString('hu-HU') }} Ft</p>

        <div class="tag-container">
          <span
            v-for="kategoria in product.termek_kategoriak"
            :key="kategoria.id"
            class="item-tag-sm"
            :class="{ 'main-category': kategoria.fo_kategoria_id === null }"
          >
            {{ kategoria.nev }}
          </span>
        </div>

        <p class="description">{{ product.leiras }}</p>

        <!-- Colors -->
        <div v-if="product.termek_szinek?.length" class="colors">
          <label>
            Szín:
            <span class="selected-color-name">{{ selectedColor?.szin_nev ?? '' }}</span>
          </label>
          <div class="color-options">
            <button
              v-for="szin in product.termek_szinek"
              :key="szin.id"
              class="color-btn"
              :style="{ backgroundColor: szin.hex_kod || '#ccc' }"
              :title="szin.szin_nev"
              @click="selectedColor = szin"
              :class="{ active: selectedColor?.id === szin.id }"
            ></button>
          </div>
        </div>

        <!-- Quantity -->
        <div class="quantity">
          <label>Mennyiség:</label>
          <div class="qty-row">
            <div class="qty-control">
              <button @click="qty > 1 && qty--" class="qty-btn">−</button>
              <input
                v-model.number="qty"
                type="number"
                :min="1"
                :max="product.darab"
                class="qty-input"
              />
              <button @click="qty < product.darab && qty++" class="qty-btn">+</button>
            </div>
            <p class="stock-info" :class="{ low: product.darab < 5, out: product.darab === 0 }">
              <span class="stock-dot"></span>
              {{ product.darab > 0 ? `Raktáron: ${product.darab} db` : 'Elfogyott' }}
            </p>
          </div>
        </div>

        <button @click="addToCart" class="add-to-cart-btn" :disabled="product.darab === 0">
          <span v-if="product.darab > 0">Kosárba teszem</span>
          <span v-else>Elfogyott</span>
        </button>
      </div>
    </div>

    <p v-else class="error">Termék nem található</p>
  </div>
</template>

<script setup>
import { ref, computed, onMounted,inject } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'
import { useCartStore } from '@/stores/cartStore'
import CartModal from '@/components/CartModal.vue'

const route = useRoute()
const router = useRouter()
const cartStore = useCartStore()
const cartModal = ref(null)
const { showToast } = inject('toast')
const product = ref(null)
const loading = ref(true)
const qty = ref(1)
const selectedColor = ref(null)
const activeIndex = ref(0)

const allImages = computed(() => {
  if (!product.value) return []
  const seen = new Set()
  const imgs = []

  const add = (url) => {
    if (url && !seen.has(url)) {
      seen.add(url)
      imgs.push(url)
    }
  }

  add(product.value.termek_fo_kep?.url_Link)

  if (product.value.termek_kepek?.length) {
    product.value.termek_kepek.forEach(k => add(k.url_Link))
  }

  return imgs
})

const activeImage = computed(() => allImages.value[activeIndex.value] ?? '')

function prevImage() {
  activeIndex.value = (activeIndex.value - 1 + allImages.value.length) % allImages.value.length
}

function nextImage() {
  activeIndex.value = (activeIndex.value + 1) % allImages.value.length
}
async function fetchProduct() {
  try {
    const id = route.params.id
    const res = await axios.get(`/api/termekek/${id}`)
    product.value = res.data
    console.log(res.data)
    if (res.data.termek_szinek && res.data.termek_szinek.length > 0) {
      selectedColor.value = res.data.termek_szinek[0]
    }

    const szinId = Number(route.query.szin)
    if (szinId && res.data.termek_szinek?.length) {
      const match = res.data.termek_szinek.find(s => s.id === szinId)
      if (match) selectedColor.value = match
    }
    loading.value = false
  } catch (e) {
    console.error(e)
    loading.value = false
  }
}
function goBack() {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/') // alapértelmezett oldal
  }
}

function addToCart() {
  if (!product.value || product.value.darab === 0) return
  
  const result = cartStore.addToCart({
    ...product.value,
    selectedColor: selectedColor.value
  }, qty.value)
  
  if (result.success && result.added > 0) {
    cartModal.value?.open(product.value, result.added)
    qty.value = 1
  } else if (!result.success) {
    showToast(`⚠️ ${result.message}`, 'error')
  }
}

onMounted(() => {
  fetchProduct()
})
</script>

<style scoped>

.item-page {
  max-width: 1140px;
  margin: 26px auto;
  padding: 28px 24px 60px;
  min-height: 80vh;
  background-color: white;
  border-radius: 24px;
}

/* Back button */
.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: transparent;
  border: 1.5px solid #d4d4d4;
  padding: 8px 18px;
  border-radius: 50px;
  cursor: pointer;
  font-size: 13px;
  font-family: inherit;
  color: #555;
  margin-bottom: 32px;
  transition: all 0.2s;
  letter-spacing: 0.02em;
}
.back-btn:hover {
  background: #f7f7f7;
  border-color: #aaa;
  color: #222;
}
.back-arrow { font-size: 16px; }

/* Loading */
.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 80px;
  color: #888;
  font-size: 15px;
}
.spinner {
  width: 36px; height: 36px;
  border: 3px solid #e5e5e5;
  border-top-color: #50432c;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* Layout */
.product-detail {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 56px;
  align-items: start;
}

.product-detail .product-images {
  grid-column: 1;
}

/* ── GALLERY ── */
.product-images {
  display: flex;
  flex-direction: column;
  gap: 14px;
  position: static;
  top: 24px;
}

.main-image-wrap {
  position: relative;
  border-radius: 16px;
  overflow: hidden;
  background: #f4f4f0;
  aspect-ratio: 1 / 1;
}

.main-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.fade-enter-active, .fade-leave-active { transition: opacity 0.25s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

/* Arrow buttons */
.gallery-arrow {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(255,255,255,0.88);
  border: none;
  border-radius: 50%;
  width: 40px; height: 40px;
  font-size: 22px;
  line-height: 1;
  cursor: pointer;
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 2px 10px rgba(0,0,0,0.12);
  transition: all 0.18s;
  z-index: 2;
}
.gallery-arrow:hover { background: white; box-shadow: 0 4px 16px rgba(0,0,0,0.18); }
.gallery-arrow.left  { left: 12px; }
.gallery-arrow.right { right: 12px; }

/* Dots */
.dots {
  position: absolute;
  bottom: 12px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 6px;
  z-index: 2;
}
.dot {
  width: 7px; height: 7px;
  border-radius: 50%;
  background: rgba(255,255,255,0.55);
  cursor: pointer;
  transition: all 0.2s;
}
.dot.active { background: white; transform: scale(1.3); }

/* Thumbnails */
.thumbnails {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}
.thumb-wrap {
  width: 76px; height: 76px;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  border: 2.5px solid transparent;
  transition: all 0.18s;
  background: #f4f4f0;
}
.thumb-wrap:hover { border-color: #aaa; }
.thumb-wrap.active { border-color: #50452c; }
.thumb { width: 100%; height: 100%; object-fit: cover; display: block; }

/* ── PRODUCT INFO ── */
.product-info {
  display: flex;
  flex-direction: column;
  gap: 0;
  padding-top: 4px;
}

.category-label {
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  color: #999;
  margin-bottom: 10px;
}

.product-info h1 {
  font-family: 'Playfair Display', serif;
  font-size: 30px;
  font-weight: 700;
  color: #1a1a1a;
  line-height: 1.25;
  margin: 0 0 14px 0;
}

.price {
  font-size: 26px;
  font-weight: 700;
  color: #1e5c2e;
  margin: 0 0 20px 0;
  letter-spacing: -0.01em;
}

/* Tags */
.tag-container {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  flex-grow: 0;
}

.item-tag-sm {
  background: #ffebd3;
  color: #a8532b;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 999px;
  cursor: pointer;
  transition: all 0.2s;
}

.item-tag-sm.main-category {
  background: #ff753657;
  color: #a8532b;
}

.item-tag-sm:hover {
  background: #ffc583fd;
  color: #553000;
}

.item-tag-sm:hover.main-category {
  background: #ffa074d2;
  color: #553000;
}


/* Description */
.description {
  color: #666;
  line-height: 1.72;
  font-size: 14.5px;
  margin-bottom: 28px;
  border-top: 1px solid #ebebeb;
  padding-top: 20px;
}

/* Colors */
.colors {
  margin-bottom: 28px;
}

.colors label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  font-size: 14px;
  color: #333;
  margin-bottom: 10px;
}

.selected-color-name {
  font-weight: 400;
  color: #888;
  font-size: 13px;
}

.color-options { display: flex; gap: 8px; flex-wrap: wrap; }
.color-btn {
  width: 34px; height: 34px;
  border-radius: 50%;
  border: 2.5px solid transparent;
  outline: 2px solid transparent;
  cursor: pointer;
  transition: all 0.18s;
}

.color-btn:hover { transform: scale(1.12); outline-color: #ccc; }
.color-btn.active {
  outline: 2.5px solid #2c3e50;
  outline-offset: 3px;
  border-color: white;
}

/* Quantity */
.quantity { margin-bottom: 32px; }
.quantity > label {
  display: block;
  font-weight: 600;
  font-size: 14px;
  color: #333;
  margin-bottom: 10px;
}

.qty-row {
  display: flex;
  align-items: center;
  gap: 20px;
  flex-wrap: wrap;
}

.qty-control {
  display: flex;
  align-items: center;
  border: 1.5px solid #ddd;
  border-radius: 10px;
  overflow: hidden;
}

.qty-btn {
  width: 40px; height: 40px;
  background: #f8f8f8;
  border: none;
  cursor: pointer;
  font-size: 18px;
  font-weight: 600;
  color: #333;
  transition: background 0.15s;
  font-family: inherit;
}

.qty-btn:hover { background: #eee; }
.qty-input {
  width: 52px;
  border: none;
  border-left: 1.5px solid #ddd;
  border-right: 1.5px solid #ddd;
  text-align: center;
  font-size: 15px;
  font-family: inherit;
  padding: 8px 0;
  outline: none;
  background: white;
}

/* Stock */
.stock-info {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #4a7c59;
  font-weight: 500;
  margin: 0;
}

.stock-info.low { color: #b45309; }

.stock-info.out { color: #c0392b; }

.stock-dot {
  width: 7px; height: 7px;
  border-radius: 50%;
  background: currentColor;
  display: inline-block;
}

/* Add to cart */
.add-to-cart-btn {
  padding: 15px 32px;
  background: #b55b3f;
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 15px;
  font-weight: 600;
  font-family: inherit;
  cursor: pointer;
  transition: all 0.22s;
  letter-spacing: 0.02em;
}

.add-to-cart-btn:hover:not(:disabled) {
  background: #81442f;
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(26, 26, 46, 0.28);
}

.add-to-cart-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.error {
  text-align: center;
  color: #888;
  padding: 60px;
  font-size: 16px;
}

/* Responsive */
@media (max-width: 860px) {
  .product-detail {
    grid-template-columns: 1fr;
    gap: 32px;
  }
  .product-images { position: static; }
}
</style>
