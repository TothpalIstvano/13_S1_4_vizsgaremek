<template>
  <div id="shop">

    <!-- TOP FILTER BAR -->
    <div id="toolbar">
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

    <!-- PRODUCT GRID -->
    <div id="products">
      <div v-for="item in items" :key="item.id" class="product-card">
        <img :src="item.termek_fo_kep.url_Link" :alt="item.termek_fo_kep.alt_szoveg" class="product-image" />

        <div class="product-body">
          <h3 class="product-title">{{ item.nev }}</h3>
          <p class="product-price">{{ item.ar }} Ft</p>

          <p class="product-desc">{{ item.leiras }}</p>

          <div class="tag-container">
            <span
              v-for="cimke in item.termek_cimkek"
              :key="cimke.id"
              class="item-tag"
            >
              {{ cimke.nev }}
            </span>
          </div>

          <button class="add-btn" @click="addToCart(item)">
            Kosárba
          </button>
        </div>
      </div>
    </div>

  </div>
</template>


<script setup>
//#region imports
import { ref, onMounted, onBeforeUnmount } from 'vue'
import axios from 'axios'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import {
  faArrowUp,
  faArrowDown,
  faSortAlphaUp,
  faSortAlphaDown,
  faChevronDown
} from '@fortawesome/free-solid-svg-icons'

library.add(
  faArrowUp,
  faArrowDown,
  faSortAlphaUp,
  faSortAlphaDown,
  faChevronDown
)
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


const selected = ref(options[0])
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

const items = ref([])

//#endregion

//#region mountok, unmountok, watchok, stb.
onMounted(() => {
  document.addEventListener('click', handleClickOutside)

  fetchTermek().then(data => {
    items.value = data
    console.log(items.value)
  })
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
  background: #f6f7fb;
}

/* ===== TOP TOOLBAR ===== */
#toolbar {
  display: flex;
  justify-content: flex-end;
  margin-bottom: 24px;
}

/* ===== DROPDOWN ===== */
.dropdown {
  position: relative;
  width: 260px;
  font-size: 15px;
}

.dropdown__selected {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border: 1px solid #d0d0d0;
  border-radius: 8px;
  cursor: pointer;
  background: white;
}

.dropdown__menu {
  position: absolute;
  top: 100%;
  width: 100%;
  border: 1px solid #d0d0d0;
  border-radius: 0 0 8px 8px;
  background: white;
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

/* ===== PRODUCT GRID ===== */
#products {
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
}

/* ===== TAGS ===== */
.tag-container {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.item-tag {
  background: #e3e8ff;
  color: #2b3ea8;
  font-size: 12px;
  padding: 4px 8px;
  border-radius: 999px;
}

.item-tag:hover {
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

</style>