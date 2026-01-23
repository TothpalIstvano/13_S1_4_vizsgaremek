<template>
  <div id="container">
    <div id="eszkoztar">
      <div class="dropdown" ref="dropdown">
        <!-- Selected value -->
        <div class="dropdown__selected" @click="toggle">
          <FontAwesomeIcon :icon="selected.icon" />
          <span>{{ selected.label }}</span>
          <FontAwesomeIcon icon="chevron-down" class="chevron" />
        </div>

        <!-- Options -->
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
      <div>
        <div v-for="item in items" :key="item.id" class="item-container">
          <div class="item">
            <img :src="item.kep" :alt="item.name" class="item-image" />
            <div class="item-info">
              <h3>{{ item.nev }}</h3>
              <p>Ár: {{ item.ar }}Ft</p>
              <p>{{ item.leiras }}</p>
              <p v-for="cimke in item.kategoria" :key="cimke.id" class="tag">#{{ cimke.nev }}"></p>
              <button @click="addToCart(item)">Kosárba</button>
            </div>
          </div>
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
#container {
  min-height: 90vh;
  display: flex;
  justify-content: center;
  align-items: center;
  font-size: 24px;
  border: 1px solid #ccc;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  margin: 10px;
  background-color: #fff;
}
#eszkoztar {
  width: 40%;
  height: 100%;
  padding: 20px;
}
.dropdown {
  position: relative;
  width: 320px;
  font-size: 18px;
}

.dropdown__selected {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 10px 14px;
  border: 1px solid #ccc;
  cursor: pointer;
  background: #fff;
}

.dropdown__menu {
  position: absolute;
  width: 100%;
  border: 1px solid #ccc;
  border-top: none;
  background: #fff;
  z-index: 10;
}

.dropdown__item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 10px 14px;
  cursor: pointer;
}

.dropdown__item:hover {
  background-color: #f2f2f2;
}

.chevron {
  margin-left: auto;
}

#tartalom {
  width: 80%;
  height: 100%;
  padding: 20px;
}
</style>