<template>
<div class="item-page">
    <button @click="goBack" class="back-btn">← Vissza</button>

    <div v-if="loading" class="loading">Betöltés...</div>
    <div v-else-if="product" class="product-detail">
        <div class="product-images">
        <img :src="product.termek_fo_kep?.url_Link" :alt="product.nev" class="main-image" />
        <div v-if="product.termekKepek && product.termekKepek.length > 0" class="thumbnails">
        <img v-for="kep in product.termekKepek" :key="kep.id" :src="kep.url_Link" :alt="product.nev" class="thumb" @click="mainImage = kep.url_Link" />
        </div>
    </div>

    <div class="product-info">
        <h1>{{ product.nev }}</h1>
        <p class="price">{{ product.ar }} Ft</p>

        <div class="tags" v-if="product.termek_cimkek && product.termek_cimkek.length > 0">
            <span v-for="tag in product.termek_cimkek" :key="tag.id" class="tag">{{ tag.nev }}</span>
        </div>

        <p class="description">{{ product.leiras }}</p>

        <div v-if="product.termek_szinek && product.termek_szinek.length > 0" class="colors">
        <label>Szín:</label>
            <div class="color-options">
                <button v-for="szin in product.termek_szinek" :key="szin.id" 
                    class="color-btn" 
                    :style="{ backgroundColor: szin.hex_kod || '#ccc' }"
                    :title="szin.szin_nev"
                    @click="selectedColor = szin"
                    :class="{ active: selectedColor?.id === szin.id }">
                </button>
            </div>
        </div>

        <div class="quantity">
          <label>Mennyiség:</label>
          <div class="qty-control">
            <button @click="qty > 1 && qty--" class="qty-btn">-</button>
            <input v-model.number="qty" name="darab" type="number" :min="1" :max="product.darab" class="qty-input" />
            <button @click="qty < product.darab && qty++" class="qty-btn">+</button>
          </div>
          <p class="stock-info" :class="{ low: product.darab < 5 }">
            Raktáron: {{ product.darab }} db
          </p>
        </div>

        <button @click="addToCart" class="add-to-cart-btn" :disabled="product.darab === 0">
          {{ product.darab > 0 ? 'Kosárba' : 'Elfogyott' }}
        </button>
      </div>
    </div>

    <p v-else class="error">Termék nem található</p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

const route = useRoute()
const router = useRouter()

const product = ref(null)
const loading = ref(true)
const qty = ref(1)
const selectedColor = ref(null)
const mainImage = ref('')

async function fetchProduct() {
  try {
    const id = route.params.id
    const res = await axios.get(`/api/termekek/${id}`)
    product.value = res.data
    mainImage.value = res.data.termek_fo_kep?.url_Link
    if (res.data.termek_szinek && res.data.termek_szinek.length > 0) {
      selectedColor.value = res.data.termek_szinek[0]
    }
    loading.value = false
  } catch (e) {
    console.error(e)
    loading.value = false
  }
}
function goBack() {
  router.push('/aruhaz')
}

onMounted(() => {
  fetchProduct()
})
</script>

<style scoped>
.item-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 24px;
  min-height: 80vh;
}

.back-btn {
  background: white;
  border: 1px solid #ddd;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  margin-bottom: 24px;
  font-size: 14px;
}

.back-btn:hover {
  background: #f5f5f5;
}

.loading, .error {
  text-align: center;
  font-size: 18px;
  color: #666;
  padding: 40px;
}

.product-detail {
  display: flex;
  gap: 48px;
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.product-images {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.main-image {
  width: 100%;
  max-height: 500px;
  object-fit: cover;
  border-radius: 10px;
  background: #f8f8f8;
}

.thumbnails {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.thumb {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  cursor: pointer;
  border: 2px solid transparent;
  transition: border-color 0.2s;
}

.thumb:hover {
  border-color: #3f51b5;
}

.product-info {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.product-info h1 {
  font-size: 28px;
  margin: 0 0 12px 0;
  color: #2c3e50;
}

.price {
  font-size: 24px;
  font-weight: 700;
  color: #2e7d32;
  margin: 0 0 16px 0;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.tag {
  background: #e3e8ff;
  color: #2b3ea8;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 13px;
}

.description {
  color: #556;
  line-height: 1.6;
  margin-bottom: 20px;
}

.colors {
  margin-bottom: 24px;
}

.colors label {
  display: block;
  font-weight: 600;
  margin-bottom: 8px;
}

.color-options {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.color-btn {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: 2px solid #ddd;
  cursor: pointer;
  transition: all 0.2s;
}

.color-btn.active {
  border-color: #2c3e50;
  box-shadow: 0 0 0 2px white, 0 0 0 4px #2c3e50;
}

.color-btn:hover {
  transform: scale(1.1);
}

.quantity {
  margin-bottom: 24px;
}

.quantity label {
  display: block;
  font-weight: 600;
  margin-bottom: 8px;
}

.qty-control {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-bottom: 8px;
}

.qty-btn {
  width: 36px;
  height: 36px;
  border: 1px solid #cfcfcf;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
}

.qty-btn:hover {
  border-color: #3f51b5;
  background: #f5f5f5;
}

.qty-input {
  width: 60px;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 8px;
  text-align: center;
  font-size: 16px;
}

.stock-info {
  font-size: 13px;
  color: #556;
  margin: 0;
}

.stock-info.low {
  color: #d97706;
  font-weight: 600;
}

.add-to-cart-btn {
  padding: 14px 28px;
  background: #3f51b5;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: auto;
}

.add-to-cart-btn:hover:not(:disabled) {
  background: #2f3fa3;
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(63, 81, 181, 0.3);
}

.add-to-cart-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@media (max-width: 900px) {
  .product-detail {
    flex-direction: column;
    gap: 24px;
  }

  .product-images {
    max-width: 100%;
  }

  .main-image {
    max-height: 400px;
  }
}
</style>
