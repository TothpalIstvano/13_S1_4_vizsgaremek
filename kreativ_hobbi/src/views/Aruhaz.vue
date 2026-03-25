  <template>
    <div id="shop">
      <CartModal ref="cartModal" />

      <!-- TOP FILTER BAR -->
      <div id="toolbar">
        <div class="filter-group">
          <span class="filter-label">Aktív kategóriák:</span>
          <div class="active-filters" v-if="activekategoriak.length">
            <div class="filter-chip" v-for="tag in lathatoFilter" :key="tag.id">
              {{ tag.nev }}
              <span class="remove" @click="togglekategoria(tag.id)">✕</span>
            </div>
            <div v-if="rejtettFilter > 0" class="filter-chip more-chip">
              +{{ rejtettFilter }}
            </div>
            <button type="button" id="clear-filters" @click="clearFilters">Összes törlése</button>
          </div>
          <div class="active-filters" v-else>
            <div class="filter-chip-empty">Nincs aktiv kategória</div>
          </div>
        </div>

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
            <h2>Kategóriák</h2>
          </div>

          <div class="side-bar-content">
          <div
            v-for="fo in kategoriakTree"
            :key="fo.id"
            class="category-group"
          >
            <!-- FŐ KATEGÓRIA (DROPDOWN HEADER) -->
            <div
              class="category-header"
              @click="toggleCategoryDropdown(fo.id)"
            >
            <div class="checkbox-wrapper-46">
              <input
                type="checkbox"
                :id="`cbx-${fo.id}`"
                class="inp-cbx"
                :value="fo.id"
                @change="togglekategoria(fo.id)"
                v-model="selectedkategoriak"
              />
              <label :for="`cbx-${fo.id}`" class="cbx">
                <span>
                  <svg viewBox="0 0 12 10" height="10px" width="12px">
                    <polyline points="1.5 6 4.5 9 10.5 1"></polyline>
                  </svg>
                </span>
              </label>
            </div>
              <span class="category-name">{{ fo.nev }}</span>
              <FontAwesomeIcon
                icon="chevron-down"
                :class="{ rotated: openCategories.includes(fo.id) }"
              />
            </div>

            <!-- ALKATEGÓRIÁK -->
            <div
              v-if="openCategories.includes(fo.id)"
              class="subcategory-list"
            >
              <div
                v-for="child in fo.children"
                :key="child.id"
                class="item-tag"
                :class="{ active: selectedkategoriak.includes(child.id) }"
                @click="togglekategoria(child.id)"
              >
                <div class="checkbox-wrapper-46">
                  <input
                    type="checkbox"
                    :id="`cbx-${child.id}`"
                    class="inp-cbx"
                    :value="child.id"
                    @change="togglekategoria(child.id)"
                    v-model="selectedkategoriak"
                    @click.stop
                  />
                  <label :for="`cbx-${child.id}`" class="cbx">
                    <span>
                      <svg viewBox="0 0 12 10" height="10px" width="12px">
                        <polyline points="1.5 6 4.5 9 10.5 1"></polyline>
                      </svg>
                    </span>
                    <span>{{ child.nev }}</span>
                  </label>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

        <!-- PRODUCT GRID -->
        <div id="products">
          <div v-if="loading" class="tolto-kontener">
            <div class="tolto-content">
              <div class="tolto-icon">🧵</div>
              <p class="tolto-szoveg">Termékek betöltése…</p>
              <div class="toltes">
                <div class="pulse-dot"></div>
                <div class="pulse-dot"></div>
                <div class="pulse-dot"></div>
            </div>
          </div>
        </div>
          <div v-for="item in lapozottTermekek" :key="item.id" class="product-card" @click="router.push(`/aruhaz/${item.id}`)" style="cursor: pointer;">
            <div class="heart-wrapper">
              <button v-if="isLoggedIn" class="heart-btn" @click="toggleLike(item, $event)"
                      :class="{ liked: likedIds.has(item.id) }">
                <FontAwesomeIcon :icon="likedIds.has(item.id) ? ['fas', 'heart'] : ['far', 'heart']" />
              </button>
            </div>
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
                  :class="{ 'main-category': kategoria.fo_kategoria_id === null }"
                >
                  {{ kategoria.nev }}
                </span>
              </div>

              <button class="add-btn" @click="addToCart(item)" @click.stop>
                Kosárba
              </button>
            </div>
          </div>
          <div v-if="filteredItems.length == 0 && !loading" style="grid-column: 1/-1; text-align: center; color: #555; font-size: 24px; padding: 2rem 0;">
            Nincs találat
          </div>
          <div class="lapozas-sor" v-if="osszesenLap > 0 && !loading">
            <div class="oldal-meret">
              <label for="perPage">Megjelenítés:</label>
              <select id="perPage" v-model="oldalMeret" @change="oldalra(1)">
                <option :value="12">12</option>
                <option :value="24">24</option>
                <option :value="48">48</option>
              </select>
            </div>

            <div class="lapozas" v-if="osszesenLap > 1">
              <button class="lap-gomb" @click="oldalra(aktualisOldal - 1)" :disabled="aktualisOldal === 1">
                <font-awesome-icon icon="fa-solid fa-chevron-left" />
              </button>

              <template v-for="lap in lathatolapok" :key="lap">
                <span v-if="lap === '...'" class="lapozas-ellipsis">…</span>
                <button
                  v-else
                  class="lap-gomb"
                  :class="{ 'aktiv-lap': lap === aktualisOldal }"
                  @click="oldalra(lap)"
                >
                  {{ lap }}
                </button>
              </template>

              <button class="lap-gomb" @click="oldalra(aktualisOldal + 1)" :disabled="aktualisOldal === osszesenLap">
                <font-awesome-icon icon="fa-solid fa-chevron-right" />
              </button>
            </div>
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
    faMagnifyingGlass,
    faChevronLeft,
    faChevronRight
  } from '@fortawesome/free-solid-svg-icons'

  library.add(
    faArrowUp,
    faArrowDown,
    faSortAlphaUp,
    faSortAlphaDown,
    faChevronDown,
    faFilter,
    faMagnifyingGlass,
    faChevronLeft,
    faChevronRight
  )

  import { faHeart as fasHeart } from '@fortawesome/free-solid-svg-icons'
  import { faHeart as farHeart } from '@fortawesome/free-regular-svg-icons'

  library.add(fasHeart, farHeart)

  const loading = ref(false)
  const router = useRouter()
  const cartStore = useCartStore()
  const cartModal = ref(null)
  const isLoggedIn = ref(false)
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
  const aktualisOldal = ref(1)
  const oldalMeret = ref(12)

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
      const response = await axios.get('/api/termekek/kategoriak');
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
  const selectedkategoriak = ref(
    JSON.parse(sessionStorage.getItem('shop_selected_kategoriak') || '[]')
  )
  const min = ref(0)
  const max = ref(0)
  const searchTerm = ref('')
  const activekategoriak = computed(() => kategoriak.value.filter(c => selectedkategoriak.value.includes(c.id)))
  const maxLathatoFilter = 4 //max látható szűrők száma a chipben
  const originalItems = ref([])
  const likedIds = ref(new Set())

  // absolute bounds (from backend)
  const absMin = ref(0)
  const absMax = ref(0)

  // temporary UI values
  const tempMin = ref(0)
  const tempMax = ref(0)

  // applied filter values
  const appliedMin = ref(0)
  const appliedMax = ref(0)

  const openCategories = ref([])

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

  function clearFilters() {
    selectedkategoriak.value = []
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

watch(selectedkategoriak, (val) => {
  sessionStorage.setItem('shop_selected_kategoriak', JSON.stringify(val))
}, { deep: true })

watch(selected, () => {
  setTimeout(() => {
    termekRendezes()
  },1000)
})

watch(items, () => {
  min.value = items.value.reduce((acc, item) => Math.min(acc, item.ar), Infinity)
  max.value = items.value.reduce((acc, item) => Math.max(acc, item.ar), 0)
})

const kategoriakTree = computed(() => {
  return kategoriak.value
    .filter(k => !k.fo_kategoria_id) // fő kategóriák
    .map(fo => ({
      ...fo,
      children: kategoriak.value.filter(
        k => k.fo_kategoria_id === fo.id
      )
    }))
})

const lathatoFilter = computed(() => {
  return activekategoriak.value.slice(0, maxLathatoFilter)
})

const rejtettFilter = computed(() => {
  return activekategoriak.value.length - maxLathatoFilter
})

function toggleCategoryDropdown(id) {
  const index = openCategories.value.indexOf(id)
  if (index === -1) {
    openCategories.value.push(id)
  } else {
    openCategories.value.splice(index, 1)
  }
}

const osszesenLap = computed(() =>
  Math.ceil(filteredItems.value.length / oldalMeret.value)
)

const lapozottTermekek = computed(() => {
  const start = (aktualisOldal.value - 1) * oldalMeret.value
  return filteredItems.value.slice(start, start + oldalMeret.value)
})

const lathatolapok = computed(() => {
  const total = osszesenLap.value
  const current = aktualisOldal.value
  const pages = []

  if (total <= 7) {
    for (let i = 1; i <= total; i++) pages.push(i)
  } else {
    pages.push(1)
    if (current > 3) pages.push('...')
    for (let i = Math.max(2, current - 1); i <= Math.min(total - 1, current + 1); i++) {
      pages.push(i)
    }
    if (current < total - 2) pages.push('...')
    pages.push(total)
  }

  return pages
})

const oldalra = (lap) => {
  if (lap < 1 || lap > osszesenLap.value) return
  aktualisOldal.value = lap
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// calculate slider fill
const rangeStyle = computed(() => {
  const range = absMax.value - absMin.value
  if (range === 0) return { left: '0%', width: '0%' }

  let minPercent = ((tempMin.value - absMin.value) / range) * 100
  let maxPercent = ((tempMax.value - absMin.value) / range) * 100

  minPercent = Math.max(0, Math.min(minPercent, 100))
  maxPercent = Math.max(0, Math.min(maxPercent, 100))

  return {
    left: `${minPercent}%`,
    width: `${maxPercent - minPercent}%`
  }
})

// safety clamps
const MIN_DISTANCE = 500

watch(tempMin, val => {
  if (val > tempMax.value - MIN_DISTANCE) {
    tempMin.value = tempMax.value - MIN_DISTANCE
  }
})

watch(tempMax, val => {
  if (val < tempMin.value + MIN_DISTANCE) {
    tempMax.value = tempMin.value + MIN_DISTANCE
  }
})

watch([searchTerm, selectedkategoriak, appliedMin, appliedMax], () => {
  aktualisOldal.value = 1
})

onMounted(async () => {
  loading.value = true
  const data = await fetchTermek()

  originalItems.value = data
  items.value = data

  absMin.value = Math.min(...data.map(i => i.ar))
  absMax.value = Math.max(...data.map(i => i.ar))

  tempMin.value = absMin.value
  tempMax.value = absMax.value

  appliedMin.value = absMin.value
  appliedMax.value = absMax.value

  loading.value = false

  try {
    const res = await axios.get('/api/user/check')
    isLoggedIn.value = res.data.loggedIn
  } catch {}

  try {
    const res = await axios.get('/api/user/kedvencek')
    likedIds.value = new Set(res.data)
  } catch {} // not logged in = no likes shown
})

async function toggleLike(item, event) {
  event.stopPropagation()
  if (!isLoggedIn.value) return

  const res = await axios.post(`/api/termekek/${item.id}/kedvenc`)
  if (res.data.liked) likedIds.value.add(item.id)
  else likedIds.value.delete(item.id)
}

function applyPriceFilter(){
  appliedMin.value = tempMin.value
  appliedMax.value = tempMax.value
}

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
.heart-wrapper { position: relative; }
.heart-btn {
  position: absolute; top: 8px; right: 8px;
  background: rgba(255,255,255,0.85);
  border: none; border-radius: 50%;
  width: 34px; height: 34px;
  font-size: 18px; cursor: pointer;
  color: #ccc; transition: color 0.2s, transform 0.15s;
  z-index: 1;
}
.heart-btn.liked { color: #e03e3e; }
.heart-btn:hover { transform: scale(1.15); }

#shop {
  min-height: 90vh;
  padding: 15px;
}

/*#region ===== TOP TOOLBAR ===== */
#toolbar {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  margin-bottom: 24px;
  background-color: white;
  border-radius: 14px;
  width: 100%;
  height: 100px; /*Ez miatt van fentebb az Aktív kategóriák és innen kikerült a min-heights*/
  padding: 0 24px;
  box-shadow:0 4px 12px rgba(0, 0, 0, 0.151);
}  


/*#endregion*/

/*#region ===== FILTER CHIPS ===== */
.active-filters {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
}

.filter-label {
  font-size: 16px;
  font-weight: 900;
  color: #333;
  white-space: nowrap;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
  grid-column: 1;
  justify-self: start;
  height: 52px; /*Ez miatt van fentebb az Aktív kategóriák*/
}

.filter-chip {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  background: #ffebd3;
  color: #b55b3f;
  border: 1px solid rgba(43, 62, 168, 0.1);
  border-radius: 999px;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s ease; 
  cursor: default;
}

.filter-chip-empty {
  display: inline-flex;
  align-items: center;
  padding: 6px 12px;
  background: #f8f9fa;
  color: #aaa;
  border: 1px dashed #d0d0d0;
  border-radius: 999px;
  font-size: 14px;
  font-style: italic;
}

.filter-chip:hover {
  background-color: #ffecdb;
  border-color: #cc6c34;
  transform: translateY(-1px); /* Slight lift effect */
  box-shadow: 0 2px 5px rgba(43, 62, 168, 0.15);
}

/* The 'X' remove button styling */
.filter-chip .remove {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background-color: rgba(255, 255, 255, 0.6);
  color: #000000;
  font-size: 10px;
  cursor: pointer;
  transition: all 0.2s;
  line-height: 1;
}

.filter-chip .remove:hover {
  background-color: #b55b3f; /* Fills with color on hover */
  color: white;
}

/* Specific style for the "+X" counter chip */
.filter-chip.more-chip {
  background-color: #f8f9fa;
  color: #666;
  border: 1px dashed #d0d0d0;
  font-weight: 600;
  padding: 6px 10px;
}

.filter-chip.more-chip:hover {
  transform: none; /* No lift effect for the counter */
  background-color: #f8f9fa;
  box-shadow: none;
  border-color: #d0d0d0;
}

/* Style for the Clear Button */
#clear-filters {
  padding: 6px 14px;
  font-size: 13px;
  color: #555;
  background: transparent;
  border: 1px solid #d0d0d0;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  font-family: inherit;
  flex-shrink: 0;
}

#clear-filters:hover {
  border-color: #dc3545;
  color: #dc3545;
  background-color: #fff5f5;
}

/*#endregion*/


/*#region ===== DROPDOWN ===== */
.dropdown {
  position: relative;
  width: 300px;
  font-size: 15px;
  margin: 0;
  grid-column: 3;
  justify-self: end;
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
  margin: 0;
  grid-column: 2;
  justify-self: center;
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
  background: #ffeee3;
  color: #b55b3f;
};

.category-group {
  margin-bottom: 10px;
}

.category-header {
  display: flex;
  align-items: center;
  padding: 10px 14px;
  background: #f3f4f6;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}

.category-header .svg-inline--fa {
  margin-left: auto;
}

.category-header:hover {
  background: #ffeee3;
}

.category-name {
margin-left: 10px;
}

.subcategory-list {
  padding-left: 10px;
  margin-top: 6px;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.category-header .svg-inline--fa {
  transition: transform 0.5s ease;
}

.rotated {
  transform: rotate(180deg);
}

.termek-oszlop {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 24px;
  min-width: 0;
}

.lapozas-sor {
  grid-column: 1 / -1;
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  align-items: center;
  padding: 8px 0 16px;
  gap: 12px;
}

.lapozas {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  flex-wrap: wrap;
  grid-column: 2;
}

.lap-gomb {
  min-width: 40px;
  height: 40px;
  padding: 0 12px;
  border: 1px solid #d0d0d0;
  background: #f8f9fa;
  color: #494d55;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.lap-gomb:hover:not(:disabled) {
  background: #b55b3f;
  color: white;
  border-color: #b55b3f;
  transform: translateY(-2px);
}

.lap-gomb:disabled {
  opacity: 0.35;
  cursor: not-allowed;
}

.aktiv-lap {
  background: #b55b3f !important;
  color: white !important;
  border-color: #b55b3f !important;
  box-shadow: 0 4px 6px -1px rgba(63, 81, 181, 0.3);
}

.lapozas-ellipsis {
  padding: 0 6px;
  color: #9ca3af;
  font-size: 18px;
  line-height: 40px;
}

.oldal-meret {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #494d55;
  position: absolute;
  right: 15px;
}

.oldal-meret select {
  padding: 8px 10px;
  border: 1px solid #d0d0d0;
  border-radius: 8px;
  background: #f8f9fa;
  font-size: 14px;
  cursor: pointer;
  color: #494d55;
}

.oldal-meret select:focus {
  outline: none;
  border-color: #b55b3f;
}
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
  margin-top: 1px;
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
  width: calc(100% + 18px);
  left: -9px;
  height: 36px;
  appearance: none;
  background: none;
}

.thumb::-webkit-slider-thumb {
  pointer-events: all;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #b55b3f;
  border: 2px solid #ffe4dcc4;
  cursor: pointer;
  box-shadow: 0 1px 4px rgba(0,0,0,0.25);
  appearance: none;
}

.thumb::-webkit-slider-thumb:hover {
  transform: scale(1.1);
}

.thumb::-moz-range-thumb {
  pointer-events: all;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #b55b3f;
  border: 2px solid white;
  box-shadow: 0 1px 4px rgba(0,0,0,0.25);
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
  background: #b55b3f;
  color: white;
  font-weight: 600;
  border-radius: 6px;
  cursor: pointer;
}

.apply-btn:hover {
  background: #81442f;
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
  background: #ff5d2adb;
  display: block;
  transform: scale(0);
  opacity: 1;
  border-radius: 50%;
}

.checkbox-wrapper-46 .cbx span:last-child {
  padding-left: 8px; /*oválissá teszi a főkategóriák kattintésos animációját*/
}

.checkbox-wrapper-46 .cbx:hover span:first-child {
  border-color: #ff5d2adb;
}

.checkbox-wrapper-46 .inp-cbx:checked + .cbx span:first-child {
  background: #ff5d2adb;
  border-color: #ff5d2adb;
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
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); /*ezt kell majd reszponzívvá tenni*/
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

/* ===== BUTTON ===== */
.add-btn {
  margin-top: auto;
  padding: 10px;
  border: none;
  border-radius: 8px;
  background: #b55b3f;
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s ease;
}

.add-btn:hover {
  background: #81442f;
}
/*#endregion*/

/* ===== BETÖLTÉS ===== */
.tolto-kontener {
  grid-column: 1 / -1;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.tolto-content {
  text-align: center;
}

.tolto-szoveg {
  font-size: 18px;
  color: #363636;
  margin-bottom: 32px;
  font-weight: 500;
}

.toltes {
  display: flex;
  justify-content: center;
  gap: 16px;
}

.pulse-dot {
  width: 12px;
  height: 12px;
  background: linear-gradient(135deg, #b55b3f 0%, #81442f 100%);
  border-radius: 50%;
  animation: pulse 1.4s infinite ease-in-out;
}

.pulse-dot:nth-child(2) { animation-delay: 0.2s; }
.pulse-dot:nth-child(3) { animation-delay: 0.4s; }

@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 1; }
  50% { transform: scale(0.6); opacity: 0.5; }
}

@media screen and (max-width: 1024px) {
  .side-bar {
    width: 220px;
    padding: 16px;
  }

  #products {
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
  }

  .product-image {
    height: 170px;
  }
}

@media screen and (max-width: 900px) {
  .side-bar {
    padding: 14px;
  }

  #products {
    grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
    gap: 16px;
  }

  .product-body {
    padding: 12px;
    min-height: 220px;
  }

  .product-title {
    font-size: 16px;
  }
}

@media screen and (max-width: 768px) {
  #tartalom {
    flex-direction: column;
    gap: 16px;
  }

  .side-bar {
    width: 100%;
    padding: 16px;
  }

  .side-bar-content {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 10px;
  }

  .category-group {
    margin-bottom: 0;
  }

  #products {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  }

  .oldal-meret {
    position: static;
    margin: 0 auto 12px;
    justify-content: center;
    width: 100%;
  }

  .lapozas-sor {
    flex-direction: column;
    align-items: center;
  }

  #toolbar {
    grid-template-columns: 1fr;
    gap: 12px;
    padding: 16px;
    height: auto;
  }

  .active-filters {
    justify-content: center;
    max-height: none;
    margin-bottom: 0;
  }

  .search-container,
  .dropdown {
    width: 100% !important;
    margin: 0 auto !important;
  }

  .dropdown {
    justify-self: stretch;
  }
}

@media screen and (max-width: 480px) {
  .side-bar-content {
    grid-template-columns: 1fr;
  }

  #products {
    grid-template-columns: 1fr;
  }

  .product-card {
    max-width: 100%;
  }

  .filter-chip {
    font-size: 12px;
    padding: 4px 10px;
  }

  #clear-filters {
    width: 100%;
    text-align: center;
  }

  .dropdown__selected {
    padding: 8px 12px;
  }
}

@media screen and (max-width: 400px) {
  #toolbar {
    grid-template-columns: 1fr;
    gap: 15px;
    padding: 16px;
  }

  .active-filters,
  .search-container,
  .dropdown {
    grid-column: 1;
    width: 100% !important;
    margin: 0 auto !important;
  }

  .active-filters {
    justify-self: center;
    max-height: none;
    justify-content: center;
  }

  .search-container {
    justify-self: center;
  }

  .dropdown {
    justify-self: stretch;
  }

  .filter-chip {
    font-size: 12px;
    padding: 4px 10px;
  }

  #clear-filters {
    width: 100%;
    text-align: center;
  }
}

@media screen and (max-width: 350px) {
  .side-bar-content {
    grid-template-columns: 1fr;
  }
  #products {
    grid-template-columns: 1fr;
  }
  .product-card {
    max-width: 100%;
  }
  .dropdown__selected {
    padding: 8px 12px;
  }
}
.tolto-kontener {
  grid-column: 1 / -1;
  display: flex; justify-content: center; align-items: center;
  min-height: 360px;
}
.tolto-content { text-align: center; }
.tolto-icon { font-size: 48px; margin-bottom: 12px; animation: spin 3s linear infinite; }
@keyframes spin { 0%,100%{transform:rotate(0deg)} 50%{transform:rotate(15deg)} 25%,75%{transform:rotate(-10deg)} }
.tolto-szoveg { font-size: 16px; color: var(--clr-muted); margin-bottom: 24px; font-weight: 600; }
.toltes { display: flex; justify-content: center; gap: 12px; }
</style>