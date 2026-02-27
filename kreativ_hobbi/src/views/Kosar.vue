<template>
  <div class="cart-page">
    <!-- Header -->
    <div class="cart-header">
      <h1>🛒 kosarad</h1>
      <p class="header-subtitle">Ellenőrizd a termékeket és fejezd be a rendelésed</p>
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
          <h2 class="summary-title">Rendelés Összegzés</h2>
          
          <div class="summary-row">
            <span class="summary-label">Tételek száma:</span>
            <span class="summary-value">{{ cartItems.reduce((t, i) => t + i.quantity, 0) }}</span>
          </div>

          <div class="summary-divider"></div>

          <div class="summary-row total">
            <span class="summary-label">Végösszeg:</span>
            <span class="summary-value-total">{{ cartTotal.toLocaleString('hu-HU') }} Ft</span>
          </div>
        </div>

        <!-- Delivery Form -->
        <div class="delivery-card">
          <h3 class="delivery-title">Szállítási Adatok</h3>
          
          <form @submit.prevent="checkout">
            <div class="form-group">
              <label for="fullName">Teljes Név *</label>
              <input 
                id="fullName" 
                v-model="deliveryDetails.fullName" 
                placeholder="Pl. Nagy János"
                required 
              />
            </div>

            <div class="form-group">
              <label for="email">Email Cím *</label>
              <input 
                id="email" 
                type="email" 
                v-model="deliveryDetails.email" 
                placeholder="janos@example.com"
                required 
              />
            </div>

            <div class="form-group">
              <label for="address">Szállítási Cím *</label>
              <input 
                id="address" 
                v-model="deliveryDetails.address" 
                placeholder="Utca, házszám"
                required 
              />
            </div>

            <div class="form-row">
              <div class="form-group">
                <label for="city">Város *</label>
                <input 
                  id="city" 
                  v-model="deliveryDetails.city" 
                  placeholder="Budapest"
                  required 
                />
              </div>
              <div class="form-group">
                <label for="zipCode">
                  Irányítószám *
                  <span v-if="zipCodeError" class="error-indicator">⚠</span>
                  <span v-else-if="zipCodeValid" class="success-indicator">✓</span>
                </label>
                <input 
                  id="zipCode" 
                  v-model="deliveryDetails.zipCode" 
                  type="text"
                  placeholder="1000"
                  required 
                  @blur="validateZipCode"
                  @keyup.enter="validateZipCode"
                  :class="{ 'input-error': zipCodeError, 'input-success': zipCodeValid }"
                  maxlength="5"
                />
                <span v-if="zipCodeError" class="error-message">{{ zipCodeError }}</span>
              </div>
            </div>

            <div class="form-group">
              <label for="phone">Telefonszám *</label>
              <input 
                id="phone" 
                v-model="deliveryDetails.phone" 
                placeholder="+36 30 123 4567"
                required 
                inputmode="tel"
                aria-describedby="phoneHelp"
              />
              <small id="phoneHelp" class="help-text">Formátum: min. 9 számjegy; szóköz, + és - engedélyezett.</small>
            </div>
          </form>
        </div>

        <!-- Action Buttons -->
        <div class="action-buttons">
          <button id="checkout" @click="checkout" class="btn-primary">
            <span>✓</span> Rendelés Véglegesítése
          </button>
          <button id="emptyCart" @click="emptyCart(true)" class="btn-secondary">
            <span>🗑</span> Kosár Ürítése
          </button>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="empty-state">
      <div class="empty-icon">🛒</div>
      <h2>A kosárod üres</h2>
      <p>Még nincs termék a kosárban. Nézz körül a boltban és válassz szét, amit szívesen megvennél!</p>
      <router-link to="/aruhaz" class="btn-primary">
        <span>→</span> Vissza az Áruházba
      </router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, provide } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cartStore'

const router = useRouter()
const cartStore = useCartStore()
const cartItems = computed(() => cartStore.cartItems)

const deliveryDetails = ref({
  fullName: '',
  email: '',
  address: '',
  city: '',
  zipCode: '',
  phone: ''
})

const zipCodeError = ref('')
const zipCodeValid = ref(false)

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

function updateQuantity(id, value) {
  cartStore.updateQuantity(id, value)
}

function removeFromCart(id) {
  cartStore.removeFromCart(id)
}

function emptyCart(confirmPrompt = true) {
  if (confirmPrompt && !confirm('Biztosan üríteni szeretnéd a kosarat?')) return
  cartStore.clearCart()
}

function validateZipCode() {
  const value = deliveryDetails.value.zipCode.trim()
  
  // Üres érték - nincs hiba, csak nem valid
  if (!value) {
    zipCodeError.value = ''
    zipCodeValid.value = false
    return
  }

  // Csak számokat engedünk meg
  if (!/^\d+$/.test(value)) {
    zipCodeError.value = 'Csak számok engedélyezve!'
    zipCodeValid.value = false
    return
  }

  // Hossz ellenőrzés - magyar irányítószámok 4-5 számjegyűek
  if (value.length < 4) {
    zipCodeError.value = `Túl rövid (${value.length}/4-5 számjegy)`
    zipCodeValid.value = false
    return
  }

  if (value.length > 5) {
    zipCodeError.value = 'Túl hosszú (max 5 számjegy)'
    zipCodeValid.value = false
    return
  }

  // Sikeres validáció
  zipCodeError.value = ''
  zipCodeValid.value = true
}

const payload = ref({})
async function checkout() {
  const currentCart = (cartItems && cartItems.value) ? cartItems.value : (cartStore && cartStore.cartItems ? cartStore.cartItems : [])
  if (!currentCart.length) {
    alert('A kosarad üres')
    return
  }
  const d = deliveryDetails.value
  if (!d.fullName || !d.email || !d.address || !d.city || !d.zipCode || !d.phone) {
    alert('Kérlek töltsd ki az összes szállítási adatot')
    return
  }

  // Irányítószám validáció a checkout előtt
  if (!zipCodeValid.value) {
    alert('Az irányítószám nem érvényes!\n\nMagyar irányítószámok: 4-5 számjegy')
    return
  }

  // Egyszerű telefonszám ellenőrzés: legalább 9 számjegy
  const phoneDigits = (d.phone || '').replace(/\D/g, '')
  if (phoneDigits.length < 9) {
    alert('A telefonszám érvénytelen (minimum 9 számjegy).')
    return
  }

  payload.value = {
    delivery: { name: d.fullName, address: d.address, zip: d.zipCode, email: d.email, phone: d.phone, city: d.city },
    items: currentCart.map(i => ({ id: i.id, mennyiseg: i.quantity, szin_id: i.selectedColor?.id ?? null }))
  }

  // Persist payload across routes (provide/inject doesn't work across route navigation)
  try {
    sessionStorage.setItem('orderPayload', JSON.stringify(payload.value))
  } catch (e) {
    console.warn('Could not persist order payload to sessionStorage', e)
  }

  router.push({ path: '/kosar/fizetes' })
}
</script>

<style scoped>
* { box-sizing: border-box; }

.cart-page {
  min-height: 100vh;
  padding: 40px 24px;
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

.summary-divider {
  height: 1px;
  background: #e5e7eb;
  margin: 16px 0;
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
.btn-secondary {
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
  background:  #0fe020;
  color: white;
  box-shadow: 0 4px 16px rgba(63, 81, 181, 0.3);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(63, 81, 181, 0.4);
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
</style>
