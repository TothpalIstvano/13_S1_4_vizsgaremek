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
                  autocomplete="family-name"
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
                  autocomplete="given-name"
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
                autocomplete="email"
                @blur="validateEmail"
                @keyup.enter="validateEmail"
                :class="{ 'input-error': emailError, 'input-success': emailValid }"
              />
              <span v-if="emailError" class="error-message">{{ emailError }}</span>
            </div>

            <div class="form-group">
              <label for="utca">
                Utca *
                <span v-if="utcaError" class="error-indicator">⚠</span>
                <span v-else-if="utcaValid" class="success-indicator">✓</span>
              </label>
              <input
                id="utca"
                v-model="deliveryDetails.utca"
                placeholder="Pl. Kossuth Lajos utca"
                autocomplete="address-line1"
                required
                @blur="validateUtca"
                @keyup.enter="validateUtca"
                :class="{ 'input-error': utcaError, 'input-success': utcaValid }"
              />
              <span v-if="utcaError" class="error-message">{{ utcaError }}</span>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label for="hazszam">
                  Házszám *
                  <span v-if="hazszamError" class="error-indicator">⚠</span>
                  <span v-else-if="hazszamValid" class="success-indicator">✓</span>
                </label>
                  <input
                    id="hazszam"
                    v-model="deliveryDetails.hazszam"
                    type="text"
                    placeholder="Pl. 12, 12/A, 14B"
                    autocomplete="address-line2"
                    required
                    @blur="validateHazszam"
                    @keyup.enter="validateHazszam"
                    :class="{ 'input-error': hazszamError, 'input-success': hazszamValid }"
                  />
                <span v-if="hazszamError" class="error-message">{{ hazszamError }}</span>
              </div>

              <div class="form-group">
                <label for="emeletAjto">
                  Emelet / Ajtó
                  <span v-if="emeletAjtoError" class="error-indicator">⚠</span>
                  <span v-else-if="emeletAjtoValid" class="success-indicator">✓</span>
                </label>
                <input
                  id="emeletAjto"
                  v-model="deliveryDetails.emeletAjto"
                  placeholder="Pl. 2/B"
                  maxlength="10"
                  autocomplete="address-line3"
                  @blur="validateEmeletAjto"
                  @input="validateEmeletAjto"
                  :class="{ 'input-error': emeletAjtoError, 'input-success': emeletAjtoValid }"
                />
                <span v-if="emeletAjtoError" class="error-message">{{ emeletAjtoError }}</span>
              </div>
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
                :virtualScrollerOptions="{ itemSize: 38 }"
                :filterDelay="300"
                filterBy="varos_nev,iranyitoszam"
                :filterFields="['varos_nev', 'iranyitoszam']"
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
              <label for="phone">Telefonszám *
                <span v-if="phoneError" class="error-indicator">⚠</span>
                <span v-else-if="phoneValid" class="success-indicator">✓</span>
              </label>
                <input 
                  id="phone" 
                  v-model="deliveryDetails.phone" 
                  placeholder="+36 30 123 4567"
                  type="tel"
                  maxlength="20"
                  autocomplete="tel"
                  required
                  @blur="validatePhone"
                  @input="validatePhone"
                  :class="{ 'input-error': phoneError, 'input-success': phoneValid }"
                  inputmode="tel"
                  aria-describedby="phoneHelp"
                />
              <span v-if="phoneError" class="error-message">{{ phoneError }}</span>
              <small id="phoneHelp" class="help-text">
                Pl. +36 30 123 4567 vagy +1 800 555 0100 — 7–15 számjegy
              </small>
            </div>
            <div class="form-group toggle-group" v-if="userLogged">
              <label class="toggle-label" for="mentes">Szállítási adatok mentése</label>
              <label class="toggle-switch">
                <input type="checkbox" name="mentes" id="mentes" v-model="deliveryDetails.mentes" />
                <span class="toggle-slider"></span>
              </label>
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
    <Teleport to="body">
      <div v-if="confirmModal.visible" class="confirm-backdrop" @click.self="confirmNo">
        <div class="confirm-modal">
          <p class="confirm-message">{{ confirmModal.message }}</p>
          <div class="confirm-actions">
            <button class="confirm-btn cancel" @click="confirmNo">Mégse</button>
            <button class="confirm-btn danger" @click="confirmYes">Törlés</button>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, inject } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cartStore'
import axios from 'axios';
import Dropdown from 'primevue/dropdown';
import { parsePhoneNumberFromString, isValidPhoneNumber } from 'libphonenumber-js';

const router = useRouter()
const cartStore = useCartStore()
const cartItems = computed(() => cartStore.cartItems)

const deliveryDetails = ref({
  firstName: '',
  lastName: '',
  email: '',
  cityId: null,
  utca: '',
  hazszam: null,
  emeletAjto: '',
  phone: '',
  mentes: false
})

const phoneError = ref('')
const phoneValid = ref(false)
const emailError = ref('')
const emailValid = ref(false)
const lastNameError = ref('')
const lastNameValid = ref(false)
const firstNameError = ref('')
const firstNameValid = ref(false)
const userLogged = ref(false)
const utcaError = ref('')
const utcaValid = ref(false)
const hazszamError = ref('')
const hazszamValid = ref(false)
const emeletAjtoError = ref('')
const emeletAjtoValid = ref(false)
const { showToast, showErrorModal } = inject('toast')

const cartTotal = computed(() => {
  return cartItems.value.reduce((s, i) => s + (Number(i.ar || i.price) * Number(i.quantity || 0)), 0)
})

// Confirm modal saját állapot
const confirmModal = ref({ visible: false, message: '', resolve: null })

function showConfirm(message) {
  return new Promise((resolve) => {
    confirmModal.value = { visible: true, message, resolve }
  })
}
function confirmYes() { confirmModal.value.resolve(true);  confirmModal.value.visible = false }
function confirmNo()  { confirmModal.value.resolve(false); confirmModal.value.visible = false }

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

async function emptyCart(confirmPrompt = true) {
  if (confirmPrompt) {
    const confirmed = await showConfirm('Biztosan üríteni szeretnéd a kosarat?')
    if (!confirmed) return
  }
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
    cities.value = res.data.map(c => ({
      ...c,
      iranyitoszam: String(c.iranyitoszam)
    }))
  } finally {
    loadingCities.value = false
  }

  // user adatok betöltése
  const check = await axios.get('/api/user/check', { withCredentials: true })
  userLogged.value = check.data.loggedIn
  if(userLogged.value) {
    try {
      const user = await axios.get('/api/user/szallitasi-adatok', { withCredentials: true })
      const a = user.data
      if (a) {
        deliveryDetails.value.lastName  = a.vezeteknev  ?? ''
        deliveryDetails.value.firstName = a.keresztnev  ?? ''
        deliveryDetails.value.cityId    = a.varos        ?? null
        deliveryDetails.value.utca       = a.utca        ?? ''
        deliveryDetails.value.hazszam    = a.hazszam     ?? null
        deliveryDetails.value.emeletAjto = a.emeletAjto  ?? ''
        deliveryDetails.value.email     = a.email        ?? ''
        deliveryDetails.value.phone     = a.telefonszam  ?? ''
        deliveryDetails.value.mentes    = true
      }
    } catch {
      // ignore
    }
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

function validateUtca() {
  const value = deliveryDetails.value.utca.trim()

  if (!value) {
    utcaError.value = ''
    utcaValid.value = false
    return
  }
  if (value.length < 3) {
    utcaError.value = 'Túl rövid (min. 3 karakter)'
    utcaValid.value = false
    return
  }
  if (value.length > 100) {
    utcaError.value = 'Túl hosszú (max. 100 karakter)'
    utcaValid.value = false
    return
  }
  // Csak betű, szám, szóköz, pont, kötőjel engedélyezett
  const utcaRegex = /^[A-Za-záéíóöőúüűÁÉÍÓÖŐÚÜŰ0-9\s.\-\/]+$/
  if (!utcaRegex.test(value)) {
    utcaError.value = 'Érvénytelen karakter az utca nevében'
    utcaValid.value = false
    return
  }
  // Legalább egy betű legyen benne
  if (!/[A-Za-záéíóöőúüűÁÉÍÓÖŐÚÜŰ]/.test(value)) {
    utcaError.value = 'Az utca nevének tartalmaznia kell legalább egy betűt'
    utcaValid.value = false
    return
  }
  utcaError.value = ''
  utcaValid.value = true
}

function validateHazszam() {
  const value = String(deliveryDetails.value.hazszam ?? '').trim()

  if (!value) {
    hazszamError.value = ''
    hazszamValid.value = false
    return
  }
  // Elfogad: 12, 12A, 12/A, 12-14, 14/B, 2a stb.
  const hazszamRegex = /^[1-9]\d{0,4}([\/\-]?[A-Za-z0-9]{1,4})?$/
  if (!hazszamRegex.test(value)) {
    hazszamError.value = 'Érvénytelen házszám (pl. 12, 12/A, 14B, 12-14)'
    hazszamValid.value = false
    return
  }
  hazszamError.value = ''
  hazszamValid.value = true
}

function validateEmeletAjto() {
  const value = deliveryDetails.value.emeletAjto.trim()

  if (!value) {
    emeletAjtoError.value = ''
    emeletAjtoValid.value = false
    return
  }
  if (value.length > 20) {
    emeletAjtoError.value = 'Túl hosszú (max. 20 karakter)'
    emeletAjtoValid.value = false
    return
  }
  // Elfogad: 2/B, 3. emelet, fsz., I/4, 12a stb.
  const emeletRegex = /^[A-Za-záéíóöőúüűÁÉÍÓÖŐÚÜŰ0-9\s\/.\-]{1,20}$/
  if (!emeletRegex.test(value)) {
    emeletAjtoError.value = 'Érvénytelen karakter (betű, szám, /, ., - és szóköz engedélyezett)'
    emeletAjtoValid.value = false
    return
  }
  emeletAjtoError.value = ''
  emeletAjtoValid.value = true
}

const nameRegex = /^[A-Za-záéíóöőúüűÁÉÍÓÖŐÚÜŰ]{2,}([- ][A-Za-záéíóöőúüűÁÉÍÓÖŐÚÜŰ]{2,}){0,4}$/

function validateLastName() {
  const value = deliveryDetails.value.lastName.trim()
  if (!value) {
    lastNameError.value = ''
    lastNameValid.value = false
    return
  }
  if (value.length > 50) {
    lastNameError.value = 'Túl hosszú (max. 50 karakter)'
    lastNameValid.value = false
    return
  }
  if (/[-]{2,}/.test(value) || /\s{2,}/.test(value)) {
    lastNameError.value = 'Nem szerepelhet egymás után két kötőjel vagy szóköz'
    lastNameValid.value = false
    return
  }
  if (!nameRegex.test(value)) {
    lastNameError.value = 'Csak betűk, kötőjel és szóköz engedélyezett (min. 2 karakter)'
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
  if (value.length > 50) {
    firstNameError.value = 'Túl hosszú (max. 50 karakter)'
    firstNameValid.value = false
    return
  }
  if (/[-]{2,}/.test(value) || /\s{2,}/.test(value)) {
    firstNameError.value = 'Nem szerepelhet egymás után két kötőjel vagy szóköz'
    firstNameValid.value = false
    return
  }
  if (!nameRegex.test(value)) {
    firstNameError.value = 'Csak betűk, kötőjel és szóköz engedélyezett (min. 2 karakter)'
    firstNameValid.value = false
    return
  }
  firstNameError.value = ''
  firstNameValid.value = true
}

function normalizePhone(raw) {
  const trimmed = raw.trim()
  // 06-os magyar → +36
  if (/^06\d/.test(trimmed)) return '+36' + trimmed.slice(2)
  // 006-os → +6 (pl. 0036 → +36)
  if (/^006\d/.test(trimmed)) return '+' + trimmed.slice(2)
  // 00-ás nemzetközi prefix → +
  if (/^00\d/.test(trimmed)) return '+' + trimmed.slice(2)
  return trimmed
}

function validatePhone() {
  const raw = deliveryDetails.value.phone.trim()

  if (!raw) {
    phoneError.value = ''
    phoneValid.value = false
    return
  }

  const allowedChars = /^[+\d\s\-().]+$/
  if (!allowedChars.test(raw)) {
    phoneError.value = 'Csak számok, +, -, szóköz és zárójelek engedélyezettek'
    phoneValid.value = false
    return
  }

  const digits = raw.replace(/\D/g, '')
  if (digits.length < 7) {
    phoneError.value = 'Túl rövid – legalább 7 számjegy szükséges'
    phoneValid.value = false
    return
  }

  // Nyilvánvalóan hamis számok kiszűrése (000...., 111..., 123456...)
  const localDigits = digits.slice(-8)
  if (/^(\d)\1{6,}$/.test(localDigits)) {
    phoneError.value = 'Érvénytelen telefonszám – ne használj ismétlődő számjegyeket'
    phoneValid.value = false
    return
  }
  if (/^(0123456|1234567|12345678|0000000|1111111)/.test(localDigits)) {
    phoneError.value = 'Érvénytelen telefonszám – ne használj szekvenciális számjegyeket'
    phoneValid.value = false
    return
  }

  try {
    const normalized = normalizePhone(raw)
    const parsed = parsePhoneNumberFromString(normalized)

    if (!parsed) {
      phoneError.value = 'Nem felismerhető telefonszám formátum'
      phoneValid.value = false
      return
    }

    if (!parsed.isValid()) {
      phoneError.value = parsed.country
        ? `Érvénytelen ${parsed.country} telefonszám – ellenőrizd a számjegyeket`
        : 'Érvénytelen telefonszám – adj meg országkódot is (pl. +36...)'
      phoneValid.value = false
      return
    }

    deliveryDetails.value.phone = parsed.formatInternational()
    phoneError.value = ''
    phoneValid.value = true

  } catch {
    phoneError.value = 'Nem felismerhető telefonszám formátum'
    phoneValid.value = false
  }
}
function validateEmail() {
  const value = deliveryDetails.value.email.trim()

  if (!value) {
    emailError.value = ''
    emailValid.value = false
    return
  }

  // Szigorúbb regex: valós TLD (min. 2 karakter), nincs dupla pont, nincs pont @ előtt/után
  const emailRegex = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/

  if (!emailRegex.test(value)) {
    emailError.value = 'Érvénytelen email cím!'
    emailValid.value = false
    return
  }

  // Dupla pont kiszűrése (pl. teszt..nev@gmail.com)
  if (value.includes('..')) {
    emailError.value = 'Az email cím nem tartalmazhat egymást követő pontokat!'
    emailValid.value = false
    return
  }

  // Pont nem lehet közvetlenül @ előtt (pl. teszt.@gmail.com)
  if (value.indexOf('.@') !== -1) {
    emailError.value = 'Nem állhat pont közvetlenül a @ előtt!'
    emailValid.value = false
    return
  }

  // Pont nem lehet közvetlenül @ után (pl. teszt@.gmail.com)
  const atIndex = value.indexOf('@')
  if (value[atIndex + 1] === '.') {
    emailError.value = 'Nem állhat pont közvetlenül a @ után!'
    emailValid.value = false
    return
  }

  // Maximum egy @ jel
  if ((value.match(/@/g) || []).length > 1) {
    emailError.value = 'Az email cím csak egy @ jelet tartalmazhat!'
    emailValid.value = false
    return
  }

  emailError.value = ''
  emailValid.value = true
}
//#endregion

const payload = ref({})
async function checkout() {
  const currentCart = (cartItems && cartItems.value) ? cartItems.value : (cartStore && cartStore.cartItems ? cartStore.cartItems : [])
  if (!currentCart.length) {
    showToast('A kosarad üres.', 'error')
    return
  }

  // Készlet ellenőrzés az API-n keresztül
  try {
    for (const item of currentCart) {
      const res = await axios.get(`/api/termekek/${item.id}`)
      const freshItem = res.data
      if (freshItem.darab < item.quantity) {
        showToast(
          `"${item.nev}" termékből csak ${freshItem.darab} db érhető el.`,
          'error',
          `A kosárban ${item.quantity} db szerepelt.`
        )
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
    showToast('Hiba történt a készlet ellenőrzése közben.', 'error')
    return
  }

  const d = deliveryDetails.value
  if (!d.firstName || !d.lastName || !d.email || !d.utca || !d.hazszam || !d.cityId || !d.phone) {
    showErrorModal(['Kérlek töltsd ki az összes szállítási adatot.'])
    return
  }

  // Vezetéknév validáció
  validateFirstName()
  if (!firstNameValid.value) {
    showErrorModal('A vezetéknév nem érvényes!')
    return
  }

  // Keresztéknév validáció
  validateLastName()
  if (!lastNameValid.value) {
    showErrorModal('A keresztéknév nem érvenytes!')
    return
  }

  // Város validáció
  validateCity()
  if (!cityValid.value) {
    showErrorModal('A város nem érvényes!')
    return
  }

  // Utca validáció
  validateUtca()
  if (!utcaValid.value) {
    showErrorModal('A megadott utca nem érvényes!')
    return
  }

  // Házsorzás validáció
  validateHazszam()
  if (!hazszamValid.value) {
    showErrorModal('A házszám nem érvényes!')
    return
  }

  // Emelet/ajtó validáció
  if (deliveryDetails.value.emeletAjto) {
    validateEmeletAjto()
    if (!emeletAjtoValid.value) { showErrorModal('Az emelet/ajtó formátuma nem érvényes!'); return }
  }

  // Egyszerű telefonszám ellenőrzés: legalább 9 számjegy
  validatePhone()
  if (!phoneValid.value) {
    showErrorModal('A telefonszám nem érvényes!')
    return
  }

  // Email ellenörzés
  validateEmail()
  if (!emailValid.value) {
    showErrorModal('Az email ciém nem érvenytelen!')
    return
  }

  // Fizetés adatok
  payload.value = {
    delivery: {
      name:    `${d.lastName} ${d.firstName}`,
      email:   d.email,
      phone:   d.phone,
      city_id: d.cityId,
      utca:       d.utca,
      hazszam:    d.hazszam,
      emeletAjto: d.emeletAjto || null,         
    },
    items: currentCart.map(i => ({
      id:       i.id,
      mennyiseg: i.quantity,
      szin_id:  i.selectedColor?.id ?? null
    }))
  }
  try {
    const res = await axios.post('/api/rendeles', payload.value);
    if (deliveryDetails.value.mentes || userLogged.value) {
      try {
        await axios.post('/api/user/szallitasi-adatok-mentese', {
          vezeteknev:  d.lastName,
          keresztnev:  d.firstName,
          varos_id:    d.cityId,
          utca:       d.utca,
          hazszam:    d.hazszam,
          emeletAjto: d.emeletAjto || null,
          telefonszam: d.phone,
        })
      } catch (mentesHiba) {
        console.warn('Adatok mentése sikertelen:', mentesHiba)
      }
    }
    router.push({ path: `/kosar/fizetes/${res.data.rendeles_id}`});
  } catch (e) {
    showToast('Hiba történt a rendelés leadásakor.', 'error')
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

.toggle-group {
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  background: #f9fafb;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  padding: 12px 14px;
}

.toggle-label {
  font-size: 12px;
  font-weight: 700;
  color: #4b5563;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin: 0;
}

.toggle-switch {
  position: relative;
  display: inline-block;
  width: 44px;
  height: 24px;
  flex-shrink: 0;
}

.toggle-switch input {
  opacity: 0;
  width: 0;
  height: 0;
  position: absolute;
}

.toggle-slider {
  position: absolute;
  inset: 0;
  background: #d1d5db;
  border-radius: 999px;
  cursor: pointer;
  transition: background 0.25s ease;
}

.toggle-slider::before {
  content: '';
  position: absolute;
  width: 18px;
  height: 18px;
  left: 3px;
  top: 3px;
  background: white;
  border-radius: 50%;
  transition: transform 0.25s ease;
  box-shadow: 0 1px 4px rgba(0,0,0,0.2);
}

.toggle-switch input:checked + .toggle-slider {
  background: #119605;
}

.toggle-switch input:checked + .toggle-slider::before {
  transform: translateX(20px);
}

.toggle-switch input:focus-visible + .toggle-slider {
  box-shadow: 0 0 0 3px rgba(5, 150, 105, 0.2);
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

  .form-row {
    grid-template-columns: 1fr;
  }
}

/* Cart item switches to a 2-column grid card at mid-size */
@media (max-width: 700px) {
  .cart-item {
    display: grid;
    grid-template-columns: auto 1fr;
    grid-template-rows: auto auto;
    grid-template-areas:
      "image  details"
      "image  controls"
      "total  total";
    gap: 8px 16px;
    padding: 16px;
    align-items: start;
    position: relative;
  }

  .item-image-wrapper {
    grid-area: image;
  }

  .cart-item-image {
    width: 90px;
    height: 90px;
  }

  .cart-item-details {
    grid-area: details;
    padding-right: 36px; /* space for remove button */
    align-self: end;
  }

  .item-name {
    font-size: 15px;
    margin-bottom: 4px;
  }

  .item-price {
    font-size: 14px;
  }

  .cart-item-controls {
    grid-area: controls;
    align-self: start;
  }

  .cart-item-total {
    grid-area: total;
    text-align: right;
    min-width: unset;
    border-top: 1px solid #f0f1f3;
    padding-top: 8px;
  }

  .total-text {
    font-size: 16px;
  }

  .remove-btn {
    position: absolute;
    top: 12px;
    right: 12px;
    width: 30px;
    height: 30px;
    font-size: 16px;
  }
}

@media (max-width: 600px) {
  .cart-page {
    padding: 24px 16px;
  }

  .cart-header h1 {
    font-size: 1.5rem;
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

.confirm-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 16px;
}

.confirm-modal {
  background: #fff;
  border-radius: 14px;
  padding: 28px 24px 20px;
  box-shadow: 0 20px 40px rgba(0,0,0,0.2);
  width: 100%;
  max-width: 360px;
}

.confirm-message {
  font-size: 16px;
  color: #1e293b;
  margin: 0 0 24px;
  line-height: 1.5;
  text-align: center;
}

.confirm-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.confirm-btn {
  padding: 8px 20px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s;
}

.confirm-btn.cancel { background: #e5e7eb; color: #374151; }
.confirm-btn.cancel:hover { background: #d1d5db; }
.confirm-btn.danger { background: #dc2626; color: white; }
.confirm-btn.danger:hover { background: #b91c1c; }
</style>