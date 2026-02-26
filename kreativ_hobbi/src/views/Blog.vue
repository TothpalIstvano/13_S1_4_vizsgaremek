<template>
  <main>
    <h1 class="title">Blog</h1>
    <a v-show="isVisible" href="#" class="ugras-felulre" @click.prevent="ugrasFelulre">
      <font-awesome-icon icon="fa-solid fa-arrow-circle-up"/>
    </a>
    
    <div class="container">
      <div class="szurok">
        <div class="kereses">        
          <div class="kereses-ikon">
            <FontAwesomeIcon icon="fa-magnifying-glass" />
          </div>
          <input
            type="text"
            placeholder="Keresés a blogbejegyzésekben..."
            class="kereses-input"
            name="kereses"
            v-model="keresett"
          />
        </div>

        <div class="aktiv-szurok" v-if="aktivCimkek.length">
          <div
            class="valasztott-cimkek"
            v-for="cimke in aktivCimkek"
            :key="cimke.id"
          >
            {{ cimke.name }}
            <span class="torles" @click="cimkeTorles(cimke.id)">✕</span>
          </div>
        </div>

        <div class="jobboldal">
          <div class="multiselect-kontener">
            <MultiSelect
              id="postCimkek"
              v-model="valasztottCimkek" 
              :options="cimkeOpciok" 
              optionLabel="name"
              optionValue="id"
              placeholder="Válassz címkét" 
              display="chip" 
              filter
              class="multiselect-stilus"
            />
          </div>

          <div class="oldal-meret">
            <label for="perPage">Megjelenítés:</label>
            <select id="perPage" v-model="oldalMeret" @change="oldalra(1)">
              <option :value="6">6</option>
              <option :value="9">9</option>
              <option :value="12">12</option>
              <option :value="24">24</option>
            </select>
          </div>
          
          <div class="dropdown" ref="dropdown">
            <div class="dropdown_opciok" @click="toggle">
              <FontAwesomeIcon :icon="valasztott.icon" />
              <span>{{ valasztott.label }}</span>
              <FontAwesomeIcon icon="chevron-down" class="chevron" />
            </div>

            <ul v-if="open" class="dropdown_menu">
              <li
                v-for="option in opciok"
                :key="option.value"
                @click="select(option)"
                class="dropdown_valasztott"
              >
                <FontAwesomeIcon :icon="option.icon" />
                <span>{{ option.label }}</span>
              </li>
            </ul>
          </div>
        </div>
      </div>
      
      <section class="kartya-kontener">
        <!-- Töltés -->
        <div v-if="loading" class="tolto-kontener">
          <div class="tolto-content">
            <p class="tolto-szoveg">Blogbejegyzések betöltése...</p>
            <div class="toltes">
              <div class="pulse-dot"></div>
              <div class="pulse-dot"></div>
              <div class="pulse-dot"></div>
            </div>
          </div>
        </div>
      
        <!-- Hiba -->
        <div v-if="error" class="hiba-kontener">
          <div class="hiba-kartya">
            <div class="hiba-icon">⚠️</div>
            <p class="hiba-uzenet">{{ error }}</p>
            <button class="ujra-gomb" @click="posztokLekerese">Újra próbálom</button>
          </div>
        </div>
        
        <!-- Blog poszt -->
        <div class="kartya-oszlop"  v-for="post in lapozottPosztok"  :key="post.id">
          <div class="kartya">
            <div class="kartya-glow"></div>
            <div class="kartya-kep">
              <img 
                :src="post.fo_kep" 
                :alt="post.cim"
                @error="kepHiba"
                loading="lazy"
              />
            </div>
            
            <div class="kartya-content">
              <div class="meta-info">
                <span class="datum"> 
                  <div class="ikon-stilus">
                    <font-awesome-icon icon="fa-solid fa-calendar"/> 
                  </div>
                  {{ formatDate(post.letrehozas_datuma) }}
                </span>
              </div>

              <div class="kartya-fejlec">
                <h3 class="kartya-cim">{{ post.cim }}</h3>
              </div>
              
              <p class="leiras">
                {{ post.kivonat || post.tartalom?.substring(0, 150) || 'Nincs leírás...' }}
                <span v-if="(post.kivonat || post.tartalom)?.length > 150">...</span>
              </p>
              
              <div class="cimkek">
                <div class="cimke" v-for="cimke in post.cimkek" :key="cimke">
                  <span class="cimke-hashtag">#</span>{{ cimke }}
                </div>
              </div>
              
              <div class="kartya-footer">
                <div class="reakcio-kontener">
                  <button 
                    class="reakcio-gomb like-gomb" 
                    :class="{ 'active': post.reakcio === 'like' }"
                    @click="reakcioKezeles(post.id, 'like')"
                  >
                    <div class="like-ikon">
                      <font-awesome-icon icon="fa-solid fa-thumbs-up"/> 
                    </div>
                    <span class="reakciok-szama">{{ post.likes_count || 0 }}</span>
                  </button>
                  
                  <button 
                    class="reakcio-gomb dislike-gomb" 
                    :class="{ 'active': post.reakcio === 'dislike' }"
                    @click="reakcioKezeles(post.id, 'dislike')"
                  >
                    <div class="like-ikon">
                      <font-awesome-icon icon="fa-solid fa-thumbs-down"/> 
                    </div>
                    <span class="reakciok-szama">{{ post.dislikes_count || 0 }}</span>
                  </button>
                </div>
                
                <button class="poszt-megtekintese" @click="posztMegjelenitese(post.id)">
                  <span>Megtekintés</span>
                  <div class="nyil-ikon">
                        <font-awesome-icon icon="fa-solid fa-arrow-right"/>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      
        <div v-if="!loading && szurtPosztok.length === 0" class="nincs-poszt">
          <div class="ures-allapot">
            <div class="ures-ikon">📝</div>
            <h3 class="ures-cim">Nincsenek találatok</h3>
          </div>
        </div>
      </section>
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
  </main>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import MultiSelect from 'primevue/multiselect';
import axios from 'axios';
import api from '@/services/api.js'
import { useAuthStore } from '@/stores/auth'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import {
  faCalendar, faHeart, faArrowRight,
  faArrowCircleUp, faThumbsUp, faThumbsDown,
  faMagnifyingGlass, faChevronDown, faArrowDown,
  faArrowUp, faSortAlphaUp, faSortAlphaDown,
  faFilter, faChevronLeft, faChevronRight
} from '@fortawesome/free-solid-svg-icons'

library.add(faCalendar, faHeart, faArrowRight,
  faArrowCircleUp, faThumbsUp, faThumbsDown,
  faMagnifyingGlass, faChevronDown, faArrowDown,
  faArrowUp, faSortAlphaUp, faSortAlphaDown,
  faFilter, faChevronLeft, faChevronRight)

import potKep from '@/assets/Public/b-pl1.jpg'

const router = useRouter()
const authStore = useAuthStore()
const posztok = ref([])
const mindenPoszt = ref([])
const loading = ref(true)
const error = ref(null)
const keresett = ref('')
const valasztottCimkek = ref([]);
const cimkeOpciok = ref([]);
const aktualisOldal = ref(1)
const oldalMeret = ref(9)

const isAuthenticated = computed(() => authStore.isAuthenticated)

const aktivCimkek = computed(() =>
  cimkeOpciok.value.filter(cimke => valasztottCimkek.value.includes(cimke.id))
);

const szurtPosztok = computed(() => {
  let filtered = [...mindenPoszt.value];
  if (keresett.value.trim()) {
    const kisbetusSzoveg = keresett.value.toLowerCase().trim();
    filtered = filtered.filter(post => {
      return (
        (post.cim && post.cim.toLowerCase().includes(kisbetusSzoveg)) ||
        (post.kivonat && post.kivonat.toLowerCase().includes(kisbetusSzoveg)) ||
        (post.tartalom && post.tartalom.toLowerCase().includes(kisbetusSzoveg))
      );
    });
  }
  
  if (valasztottCimkek.value.length > 0) {
    filtered = filtered.filter(post => {
      if (!post.cimkek || !Array.isArray(post.cimkek)) {
        return false;
      }
      
      if (post.cimkek.length > 0 && typeof post.cimkek[0] === 'object') {
        return post.cimkek.some(postTag => 
          valasztottCimkek.value.includes(postTag.id)
        );
      } 
      else if (typeof post.cimkek[0] === 'string') {
        const valasztottCimkeNevek = valasztottCimkek.value.map(cimkeId => {
          const cimke = cimkeOpciok.value.find(t => t.id === cimkeId);
          return cimke ? cimke.name : null;
        }).filter(Boolean);
        
        return post.cimkek.some(posztCimkeNev => 
          valasztottCimkeNevek.includes(posztCimkeNev)
        );
      }
      
      return false;
    });
  }
  
  return filtered;
});

const osszesenLap = computed(() => 
  Math.ceil(szurtPosztok.value.length / oldalMeret.value)
)

const lapozottPosztok = computed(() => {
  const start = (aktualisOldal.value - 1) * oldalMeret.value
  return szurtPosztok.value.slice(start, start + oldalMeret.value)
})

// Shows page numbers with "..." for long ranges, like Google
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

const opciok = [
  {
    value: 'date-desc',
    label: 'Legújabb elöl',
    icon: 'arrow-down'
  },
  {
    value: 'date-asc',
    label: 'Legrégebbi elöl',
    icon: 'arrow-up'
  },
  {
    value: 'title-asc',
    label: 'Cím szerint A-Z',
    icon: 'sort-alpha-up'
  },
  {
    value: 'title-desc',
    label: 'Cím szerint Z-A',
    icon: 'sort-alpha-down'
  },
  {
    value: 'likes-desc',
    label: 'Legtöbb kedvelés',
    icon: 'thumbs-up'
  },
  {
    value: 'likes-asc',
    label: 'Legkevesebb kedvelés',
    icon: 'thumbs-up'
  }
];

const valasztott = ref({
  value: 'date-desc',
  label: 'Legújabb elöl',
  icon: 'arrow-down'
});
const open = ref(false);
const dropdown = ref(null);

function toggle() {
  open.value = !open.value;
}

function select(option) {
  valasztott.value = option;
  open.value = false;
  rendezes();
}

function kiKattintas(event) {
  if (dropdown.value && !dropdown.value.contains(event.target)) {
    open.value = false;
  }
}

function cimkeTorles(id) {
  const index = valasztottCimkek.value.indexOf(id);
  if (index !== -1) {
    valasztottCimkek.value.splice(index, 1);
  }
}

function rendezes() {
  const sortOption = valasztott.value.value;
  
  mindenPoszt.value.sort((a, b) => {
    switch (sortOption) {
      case 'date-desc':
        return new Date(b.letrehozas_datuma || 0) - new Date(a.letrehozas_datuma || 0);
      case 'date-asc':
        return new Date(a.letrehozas_datuma || 0) - new Date(b.letrehozas_datuma || 0);
      case 'title-asc':
        return (a.cim || '').localeCompare(b.cim || '');
      case 'title-desc':
        return (b.cim || '').localeCompare(a.cim || '');
      case 'likes-desc':
        return (b.likes_count || 0) - (a.likes_count || 0);
      case 'likes-asc':
        return (a.likes_count || 0) - (b.likes_count || 0);
      default:
        return 0;
    }
  });
}

const posztMegjelenitese = (postId) => {
  router.push(`/blog/${postId}`)
}

const posztokLekerese = async () => {
  try {
    loading.value = true
    error.value = null
    
    const response = await api.get('/api/blog')
    mindenPoszt.value = response.data;
    posztok.value = [...mindenPoszt.value];
    
    rendezes();

    if (isAuthenticated.value) {
      await fetchReakcio()
    }
    
  } catch (err) {
    error.value = 'Hiba történt a blog bejegyzések betöltése közben.'
  } finally {
    loading.value = false
  }
}

const fetchReakcio = async () => {
  try {
    const response = await api.get('/api/user/reactions')
    const reakcios = response.data
    
    mindenPoszt.value = mindenPoszt.value.map(post => ({
      ...post,
      reakcio: reakcios[post.id] || null
    }))
    posztok.value = [...mindenPoszt.value];
    
  } catch (err) {
    console.error('Error fetching user reactions:', err)
  }
}

const reakcioKezeles = async (postId, reactionType) => {
  try {
    const response = await api.post(`/api/blog/${postId}/reaction`, {
      reaction: reactionType
    })
    
    const { likes_count, dislikes_count, user_reaction } = response.data
    
    const postIndex = mindenPoszt.value.findIndex(post => post.id === postId)
    if (postIndex !== -1) {
      mindenPoszt.value[postIndex].likes_count = likes_count
      mindenPoszt.value[postIndex].dislikes_count = dislikes_count
      mindenPoszt.value[postIndex].reakcio = user_reaction
      posztok.value = [...mindenPoszt.value]
    }
    
  } catch (err) {
    if (err.response?.status === 401) {
      alert('Kérjük, jelentkezzen be a reakciókhoz!')
      router.push('/Belepes')
    }
  }
}

const kepHiba = (event) => {
  event.target.src = potKep
}

const formatDate = (dateString) => {
  if (!dateString) return 'Ismeretlen dátum'
  return dateString
}

const fetchCimkek = async () => {
    try {
        const response = await axios.get('/api/cimkek');
        
        cimkeOpciok.value = response.data.map(cimke => ({
            id: cimke.id,
            name: cimke.nev,
            code: cimke.nev.toLowerCase().replace(/\s+/g, '_')
        }));
    } catch (error) {
        console.error('Error fetching cimkek:', error);
    }
};

onMounted(() => {
  document.addEventListener('click', kiKattintas);
  posztokLekerese();
  fetchCimkek();
});

onBeforeUnmount(() => {
  document.removeEventListener('click', kiKattintas);
});

watch([keresett, valasztottCimkek], () => {
  aktualisOldal.value = 1
})

const isVisible = ref(false);

const handleScroll = () => {
  isVisible.value = window.scrollY > 200;
};

const ugrasFelulre = () => {
  window.scrollTo({ top: 0, behavior: 'smooth' });
};

onMounted(() => {
  window.addEventListener('scroll', handleScroll);
});

onBeforeUnmount(() => {
  window.removeEventListener('scroll', handleScroll);
});
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css?family=Heebo:400,700|Open+Sans:400,700');

main {
  min-height: 100vh;
  margin: 0;
  padding: 0;
  text-align: center;
}

.title {
  font-weight: 700;
  font-size: 45px;
  color: var(--mk-text-dark);
  display: inline-block;
  background-image: linear-gradient(90deg, #a08283, #4d0303);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
}

.container {
  max-width: 1800px;
  margin: 0 auto;
  padding: 0 32px;
}

.szurok {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  background-color: #a58787;
  border-radius: 8px;
  padding: 20px 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  flex-wrap: wrap;
  gap: 16px;
}

.aktiv-szurok {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  flex: 1;
  margin: 0 16px;
  min-height: 40px;
}

.valasztott-cimkek {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: #ffece3;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.valasztott-cimkek:hover {
  background: #ffcbc7;
  transform: translateY(-1px);
}

.valasztott-cimkek .torles {
  cursor: pointer;
  font-weight: bold;
  opacity: 0.7;
  margin-left: 4px;
  font-size: 16px;
  line-height: 1;
}

.valasztott-cimkek .torles:hover {
  opacity: 1;
}

.jobboldal {
  display: flex;
  align-items: center;
  gap: 16px;
}

.multiselect-kontener {
  width: 300px;
}

.multiselect-stilus {
  width: 100%;
}

:deep(.p-multiselect) {
  border: 2px solid #e2e8f0 !important;
  border-radius: 6px !important;
  transition: all 0.3s ease !important;
  background: white !important;
  min-height: 44px !important;
}

:deep(.p-multiselect:not(.p-disabled):hover) {
  border-color: #cbd5e0 !important;
}

:deep(.p-multiselect:not(.p-disabled).p-focus) {
  border-color: #d49535 !important;
  box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1) !important;
  outline: none !important;
}

:deep(.p-multiselect-label) {
  padding: 10px 14px !important;
  font-size: 15px !important;
  color: #4a5568 !important;
  text-align: left;
}

:deep(.p-multiselect-panel) {
  border-radius: 6px !important;
  border: 1px solid #e2e8f0 !important;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1) !important;
}

:deep(.p-multiselect-chip .p-chip) {
  background: linear-gradient(135deg, #d49535 0%, #d45a35 100%) !important;
  color: white !important;
  border-radius: 6px !important;
  padding: 6px 12px !important;
  font-weight: 500 !important;
  margin-right: 6px !important;
  margin-bottom: 4px !important;
  font-size: 13px !important;
}

:deep(.p-multiselect-chip .p-chip .p-chip-remove-icon) {
  color: white !important;
  opacity: 0.8 !important;
}

:deep(.p-multiselect-chip .p-chip .p-chip-remove-icon:hover) {
  opacity: 1 !important;
}

:deep(.p-checkbox-box) {
  border-radius: 6px !important;
  border: 2px solid #cbd5e0 !important;
}

:deep(.p-checkbox-box.p-highlight) {
  background: #d49535 !important;
  border-color: #993b3b !important;
}

:deep(.p-multiselect-header) {
  padding: 12px 16px !important;
  border-bottom: 1px solid #e2e8f0 !important;
  background: #f8fafc !important;
  border-radius: 8px 8px 0 0 !important;
}

:deep(.p-multiselect-filter) {
  padding: 8px 12px !important;
  border-radius: 8px !important;
  border: 1px solid #e2e8f0 !important;
}

:deep(.p-multiselect-filter:focus) {
  border-color: #d49535 !important;
  box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1) !important;
  outline: none !important;
}

.lapozas {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 6px;
  padding: 32px 0 16px;
  flex-wrap: wrap;
}

.lap-gomb {
  min-width: 40px;
  height: 40px;
  padding: 0 12px;
  border: 1px solid #e5e7eb;
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
  background: var(--b-gomb);
  color: white;
  border-color: var(--b-gomb);
  transform: translateY(-2px);
}

.lap-gomb:disabled {
  opacity: 0.35;
  cursor: not-allowed;
}

.aktiv-lap {
  background: var(--b-gomb) !important;
  color: white !important;
  border-color: var(--b-gomb) !important;
  box-shadow: 0 4px 6px -1px rgba(237, 58, 58, 0.3);
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
}

.oldal-meret select {
  padding: 8px 10px;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  background: #f8f9fa;
  font-size: 14px;
  cursor: pointer;
  color: #494d55;
}

.oldal-meret select:focus {
  outline: none;
  border-color: var(--b-gomb);
}

.dropdown {
  position: relative;
  width: 250px;
  font-size: 15px;
}

.dropdown_opciok {
  display: flex;
  gap: 10px;
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
  background: white;
  transition: all 0.3s ease;
  min-height: 44px;
}

.dropdown_opciok:hover {
  border-color: #cbd5e0;
}

.dropdown_opciok:active {
  border-color: #d49535;
}

.dropdown_menu {
  position: absolute;
  top: calc(100% - 14px);
  width: 100%;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background: white;
  z-index: 10;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  padding: 0;
}

.dropdown_valasztott {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 16px;
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 1px solid #f1f5f9;
}

.dropdown_valasztott:last-child {
  border-bottom: none;
}

.dropdown_valasztott:hover {
  background: #f8fafc;
  color: #d49535;
}

.chevron {
  margin-left: auto;
  transition: transform 0.3s ease;
}

.dropdown_opciok.active .chevron {
  transform: rotate(180deg);
}

.kereses {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  background: white;
  width: 300px;
  height: 44px;
  transition: all 0.3s ease;
}

.kereses:focus-within {
  border-color: #d49535;
  box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1);
}

.kereses-ikon {
  color: #718096;
  display: flex;
  align-items: center;
  font-size: 16px;
}

.kereses input {
  border: none;
  outline: none;
  width: 100%;
  font-size: 15px;
  background: transparent;
  color: #4a5568;
}

.kereses input::placeholder {
  color: #a0aec0;
}


.ugras-felulre {
	display: flex;
	align-items: center;
	justify-content: center;
	position: fixed;
	bottom: 20px;
	right: 20px;
	z-index: 1000;
	width: 60px;
	height: 60px;
	color: black;
	background-color: white;
	border-radius: 50%;
	box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
	opacity: 0.5;
	transition: opacity 0.3s ease;

	&:hover {
		opacity: 1;
	}

	> svg {
		width: 24px;
		height: 24px;
	}
}

.kartya-kontener {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 64px;
  padding: 48px 0;
}

.kartya-oszlop {
  position: relative;
}

.kartya {
  background: var(--b-kartya);
  border-radius: 20px;
  padding: 15px;
  overflow: hidden;
  position: relative;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 0 0 3px rgba(237, 58, 58, 0.1);
  height: 100%;
  display: flex;
  flex-direction: column;
  border: 1px solid #e5e7eb;
  text-align: left;
}

.kartya-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  opacity: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.kartya:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  color: var(--b-text-dark);
}

.kartya:hover .kartya-glow {
  opacity: 1;
  height: 3px;
}

.kartya-kep {
  height: 240px;
  position: relative;
  overflow: hidden;
  border-radius: 20px;
}

.kartya-kep::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 50%, rgba(0, 0, 0, 0.3));
  z-index: 1;
}

.kartya-kep img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: all, var(--b-transition-time);
}

.kartya:hover .kartya-kep img {
  transform: scale(1.10);
}

.kartya-content {
  padding: 18px;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.kartya-fejlec {
  margin-bottom: 16px;
}

.kartya-cim {
  padding: 16px 0 8px 0;
  font-size: 24px;
  margin: 0;
  transition: all, var(--b-transition-time);
  display: inline-block;
  background-image: linear-gradient(90deg, #b39999, #cacaca);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 3px;
}

.kartya:hover .kartya-cim {
  color: var(--b-text-dark);
}

.meta-info {
  margin-bottom: 16px;
}

.datum {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #494d55;
  background: #eedada;
  padding: 6px 12px;
  border-radius: 20px;
  font-weight: 500;
}

.ikon-stilus {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
}

.leiras {
  padding: 16px 0;
  font-size: 16px;
  margin: 0;
  line-height: 1.6;
  min-height: 80px;
  overflow: hidden;
}

.kartya:hover .leiras {
  color: var(--b-text-dark);  
}

.cimkek {
  display: flex;
  flex-wrap: wrap;
  margin: 16px 0;
  gap: 8px;
}

.cimke {
  font-size: 12px;
  background: var(--b-tag);
  color: var(--b-text-light);
  border-radius: 20px;
  padding: 5px 13px;
  line-height: 24px;
  transition: all, var(--b-transition-time);
  font-weight: 500;
  box-shadow: inset 0px 0px 10px 1px rgba(80, 33, 0, 0.5);
  display: inline-flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid #e5e7eb;
}

.cimke:hover {
  background: var(--b-tag-hover);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 0 0 3px rgba(237, 58, 58, 0.1);
}

.cimke-hashtag {
  opacity: 0.7;
  font-size: 14px;
}

.kartya-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
  padding-top: 20px;
  border-top: 1px solid #d8c7c7;
}

.reakcio-kontener {
  display: flex;
  gap: 8px;
  flex: 1;
}

.reakcio-gomb {
  display: flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: 1px solid #e5e7eb;
  color: #494d55;
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background-color: #f8f9fa;
  font-size: 14px;
}

.reakcio-gomb:hover {
  transform: translateY(-2px);
}

.like-gomb:hover {
  background-color: #d1f7c4;
  border-color: #22c55e;
  color: #16a34a;
}

.dislike-gomb:hover {
  background-color: #ffe4e6;
  border-color: #f43f5e;
  color: #dc2626;
}

.reakcio-gomb.active {
  font-weight: 600;
}

.like-gomb.active {
  background-color: #bbf7d0;
  border-color: #16a34a;
  color: #15803d;
}

.dislike-gomb.active {
  background-color: #fecdd3;
  border-color: #e11d48;
  color: #be123c;
}

.like-ikon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.reakciok-szama {
  font-weight: 500;
  min-width: 20px;
}

.poszt-megtekintese {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--b-gomb);
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 12px;
  font-weight: 500;
  font-size: 16px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 6px -1px rgba(237, 58, 58, 0.2);
}

.poszt-megtekintese:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(237, 58, 58, 0.3);
  background: var(--b-gomb-hover);
}

.nyil-ikon {
  transition: transform 0.3s ease;
}

.poszt-megtekintese:hover .nyil-ikon {
  transform: translateX(3px);
}

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
  background: linear-gradient(135deg, #6d2020 0%, #520606 100%);
  border-radius: 50%;
  animation: pulse 1.4s infinite ease-in-out;
}

.pulse-dot:nth-child(2) {
  animation-delay: 0.2s;
}

.pulse-dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
    opacity: 1;
  }
  50% {
    transform: scale(0.6);
    opacity: 0.5;
  }
}

.hiba-kontener {
  grid-column: 1 / -1;
}

.hiba-kartya {
  background: white;
  border-radius: 20px;
  padding: 48px;
  text-align: center;
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
  border: 1px solid #e5e7eb;
}

.hiba-icon {
  font-size: 48px;
  margin-bottom: 24px;
}

.hiba-uzenet {
  font-size: 18px;
  color: var(--text-dark);
  margin-bottom: 32px;
  line-height: 1.6;
}

.ujra-gomb {
  background: linear-gradient(135deg, #5f1010 0%, #aa2323 100%);
  color: white;
  border: none;
  padding: 14px 32px;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 6px -1px rgba(124, 58, 237, 0.2);
}

.ujra-gomb:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(124, 58, 237, 0.3);
}

/* Nincs poszt */
.nincs-poszt {
  grid-column: 1 / -1;
}

.ures-allapot {
  text-align: center;
  padding: 64px 32px;
  background: white;
  border-radius: 20px;
  box-shadow: var(--shadow-lg);
  border: 1px solid #e5e7eb;
}

.ures-ikon {
  font-size: 64px;
  margin-bottom: 24px;
  opacity: 0.8;
}

.ures-cim {
  font-family: 'Poppins', sans-serif;
  font-size: 28px;
  color: var(--text-dark);
  margin-bottom: 12px;
  font-weight: 600;
}

@media (max-width: 1200px) {
  .kartya-kontener {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 24px;
  }
  
  .szurok {
    padding: 16px 20px;
  }
}

@media (max-width: 992px) {
  .szurok {
    flex-direction: column;
    align-items: stretch;
    gap: 16px;
  }
  
  .kereses,
  .multiselect-kontener,
  .dropdown {
    width: 100%;
  }
  
  .jobboldal {
    width: 100%;
    flex-direction: column;
    gap: 16px;
  }
  
  .aktiv-szurok {
    margin: 0;
    justify-content: center;
  }
}

@media (max-width: 768px) {
  .title {
    font-size: 36px;
  }
  
  .container {
    padding: 0 20px;
  }
  
  .kartya-kontener {
    grid-template-columns: 1fr;
    gap: 24px;
    padding: 32px 0;
  }
  
  .szurok {
    padding: 14px 16px;
  }
}

@media (max-width: 480px) {
  .title {
    font-size: 28px;
  }
  
  .container {
    padding: 0 16px;
  }
  
  .kartya-kontener {
    grid-template-columns: 1fr;
  }
  
  .kartya {
    max-width: 100%;
  }
  
  .kartya-footer {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .poszt-megtekintese {
    justify-content: center;
  }
}

</style>