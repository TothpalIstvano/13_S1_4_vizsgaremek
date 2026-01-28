<template>
  <div id="shop">

    <!-- TOP FILTER BAR -->
    <div id="toolbar">
      <div class="search-container">        
        <div class="search-icon">
          <FontAwesomeIcon icon="fa-magnifying-glass" />
        </div>
        <input
          type="text"
          placeholder="Keresés"
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
          <h2>Termékek</h2>
        </div>

        <div class="side-bar-content">
          <div 
            v-for="cimke in cimkek" 
            :key="cimke.id" 
            class="item-tag"
            @click="toggleTagFilter(cimke)"
            :class="{ active: activeTagId === cimke.id }"
          >
            {{ cimke.nev }}
          </div>
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
                class="item-tag-sm"
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
  </div>
</template>


<script setup>
//#region imports
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import axios from 'axios'
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

async function fetchCimkek() {
  try {
    const response = await axios.get('/api/cimkek');
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
const cimkek = ref([]) // Holds the list of tags for the sidebar
const activeTagId = ref(null) // Tracks which sidebar tag is clicked

function toggleTagFilter(tag) {
  if (activeTagId.value === tag.id) {
    activeTagId.value = null; // Deselect if clicking same tag
    // Ideally refetch or reset filter here
  } else {
    activeTagId.value = tag.id;
    // Ideally filter items here or call API
    console.log('Filter by:', tag.nev);
  }
}

//#endregion

//#region mountok, unmountok, watchok, stb.
onMounted(() => {
  document.addEventListener('click', handleClickOutside)

  fetchTermek().then(data => {
    items.value = data
    console.log(items.value)
  })

  fetchCimkek().then(data => {
    cimkek.value = data
    console.log(cimkek.value)
  })
})

watch(selected, () => {
  setTimeout(() => {
    termekRendezes()
  },1000)
})

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

}
/*#endregion*/


/*#region ===== DROPDOWN ===== */
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
  top: calc(100% - 15px);
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

.side-bar-content .item-tag.active {
  background: #3f51b5;
  color: white;
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

/* ===== TAGS (Inside Card) ===== */
.tag-container {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
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