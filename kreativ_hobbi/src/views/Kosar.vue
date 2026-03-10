<template>
  <div class="cart-page">
    <!-- Header -->
    <div class="cart-header" style="padding-bottom: 35px;">
      <h1 class="title">Kosarad</h1>
    </div>

    <div v-if="cartItems.length > 0" class="cart-container">
      <!-- Cart Items Section -->
      <div class="cart-items">
        <div class="items-header">
          <span>{{ cartItems.length }} termék</span>
        </div>
        
        <div v-for="item in cartItems" :key="item.id" class="cart-item">
          <div class="item-image-wrapper">
            <img :src="item.termek_fo_kep.url_Link || '/src/assets/Public/placeholder.png'" :alt="item.nev" class="cart-item-image" />
          </div>

          <div class="cart-item-details">
            <h3 class="item-name">{{ item.nev }}</h3>
            <p class="item-price">{{ (item.ar || item.price).toLocaleString('hu-HU') }} Ft</p>
          </div>

          <div class="cart-item-controls">
            <div class="quantity-control">
              <button class="qty-btn minus" @click="decreaseFromCart(item.id)" :disabled="item.quantity <= 1">−</button>
              <input type="number" :min="1" :max="item.darab" class="qty-input" v-model.number="item.quantity" @change="updateQuantity(item.id, item.quantity)" />
              <button class="qty-btn plus" @click="addOne(item.id)" :disabled="item.quantity >= item.darab">+</button>
            </div>
          </div>

          <div class="cart-item-total">
            <p class="total-text">{{ ((item.ar) * item.quantity).toLocaleString('hu-HU') }} Ft</p>
          </div>

          <button @click="removeFromCart(item.id)" class="remove-btn" title="Eltávolít">
            ✕
          </button>
        </div>
      </div>

      <!-- Summary Sidebar -->
      <div class="cart-sidebar">
        <!-- Order Summary -->
        <div class="summary-card">
          <h2 class="summary-title">Rendelés összegzése</h2>
          
          <div class="summary-row">
            <span class="summary-label">Tételek száma:</span>
            <span class="summary-value">{{ cartItems.reduce((t, i) => t + i.quantity, 0) }}</span>
          </div>

          <div class="summary-row total">
            <span class="summary-label">Végösszeg:</span>
            <span class="summary-value-total">{{ cartTotal.toLocaleString('hu-HU') }} Ft</span>
          </div>
        </div>

        <!-- Delivery Form -->
        <div class="delivery-card">
          <h3 class="delivery-title">Szállítási adatok</h3>
          
          <form @submit.prevent="checkout">
            <div class="form-row">
              <div class="form-group">
                <label for="lastName">
                  Vezetéknév *
                  <span v-if="lastNameError" class="error-indicator">⚠</span>
                  <span v-else-if="lastNameValid" class="success-indicator">✓</span>
                </label>
                <input
                  id="lastName"
                  v-model="deliveryDetails.lastName"
                  placeholder="Pl. Nagy"
                  required
                  @blur="validateLastName"
                  @keyup.enter="validateLastName"
                  :class="{ 'input-error': lastNameError, 'input-success': lastNameValid }"
                />
                <span v-if="lastNameError" class="error-message">{{ lastNameError }}</span>
              </div>

              <div class="form-group">
                <label for="firstName">
                  Keresztnév *
                  <span v-if="firstNameError" class="error-indicator">⚠</span>
                  <span v-else-if="firstNameValid" class="success-indicator">✓</span>
                </label>
                <input
                  id="firstName"
                  v-model="deliveryDetails.firstName"
                  placeholder="Pl. János"
                  required
                  @blur="validateFirstName"
                  @keyup.enter="validateFirstName"
                  :class="{ 'input-error': firstNameError, 'input-success': firstNameValid }"
                />
                <span v-if="firstNameError" class="error-message">{{ firstNameError }}</span>
              </div>
            </div>

            <div class="form-group">
              <label for="email">Email Cím *</label>
              <input 
                id="email" 
                type="email" 
                v-model="deliveryDetails.email" 
                placeholder="janos@example.com"
                required
                @blur="validateEmail"
                @keyup.enter="validateEmail"
                :class="{ 'input-error': emailError, 'input-success': emailValid }"
              />
              <span v-if="emailError" class="error-message">{{ emailError }}</span>
            </div>

            <div class="form-group">
              <label for="address">Szállítási Cím *</label>
              <input 
                id="address" 
                v-model="deliveryDetails.address" 
                placeholder="Utca, házszám"
                required
                @blur="validateAddress"
                @keyup.enter="validateAddress"
                :class="{ 'input-error': addressError, 'input-success': addressValid }"
              />
              <span v-if="addressError" class="error-message">{{ addressError }}</span>
            </div>

            <div class="form-group">
              <label for="city">Város *
                <span v-if="cityError" class="error-indicator">⚠</span>
                <span v-else-if="cityValid" class="success-indicator">✓</span>
              </label>
              <Dropdown
                id="city"
                v-model="deliveryDetails.cityId"
                :options="cities"
                optionLabel="varos_nev"
                optionValue="id"
                placeholder="Válassz vagy írj be egy várost"
                :filter="true"
                filterBy="varos_nev,iranyitoszam"
                :showClear="true"
                :loading="loadingCities"
                @change="validateCity"
                :class="{ 'p-invalid': cityError, 'p-success': cityValid }"
                class="w-full"
              >
                <template #value="slotProps">
                  <span v-if="slotProps.value">
                    {{ cities.find(c => c.id === slotProps.value)?.varos_nev }}
                    <span class="irsz-badge">
                      {{ cities.find(c => c.id === slotProps.value)?.iranyitoszam }}
                    </span>
                  </span>
                  <span v-else class="p-placeholder">Válassz vagy írj be egy várost</span>
                </template>

                <!-- A lista elemeinek megjelenítése -->
                <template #option="slotProps">
                  <div class="city-option">
                    <span class="city-name">{{ slotProps.option.varos_nev }}</span>
                    <span class="irsz-badge">{{ slotProps.option.iranyitoszam }}</span>
                  </div>
                </template>
              </Dropdown>
                <span v-if="cityError" class="error-message">{{ cityError }}</span>
            </div>
            <div class="form-group">
              <label for="phone">Telefonszám *</label>
              <input 
                id="phone" 
                v-model="deliveryDetails.phone" 
                placeholder="+36 30 123 4567"
                type="tel"
                pattern="^\+\d{2}\s\d{3}\s\d{3}\s\d{4}$"
                maxlength="15"
                required
                @blur="validatePhone"
                @keyup.enter="validatePhone"
                :class="{ 'input-error': phoneError, 'input-success': phoneValid }"
                inputmode="tel"
                aria-describedby="phoneHelp"
              />
              <span v-if="phoneError" class="error-message">{{ phoneError }}</span>
              <small id="phoneHelp" class="help-text">Formátum: min. 9 számjegy; szóköz, + és - engedélyezett.</small>
            </div>
          </form>
        </div>

        <!-- Action Buttons -->
        <div class="action-buttons">
          <button id="checkout" @click="checkout" class="btn-primary">
            <span>✓</span> Rendelés véglegesítése
          </button>
          <button id="emptyCart" @click="emptyCart(true)" class="btn-secondary">
            <span>🗑</span> Kosár ürítése
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-icon">🛒</div>
      <h2>A kosarad üres</h2>
      <p>Még nincs termék a kosárban. Nézz körül a boltban és válassz szét, amit szívesen megvennél!</p>
      <router-link to="/aruhaz" class="btn-primary">
        <span>→</span> Vissza az Áruházba
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cartStore'
import axios from 'axios';
import Dropdown from 'primevue/dropdown';

const router = useRouter()
const cartStore = useCartStore()
const cartItems = computed(() => cartStore.cartItems)

const deliveryDetails = ref({
  firstName: '',
  lastName: '',
  email: '',
  address: '',
  cityId: null,
  phone: ''
})

const phoneError = ref('')
const phoneValid = ref(false)
const emailError = ref('')
const emailValid = ref(false)
const addressError = ref('')
const addressValid = ref(false)
const lastNameError = ref('')
const lastNameValid = ref(false)
const firstNameError = ref('')
const firstNameValid = ref(false)

const cartTotal = computed(() => {
  return cartItems.value.reduce((s, i) => s + (Number(i.ar || i.price) * Number(i.quantity || 0)), 0)
})

function addOne(id) {
  cartStore.updateQuantity(id, (cartStore.cartItems.find(i => i.id === id)?.quantity || 0) + 1)
}

function decreaseFromCart(id) {
  const item = cartStore.cartItems.find(i => i.id === id)
  if (!item) return
  if (item.quantity > 1) {
    cartStore.updateQuantity(id, item.quantity - 1)
  } else {
    cartStore.removeFromCart(id)
  }
}

function updateQuantity(id, quantity) {
  const idx = cartItems.value.findIndex(i => i.id === id)
  if (idx === -1) return
  const clamped = Math.max(1, Math.min(quantity, cartItems.value[idx].darab ?? Infinity))
  cartItems.value.splice(idx, 1, { ...cartItems.value[idx], quantity: clamped })
}

function removeFromCart(id) {
  cartStore.removeFromCart(id)
}

function emptyCart(confirmPrompt = true) {
  if (confirmPrompt && !confirm('Biztosan üríteni szeretnéd a kosarat?')) return
  cartStore.clearCart()
}

//#region Validation

const cities = ref([])
const cityError = ref('')
const cityValid = ref(false)
const loadingCities = ref(false)

// városok betöltése

onMounted(async () => {
  loadingCities.value = true
  try {
    const res = await axios.get('/api/varosok')
    cities.value = res.data
  } finally {
    loadingCities.value = false
  }
})

function validateCity() {
  if (!deliveryDetails.value.cityId) {
    cityError.value = 'Kérlek válassz várost!'
    cityValid.value = false
    return
  }
  cityError.value = ''
  cityValid.value = true
}

const nameRegex = /^[A-Za-záéíóöőúüűÁÉÍÓÖŐÚÜŰ\-]{2,}(\s[A-Za-záéíóöőúüűÁÉÍÓÖŐÚÜŰ\-]{2,}){0,3}$/

function validateLastName() {
  const value = deliveryDetails.value.lastName.trim()
  if (!value) {
    lastNameError.value = ''
    lastNameValid.value = false
    return
  }
  if (!nameRegex.test(value)) {
    lastNameError.value = 'Csak betűk és max. 3 szóköz engedélyezett (min. 2 karakter)'
    lastNameValid.value = false
    return
  }
  lastNameError.value = ''
  lastNameValid.value = true
}

function validateFirstName() {
  const value = deliveryDetails.value.firstName.trim()
  if (!value) {
    firstNameError.value = ''
    firstNameValid.value = false
    return
  }
  if (!nameRegex.test(value)) {
    firstNameError.value = 'Csak betűk és max. 3 szóköz engedélyezett (min. 2 karakter)'
    firstNameValid.value = false
    return
  }
  firstNameError.value = ''
  firstNameValid.value = true
}

function validatePhone() {
  const value = deliveryDetails.value.phone.trim()  // ← d.phone helyett
  const phoneRegex = /^[+]?[\d\s\-()]{9,15}$/
  
  if (!value) {
    phoneError.value = ''
    phoneValid.value = false
    return
  }

  if (!phoneRegex.test(value)) {
    phoneError.value = 'Érvénytelen telefonszám formátum!'
    phoneValid.value = false
    return
  }

  const digits = value.replace(/\D/g, '')
  if (digits.length < 9) {
    phoneError.value = `Túl rövid (${digits.length}/9 számjegy)`
    phoneValid.value = false
    return
  }

  phoneError.value = ''
  phoneValid.value = true
}

function validateEmail() {
  const value = deliveryDetails.value.email.trim()
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  
  if (!value) {
    emailError.value = ''
    emailError.value = false
    return
  }

  if (!emailRegex.test(value)) {
    emailError.value = 'Érvenytelen email cím!'
    emailValid.value = false
    return
  }

  emailError.value = ''
  emailValid.value = true
}

function validateAddress() {
  const value = deliveryDetails.value.address.trim()
  const addressRegex = /^[A-Za-zÀ-ÖØ-öø-ÿ0-9\s\.\,\-\/]+$/
  if (!value) {
    addressError.value = ''
    addressValid.value = false
    return
  }
  if (!addressRegex.test(value)) {
    addressError.value = 'Érvénytelen cím formátum!'
    addressValid.value = false
    return
  }
  if (value.length < 5) {
    addressError.value = 'Túl rövid (min 5 karakter)'
    addressValid.value = false
    return
  }
  addressError.value = ''
  addressValid.value = true
}

//#endregion

const payload = ref({})
async function checkout() {
  const currentCart = (cartItems && cartItems.value) ? cartItems.value : (cartStore && cartStore.cartItems ? cartStore.cartItems : [])
  if (!currentCart.length) {
    alert('A kosarad üres')
    return
  }

  // Készlet ellenőrzés az API-n keresztül
  try {
    for (const item of currentCart) {
      const res = await axios.get(`/api/termekek/${item.id}`)
      const freshItem = res.data
      if (freshItem.darab < item.quantity) {
        alert(`"${item.nev}" termékből csak ${freshItem.darab} db érhető el, de ${item.quantity} db van a kosárban!`)
        // Frissítsd a kosarat a valós készlettel
        if (freshItem.darab === 0) {
          cartStore.removeFromCart(item.id)
        } else {
          cartStore.updateStock(item.id, freshItem.darab)
        }
        return
      }
    }
  } catch (e) {
    alert('Hiba történt a készlet ellenőrzése közben!')
    return
  }

  const d = deliveryDetails.value
  if (!d.firstName || !d.lastName || !d.email || !d.address || !d.cityId || !d.phone) {
    alert('Kérlek töltsd ki az összes szállítási adatot')
    return
  }

  // Vezetéknév validáció
  validateFirstName()
  if (!firstNameValid.value) {
    alert('A vezetéknév nem érvényes!')
    return
  }

  // Keresztéknév validáció
  validateLastName()
  if (!lastNameValid.value) {
    alert('A keresztéknév nem érvenytes!')
    return
  }

  // Egyszerű telefonszám ellenőrzés: legalább 9 számjegy
  validatePhone()
  if (!phoneValid.value) {
    alert('A telefonszám nem érvényes!')
    return
  }

  // Email ellenörzés
  validateEmail()
  if (!emailValid.value) {
    alert('Az email ciém nem érvenytelen!')
    return
  }

  // Fizetés adatok
  payload.value = {
    delivery: {
      name:    `${d.lastName} ${d.firstName}`,
      address: d.address,
      email:   d.email,
      phone:   d.phone,
      city_id: d.cityId,         
    },
    items: currentCart.map(i => ({
      id:       i.id,
      mennyiseg: i.quantity,
      szin_id:  i.selectedColor?.id ?? null
    }))
  }
  try {
    const res = await axios.post('/api/rendeles', payload.value);
    router.push({ path: `/kosar/fizetes/${res.data.rendeles_id}`});
  } catch (e) {
    console.warn('bug:', e)
  }
}
</script>

<style scoped>
* { box-sizing: border-box; }

.cart-page {
  min-height: 100vh;
  padding: 40px 24px;
}

.title {
  display: inline-block;
  font-weight: 700;
  font-size: 45px;
  color: var(--mk-text-dark);
  background-image: linear-gradient(90deg, #f08686, #853303);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
}

/* Header */
.cart-header {
  text-align: center;
  margin-bottom: 48px;
  animation: slideDown 0.6s ease-out;
}

.cart-header h1 {
  font-size: 2.5rem;
  color: #1a2332;
  margin: 0 0 8px 0;
  font-weight: 700;
  letter-spacing: -0.5px;
}

.header-subtitle {
  color: #6b7280;
  font-size: 16px;
  margin: 0;
}

/* Main Container */
.cart-container {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  gap: 32px;
  align-items: flex-start;
}

/* Cart Items Section */
.cart-items {
  flex: 1;
}

.items-header {
  background: white;
  padding: 16px 20px;
  border-radius: 12px 12px 0 0;
  border-bottom: 2px solid #f0f1f3;
  font-weight: 600;
  color: #2c3e50;
  font-size: 14px;
}

.cart-item {
  background: white;
  border: 1px solid #e5e7eb;
  border-top: none;
  padding: 20px;
  display: flex;
  gap: 20px;
  align-items: center;
  transition: all 0.3s ease;
  position: relative;
}

.cart-item:last-child {
  border-radius: 0 0 12px 12px;
}

.cart-item:hover {
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  transform: translateY(-2px);
}

.item-image-wrapper {
  flex-shrink: 0;
}

.cart-item-image {
  width: 120px;
  height: 120px;
  object-fit: cover;
  border-radius: 10px;
  background: #f3f4f6;
}

.cart-item-details {
  flex: 1;
  text-align: left;
}

.item-name {
  margin: 0 0 8px 0;
  font-size: 18px;
  font-weight: 600;
  color: #1a2332;
}

.item-price {
  margin: 0;
  color: #059669;
  font-size: 16px;
  font-weight: 700;
}

.cart-item-controls {
  display: flex;
  align-items: center;
}

.quantity-control {
  display: flex;
  align-items: center;
  background: #f3f4f6;
  border-radius: 8px;
  overflow: hidden;
}

.qty-btn {
  background: white;
  border: none;
  width: 36px;
  height: 36px;
  cursor: pointer;
  font-weight: 600;
  color: #3f51b5;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.qty-btn:hover:not(:disabled) {
  background: #3f51b5;
  color: white;
}

.qty-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.qty-input {
  width: 50px;
  height: 36px;
  border: none;
  background: #f3f4f6;
  text-align: center;
  font-weight: 600;
  color: #1a2332;
  font-size: 14px;
}

.qty-input:focus {
  outline: none;
  background: white;
}

.cart-item-total {
  text-align: right;
  min-width: 120px;
  flex-shrink: 0;
}

.total-text {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: #1a2332;
}

.remove-btn {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #fee2e2;
  border: none;
  color: #dc2626;
  cursor: pointer;
  font-size: 20px;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.remove-btn:hover {
  background: #dc2626;
  color: white;
  transform: scale(1.1);
}

/* Sidebar */
.cart-sidebar {
  width: 380px;
  position: sticky;
  top: 20px;
}

.summary-card,
.delivery-card {
  background: white;
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 20px;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  border: 1px solid #e5e7eb;
}

.summary-title,
.delivery-title {
  margin: 0 0 20px 0;
  font-size: 18px;
  font-weight: 700;
  color: #1a2332;
}

.summary-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  font-size: 14px;
}

.summary-label {
  color: #6b7280;
  font-weight: 500;
}

.summary-value {
  color: #1a2332;
  font-weight: 600;
}

.summary-row.total {
  padding: 16px 0 0 0;
  border-top: 2px solid #f0f1f3;
  font-size: 16px;
}

.summary-value-total {
  color: #059669;
  font-weight: 700;
  font-size: 20px;
}

/* Delivery Form */
.delivery-card form {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group label {
  font-size: 12px;
  font-weight: 700;
  color: #4b5563;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.form-group input {
  padding: 12px 14px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  font-size: 14px;
  color: #1a2332;
  transition: all 0.2s;
  background: #f9fafb;
  width: 100%;
}

.form-group input:focus {
  outline: none;
  border-color: #3f51b5;
  background: white;
  box-shadow: 0 0 0 3px rgba(63, 81, 181, 0.1);
}

.form-group input::placeholder {
  color: #9ca3af;
}

.form-group input.input-error {
  border-color: #dc2626 !important;
  background: #fef2f2 !important;
}

.form-group input.input-error:focus {
  box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1) !important;
}

.form-group input.input-success {
  border-color: #059669 !important;
  background: #f0fdf4 !important;
}

.form-group input.input-success:focus {
  box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.1) !important;
}

.error-message {
  font-size: 12px;
  color: #dc2626;
  font-weight: 600;
  margin-top: 4px;
  display: block;
  animation: shake 0.3s ease-in-out;
}

.error-indicator {
  color: #dc2626;
  margin-left: 6px;
  font-weight: bold;
}

.success-indicator {
  color: #059669;
  margin-left: 6px;
  font-weight: bold;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-4px); }
  75% { transform: translateX(4px); }
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.btn-primary,
.btn-secondary{
  padding: 14px 24px;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  text-decoration: none;
  text-align: center;
}

.btn-primary {
  background:  #2ac403;
  color: white;
  box-shadow: 0 4px 16px rgba(39, 100, 23, 0.3);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(17, 70, 1, 0.4);
}

.btn-primary:active {
  transform: translateY(0);
}

.btn-secondary {
  background: white;
  color: #dc2626;
  border: 2px solid #fecaca;
  box-shadow: 0 2px 8px rgba(220, 38, 38, 0.1);
}

.btn-secondary:hover {
  background: #fee2e2;
  border-color: #dc2626;
}

/* Empty State */
.empty-state {
  text-align: center;
  background: white;
  border-radius: 16px;
  padding: 60px 40px;
  max-width: 500px;
  margin: 0 auto;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}

.empty-icon {
  font-size: 80px;
  margin-bottom: 24px;
  display: block;
}

.empty-state h2 {
  margin: 0 0 12px 0;
  color: #1a2332;
  font-size: 28px;
}

.empty-state p {
  margin: 0 0 32px 0;
  color: #6b7280;
  line-height: 1.6;
}

.empty-state .btn-primary {
  max-width: 100%;
  margin: 0 auto;
  display: inline-flex;
}

/* Animations */
@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Responsive */
@media (max-width: 900px) {
  .cart-container {
    flex-direction: column;
    gap: 24px;
  }

  .cart-sidebar {
    width: 100%;
    position: static;
  }

  .cart-header h1 {
    font-size: 2rem;
  }

  .cart-item {
    flex-wrap: wrap;
  }

  .form-row {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 600px) {
  .cart-page {
    padding: 24px 16px;
  }

  .cart-header h1 {
    font-size: 1.5rem;
  }

  .cart-item {
    padding: 16px;
    gap: 12px;
  }

  .cart-item-image {
    width: 100px;
    height: 100px;
  }

  .item-name {
    font-size: 16px;
  }

  .summary-card,
  .delivery-card {
    padding: 18px;
  }

  .btn-primary,
  .btn-secondary {
    padding: 12px 16px;
    font-size: 14px;
  }

  .empty-state {
    padding: 40px 20px;
  }

  .empty-icon {
    font-size: 60px;
  }

  .empty-state h2 {
    font-size: 22px;
  }
}
:deep(.p-dropdown) {
  width: 100%;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  background: #f9fafb;
  transition: all 0.2s;
}

:deep(.p-dropdown:hover),
:deep(.p-dropdown.p-focus) {
  border-color: #3f51b5;
  background: white;
  box-shadow: 0 0 0 3px rgba(63, 81, 181, 0.1);
}

:deep(.p-dropdown.p-invalid) {
  border-color: #dc2626;
  background: #fef2f2;
}

:deep(.p-dropdown.p-success) {
  border-color: #059669;
  background: #f0fdf4;
}

:deep(.p-dropdown .p-dropdown-label) {
  font-size: 14px;
  color: #1a2332;
  padding: 12px 14px;
}

.city-option {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  width: 100%;
}

.city-name {
  font-weight: 500;
  color: #1a2332;
}

.irsz-badge {
  font-size: 12px;
  color: #6b7280;
  background: #f3f4f6;
  padding: 2px 8px;
  border-radius: 999px;
  font-weight: 600;
  flex-shrink: 0;
}
</style>
