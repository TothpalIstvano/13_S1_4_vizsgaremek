  <template>
    <div id="shop">
      <CartModal ref="cartModal" />

      <!-- TOP FILTER BAR -->
      <div id="toolbar">
        <div class="search-container">        
          <div class="search-icon">
            <FontAwesomeIcon icon="fa-magnifying-glass" />
          </div>
          <input
            type="text"
            placeholder="Keresés"
            class="search-input"
            name="search"
            v-model="searchTerm"
          />
        </div>

        <div class="active-filters" v-if="activekategoriak.length">
          <div
            class="filter-chip"
            v-for="tag in activekategoriak"
            :key="tag.id"
          >
            {{ tag.nev }}
            <span class="remove" @click="togglekategoria(tag.id)">✕</span>
          </div>
        </div>

        <div class="dropdown" ref="dropdown">
          <div class="dropdown__selected" @click="toggle">
            <FontAwesomeIcon :icon="selected.icon" />
            <span>{{ selected.label }}</span>
            <FontAwesomeIcon icon="chevron-down" class="chevron" />
          </div>

          <ul v-if="open" class="dropdown__menu">
            <li
              v-for="option in options"
              :key="option.value"
              @click="select(option)"
              class="dropdown__item"
            >
              <FontAwesomeIcon :icon="option.icon" />
              <span>{{ option.label }}</span>
            </li>
          </ul>
        </div>
      </div>
      
      <div id="tartalom">

        <!-- SIDEBAR -->
        <div class="side-bar">
          <div class="side-bar-header">
          <h2>Szűrés ár szerint</h2>
          </div>

          <div class="side-bar-content price-filter">
          <!-- Dual range slider -->
            <div class="range-slider">
              <input
                type="range"
                name="min-slide"
                v-model.number="tempMin"
                minlength="60"
                :min="absMin"
                :max="absMax"
                step="1"
                class="thumb thumb--left"
              />

              <input
                type="range"
                name="max-slide"
                v-model.number="tempMax"
                :min="absMin"
                :max="absMax"
                :value="tempMax"
                step="1"
                class="thumb thumb--right"
              />

              <div class="slider-track">
                <div
                  class="slider-range"
                  :style="rangeStyle"
                ></div>
              </div>
            </div>

            <!-- Number inputs -->
            <div class="price-range">
              <div class="price-input">
                <label class="price-label" for="minTextIn">Ft-tól</label>
                <input
                  type="number"
                  id="minTextIn"
                  v-model.number="tempMin"
                  :min="absMin"
                  :max="tempMax - 500"
                />
              </div>

              <div class="price-input">
                <label class="price-label" for="maxTextIn">Ft-ig</label>
                <input
                  type="number"
                  id="maxTextIn"
                  v-model.number="tempMax"
                  :min="tempMin"
                  :max="absMax"
                />
              </div>
            </div>

            <!-- Apply -->
            <button class="apply-btn" @click="applyPriceFilter">
              Alkalmaz
            </button>
          </div>

          <div class="side-bar-header">
            <h2>Szűrés kategória szerint</h2>
          </div>

          <div class="side-bar-content">
            <div 
              v-for="(kategoria, index) in kategoriak"
              :key="kategoria.id" 
              class="item-tag"
              :class="{ active: selectedkategoriak.includes(kategoria.id) }"
              @click="togglekategoria(kategoria.id)"
            >
            <div class="checkbox-wrapper-46">
                <input type="checkbox" :id="`cbx-${kategoria.id}`" class="inp-cbx" :value="kategoria.id" :key="index" v-model="selectedkategoriak" @click.stop/>
                <label :for="`cbx-${kategoria.id}`" class="cbx"
                    ><span>
                      <svg viewBox="0 0 12 10" height="10px" width="12px">
                        <polyline points="1.5 6 4.5 9 10.5 1"></polyline></svg></span
                  ><span>{{ kategoria.nev }}</span>
                </label>
              </div>
            </div>
          </div>
        </div>

        <!-- PRODUCT GRID -->
        <div id="products">
          <div v-for="item in filteredItems" :key="item.id" class="product-card" @click="router.push(`/aruhaz/${item.id}`)" style="cursor: pointer;">
            <img :src="item.termek_fo_kep.url_Link" :alt="item.termek_fo_kep.alt_szoveg" class="product-image" />

            <div class="product-body">
              <h3 class="product-title">{{ item.nev }}</h3>
              <p class="product-price">{{ item.ar }} Ft</p>

              <p class="product-desc" :style="item.termek_kategoriak.length == 0 ? 'margin-bottom: 25px;' : ''">{{ item.leiras }}</p>

              <div class="tag-container">
                <span
                  v-for="kategoria in item.termek_kategoriak"
                  :key="kategoria.id"
                  class="item-tag-sm"
                >
                  {{ kategoria.nev }}
                </span>
              </div>

              <button class="add-btn" @click="addToCart(item)" @click.stop>
                Kosárba
              </button>
            </div>
          </div>
          <div v-if="filteredItems.length == 0" style="grid-column: 1/-1; text-align: center; color: #555; font-size: 24px; padding: 2rem 0;">
            Nincs találat
          </div>
        </div>
      </div>
    </div>
  </template>


  <script setup>
  //#region imports
  import { ref, onMounted, onBeforeUnmount, watch, computed, provide, inject, onUnmounted } from 'vue'
  import axios from 'axios'
  import { useRouter } from 'vue-router'
  import { useCartStore } from '@/stores/cartStore'
  import CartModal from '@/components/CartModal.vue'
  import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
  import { library } from '@fortawesome/fontawesome-svg-core'
  import {
    faArrowUp,
    faArrowDown,
    faSortAlphaUp,
    faSortAlphaDown,
    faChevronDown,
    faFilter,
    faMagnifyingGlass
  } from '@fortawesome/free-solid-svg-icons'


  library.add(
    faArrowUp,
    faArrowDown,
    faSortAlphaUp,
    faSortAlphaDown,
    faChevronDown,
    faFilter,
    faMagnifyingGlass 
  )
  
  const router = useRouter()
  const cartStore = useCartStore()
  const cartModal = ref(null)
  //#endregion

  //#region eszköztár
  const options = [
    {
      value: 'price-asc',
      label: 'Ár szerint növekvő',
      icon: 'arrow-up'
    },
    {
      value: 'price-desc',
      label: 'Ár szerint csökkenő',
      icon: 'arrow-down'
    },
    {
      value: 'name-asc',
      label: 'Név szerint növekvő',
      icon: 'sort-alpha-up'
    },
    {
      value: 'name-desc',
      label: 'Név szerint csökkenő',
      icon: 'sort-alpha-down'
    }
  ]


  const selected = ref(  {
      value: 'default',
      label: 'Sorba rendezés',
      icon: 'filter'
    })
  const open = ref(false)
  const dropdown = ref(null)

  function toggle() {
    open.value = !open.value

  }

  function select(option) {
    selected.value = option
    open.value = false

    // emit / sort logic goes here
    console.log('Selected:', option.value)
  }

  function handleClickOutside(event) {
    if (dropdown.value && !dropdown.value.contains(event.target)) {
      open.value = false
    }
  }
  //#endregion

  //#region tartalom
  async function fetchTermek() {
    try {
      const response = await axios.get('/api/termekek');
      return response.data;
    } catch (error) {
      console.error('Error fetching products:', error);
      return [];
    }
  }

  async function fetchkategoriak() {
    try {
      const response = await axios.get('/api/kategoriak');
      return response.data;
    } catch (error) {
      console.error('Error fetching tags:', error);
      return [];
    }
  }

  async function termekRendezes() {
    if (selected.value.value === 'price-asc') {
      items.value.sort((a, b) => a.ar - b.ar);
    }
    if (selected.value.value === 'price-desc') {
      items.value.sort((a, b) => b.ar - a.ar);
    }
    if (selected.value.value === 'name-asc') {
      items.value.sort((a, b) => a.nev.localeCompare(b.nev));
    }
    if (selected.value.value === 'name-desc') {
      items.value.sort((a, b) => b.nev.localeCompare(a.nev));
    }
  }


  const items = ref([])
  const kategoriak = ref([]) // Holds the list of tags for the sidebar
  const selectedkategoriak = ref([])
  const min = ref(0)
  const max = ref(0)
  const searchTerm = ref('')
  const activekategoriak = computed(() => kategoriak.value.filter(c => selectedkategoriak.value.includes(c.id)))
  const foKategoriak = computed(() => kategoriak.value.filter(k => !k.fo_kategoria_id))

  function togglekategoria(id) {
    const index = selectedkategoriak.value.indexOf(id);
    if (index === -1) {
      selectedkategoriak.value.push(id);
    } else {
      selectedkategoriak.value.splice(index, 1);
    }
  }

  const filteredItems = computed(() => {
  return originalItems.value.filter(item => {

    // SEARCH
    const matchesSearch =
      item.nev.toLowerCase().includes(searchTerm.value.toLowerCase())

    // PRICE
    const matchesPrice =
      item.ar >= appliedMin.value && item.ar <= appliedMax.value

    // TAGS
    const matchesTags =
      selectedkategoriak.value.length === 0 ||
      selectedkategoriak.value.every(tagId =>
        item.termek_kategoriak.some(t => t.id === tagId)
      )

    return matchesSearch && matchesPrice && matchesTags
  })
})

  function addToCart(item) {
    const result = cartStore.addToCart(item, 1)
    
    if (result.success && result.added > 0) {
      cartModal.value?.open(item, result.added)
    } else if (!result.success) {
      alert(`⚠️ ${result.message}`)
    }
  }
//#endregion

//#region mountok, unmountok, watchok, stb.
onMounted(() => {
  document.addEventListener('click', handleClickOutside)

  fetchTermek().then(data => {
    items.value = data
    min.value = items.value.reduce((acc, item) => Math.min(acc, item.ar), Infinity)
    max.value = items.value.reduce((acc, item) => Math.max(acc, item.ar), 0)
  })

  fetchkategoriak().then(data => {
    kategoriak.value = data.sort((a, b) => a.nev.localeCompare(b.nev))
  })
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

watch(selected, () => {
  setTimeout(() => {
    termekRendezes()
  },1000)
})

watch(items, () => {
  min.value = items.value.reduce((acc, item) => Math.min(acc, item.ar), Infinity)
  max.value = items.value.reduce((acc, item) => Math.max(acc, item.ar), 0)
})


const originalItems = ref([])

// absolute bounds (from backend)
const absMin = ref(0)
const absMax = ref(0)

// temporary UI values
const tempMin = ref(0)
const tempMax = ref(0)

// applied filter values
const appliedMin = ref(0)
const appliedMax = ref(0)

// calculate slider fill
const rangeStyle = computed(() => {
  const minPercent = ((tempMin.value - absMin.value) / (absMax.value - absMin.value)) * 100
  const maxPercent = ((tempMax.value - absMin.value) / (absMax.value - absMin.value)) * 100

  if (minPercent<0) {
    minPercent = 0
  }
  if (maxPercent>100) {
    maxPercent = 100
  }
  return {
    left: `${minPercent}%`,
    width: `${maxPercent - minPercent}%`
  }
})

// safety clamps
watch(tempMin, val => {
  if (val > tempMax.value) tempMin.value = tempMax.value
})

watch(tempMax, val => {
  if (val < tempMin.value) tempMax.value = tempMin.value
})


onMounted(async () => {
  const data = await fetchTermek()

  originalItems.value = data
  items.value = data

  absMin.value = Math.min(...data.map(i => i.ar))
  absMax.value = Math.max(...data.map(i => i.ar))

  tempMin.value = absMin.value
  tempMax.value = absMax.value

  appliedMin.value = absMin.value
  appliedMax.value = absMax.value
})

function applyPriceFilter(){
  appliedMin.value = tempMin.value
  appliedMax.value = tempMax.value
}

const priceChanged = computed(() =>
  tempMin.value !== appliedMin.value ||
  tempMax.value !== appliedMax.value
)


watch(open, () => {
  if (open.value) {
    document.getElementsByClassName('dropdown__selected')[0].style.border = '1px solid #000'
    document.getElementsByClassName('dropdown__selected')[0].style.borderRadius = '8px 8px 0px 0px'
  }
  else {
    document.getElementsByClassName('dropdown__selected')[0].style.border = '1px solid #d0d0d0'
    document.getElementsByClassName('dropdown__selected')[0].style.borderRadius = '8px'
  }
})

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside)
})
//#endregion
</script>

<style scoped>
#shop {
  min-height: 90vh;
  padding: 24px;
}

/*#region ===== TOP TOOLBAR ===== */
#toolbar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 24px;
  background-color: white;
  border-radius: 14px;
  width: 100%;
  height: 100px;
  box-shadow:0 4px 12px rgba(0, 0, 0, 0.151);
  @media screen and (max-width: 480px) {
    flex-direction: column;
  }
}
/*#endregion*/

/*#region ===== FILTER CHIPS ===== */
.active-filters {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  margin-right: 20px;
}

.filter-chip {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 10px;
  background: #e3e8ff;
  color: #2b3ea8;
  border-radius: 999px;
  font-size: 13px;
  font-weight: 500;
}

.filter-chip .remove {
  cursor: pointer;
  font-weight: bold;
  opacity: 0.7;
}

.filter-chip .remove:hover {
  opacity: 1;
}
/*#endregion*/


/*#region ===== DROPDOWN ===== */
.dropdown {
  position: relative;
  width: 300px;
  font-size: 15px;
  margin: 25px auto;
}

.dropdown__selected {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border: 1px solid #f1f1f1;
  border-radius: 8px ;
  cursor: pointer;
  background: white;
}

.dropdown__selected:hover {
  border: 1px solid #d0d0d0;
}

.dropdown__menu {
  position: absolute;
  top: calc(100% - 25px);
  width: 100%;
  border: 1px solid #d0d0d0;
  border-radius: 0 0 8px 8px;
  background: white;
  z-index: 2;
}

.dropdown__item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  cursor: pointer;
}

.dropdown__item:hover {
  background: #f1f1f1;
}

.chevron {
  margin-left: auto;
}
/*#endregion*/

/*#region ===== SEARCH BAR ===== */
.search-container {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px 14px 8px 14px; /* Adjusted padding for better look */
  border: 1px solid #d0d0d0;
  border-radius: 50px; /* Pill shape */
  background: white;
  width: 300px;
  height: 40px;
  margin: 25px auto;
  transition: all 0.2s;
}

.search-container:focus-within {
  border-color: #d49535;
  box-shadow: 0 0 0 3px rgba(63, 81, 181, 0.1);
}

.search-icon {
  color: #999;
  display: flex;
  align-items: center;
}

.search-container input {
  border: none;
  outline: none;
  width: 100%;
  font-size: 15px;
  background: transparent;
}
/*#endregion*/

/*#region ===== MAIN LAYOUT ===== */
#tartalom {
  display: flex;
  gap: 20px;
  align-items: flex-start;
}
/*#endregion*/

/*#region ===== SIDEBAR ===== */
.side-bar {
  width: 250px;
  flex-shrink: 0; /* Prevent shrinking */
  background: white;
  border-radius: 14px;
  padding: 20px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
  position: static;
}

.side-bar-header h2 {
  font-size: 18px;
  margin-bottom: 16px;
  color: #333;
  border-bottom: 2px solid #f0f0f0;
  padding-bottom: 10px;
}

.side-bar-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Sidebar Tags */
.side-bar-content .item-tag {
  padding: 10px 14px;
  border-radius: 8px;
  cursor: pointer;
  color: #555;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
  background: #f8f9fa;
}

.side-bar-content .item-tag:hover {
  background: #e3e8ff;
  color: #3f51b5;
}
/*
.item-tag.active {
  background: #c7d4ff;
  color: #2b3ea8;
}*/
/*#endregion*/

/*#region ===== Price Filter ===== */
.price-filter {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

/* === RANGE SLIDER === */
.range-slider {
  position: relative;
  height: 38px;
  width: 100%;
}

.slider-track {
  position: absolute;
  top: 50%;
  width: 100%;
  height: 6px;
  background: #e0e0e0;
  border-radius: 3px;
  transform: translateY(-50%);
}

.slider-range {
  position: absolute;
  height: 100%;
  background: #f3a514;
  max-width: 100%;
  border-radius: 3px;
}

.thumb {
  pointer-events: none;
  position: absolute;
  width: 100%;
  height: 36px;
  appearance: none;
  background: none;
}

.thumb::-webkit-slider-thumb {
  pointer-events: all;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #3f51b5;
  border: none;
  cursor: pointer;
}

.thumb--left {
  z-index: 3;
}

.thumb--right {
  z-index: 4;
}

/* === INPUTS === */
.price-range {
  display: flex;
  gap: 10px;
}

.price-input {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.price-input input {
  padding: 6px 8px;
  border: 1px solid #d0d0d0;
  border-radius: 6px;
}

/* === APPLY BUTTON === */
.apply-btn {
  margin-top: 6px;
  padding: 8px;
  border: none;
  background: #3f51b5;
  color: white;
  font-weight: 600;
  border-radius: 6px;
  cursor: pointer;
}

.apply-btn:hover {
  background: #2f3fa3;
}
/*#endregion*/

/*#region Checkbox */
.checkbox-wrapper-46 input[type="checkbox"] {
  display: none;
  visibility: hidden;
}

.checkbox-wrapper-46 .cbx {
  margin: auto;
  -webkit-user-select: none;
  user-select: none;
  cursor: pointer;
}
.checkbox-wrapper-46 .cbx span {
  display: inline-block;
  vertical-align: middle;
  transform: translate3d(0, 0, 0);
}
.checkbox-wrapper-46 .cbx span:first-child {
  position: relative;
  width: 18px;
  height: 18px;
  border-radius: 3px;
  transform: scale(1);
  vertical-align: middle;
  border: 1px solid #9098a9;
  transition: all 0.2s ease;
}
.checkbox-wrapper-46 .cbx span:first-child svg {
  position: absolute;
  top: 3px;
  left: 2px;
  fill: none;
  stroke: #ffffff;
  stroke-width: 2;
  stroke-linecap: round;
  stroke-linejoin: round;
  stroke-dasharray: 16px;
  stroke-dashoffset: 16px;
  transition: all 0.3s ease;
  transition-delay: 0.1s;
  transform: translate3d(0, 0, 0);
}
.checkbox-wrapper-46 .cbx span:first-child:before {
  content: "";
  width: 100%;
  height: 100%;
  background: #506eec;
  display: block;
  transform: scale(0);
  opacity: 1;
  border-radius: 50%;
}
.checkbox-wrapper-46 .cbx span:last-child {
  padding-left: 8px;
}
.checkbox-wrapper-46 .cbx:hover span:first-child {
  border-color: #506eec;
}

.checkbox-wrapper-46 .inp-cbx:checked + .cbx span:first-child {
  background: #506eec;
  border-color: #506eec;
  animation: wave-46 0.4s ease;
}
.checkbox-wrapper-46 .inp-cbx:checked + .cbx span:first-child svg {
  stroke-dashoffset: 0;
}
.checkbox-wrapper-46 .inp-cbx:checked + .cbx span:first-child:before {
  transform: scale(3.5);
  opacity: 0;
  transition: all 0.6s ease;
}

@keyframes wave-46 {
  50% {
    transform: scale(0.9);
  }
}
/*#endregion*/

/*#region ===== PRODUCT GRID ===== */
#products {
  flex: 1;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
}

/* ===== PRODUCT CARD ===== */
.product-card {
  background: white;
  border-radius: 14px;
  overflow: hidden;
  box-shadow: 0 6px 18px rgba(0,0,0,0.08);
  display: flex;
  flex-direction: column;
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

.product-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 26px rgba(0,0,0,0.12);
}

.product-image {
  width: 100%;
  height: 190px;
  object-fit: cover;
}

/* ===== PRODUCT BODY ===== */
.product-body {
  padding: 14px 16px 16px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
  min-height: 240px;
}

.product-title {
  font-size: 17px;
  font-weight: 600;
}

.product-price {
  font-weight: 700;
  color: #2e7d32;
}

.product-desc {
  font-size: 14px;
  color: #555;
  line-height: 1.3;
  max-height: 3.8em;
  overflow: hidden;
  flex: 1;
}

/* ===== TAGS (Inside Card) ===== */
.tag-container {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  flex-grow: 0;
}

.item-tag-sm {
  background: #e3e8ff;
  color: #2b3ea8;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 999px;
  cursor: pointer;
  transition: all 0.2s;
}

.item-tag-sm:hover {
  background: #c7d4ff;
}

/* ===== BUTTON ===== */
.add-btn {
  margin-top: auto;
  padding: 10px;
  border: none;
  border-radius: 8px;
  background: #3f51b5;
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s ease;
}

.add-btn:hover {
  background: #2f3fa3;
}
/*#endregion*/
</style>