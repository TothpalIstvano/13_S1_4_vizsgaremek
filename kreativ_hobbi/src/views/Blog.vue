<template>
  <main>
    <h1 class="title">Blog</h1>
    <a v-show="isVisible" href="#" class="back-to-top-control" @click.prevent="scrollToTop">
      <font-awesome-icon icon="fa-solid fa-arrow-circle-up"/>
    </a>
    
    <div class="content-wrapper">
      <!-- Szűrők (Working like Aruhaz.vue) -->
      <div class="szurok">
        <div class="search-container">        
          <div class="search-icon">
            <FontAwesomeIcon icon="fa-magnifying-glass" />
          </div>
          <input
            type="text"
            placeholder="Keresés a blogbejegyzésekben..."
            class="search-input"
            name="search"
            v-model="searchTerm"
          />
        </div>

        <div class="active-filters" v-if="activeCimkek.length">
          <div
            class="filter-chip"
            v-for="tag in activeCimkek"
            :key="tag.id"
          >
            {{ tag.name }}
            <span class="remove" @click="removeCimke(tag.id)">✕</span>
          </div>
        </div>

        <div class="filters-right">
          <div class="multiselect-container">
            <MultiSelect
              id="postCimkek"
              v-model="selectedCimkek" 
              :options="tagOptions" 
              optionLabel="name"
              optionValue="id"
              placeholder="Válassz címkét" 
              display="chip" 
              filter
              class="custom-multiselect"
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
      </div>
      
      <section class="cards-wrapper">
        <!-- Loading -->
        <div v-if="loading" class="loading-container">
          <div class="loading-content">
            <p class="loading-text">Blogbejegyzések betöltése...</p>
            <div class="spinner-wrapper">
              <div class="pulse-dot"></div>
              <div class="pulse-dot"></div>
              <div class="pulse-dot"></div>
            </div>
          </div>
        </div>
      
        <!-- Error -->
        <div v-if="error" class="error-container">
          <div class="error-card">
            <div class="error-icon">⚠️</div>
            <p class="error-message">{{ error }}</p>
            <button class="retry-btn" @click="fetchBlogPosts">Újra próbálom</button>
          </div>
        </div>
        
        <!-- Blog poszt -->
        <div class="card-grid-space"  v-for="post in filteredPosts"  :key="post.id">
          <div class="card">
            <div class="card-glow"></div>
            <div class="card-img-holder">
              <img 
                :src="post.fo_kep" 
                :alt="post.cim"
                @error="handleImageError"
                loading="lazy"
              />
            </div>
            
            <div class="card-content">
              <div class="meta-info">
                <span class="blog-time"> 
                  <div class="icon-wrapper">
                    <font-awesome-icon icon="fa-solid fa-calendar"/> 
                  </div>
                  {{ formatDate(post.letrehozas_datuma) }}
                </span>
              </div>

              <div class="card-header">
                <h3 class="blog-title">{{ post.cim }}</h3>
              </div>
              
              <p class="description">
                {{ post.kivonat || post.tartalom?.substring(0, 150) || 'Nincs leírás...' }}
                <span v-if="(post.kivonat || post.tartalom)?.length > 150">...</span>
              </p>
              
              <div class="tags">
                <div class="tag" v-for="tag in post.cimkek" :key="tag">
                  <span class="tag-hash">#</span>{{ tag }}
                </div>
              </div>
              
              <div class="card-footer">
                <div class="reaction-container">
                  <button 
                    class="reaction-btn thumbs-up-btn" 
                    :class="{ 'active': post.userReaction === 'like' }"
                    @click="handleReaction(post.id, 'like')"
                  >
                    <div class="thumb-icon">
                      <font-awesome-icon icon="fa-solid fa-thumbs-up"/> 
                    </div>
                    <span class="reaction-count">{{ post.likes_count || 0 }}</span>
                  </button>
                  
                  <button 
                    class="reaction-btn thumbs-down-btn" 
                    :class="{ 'active': post.userReaction === 'dislike' }"
                    @click="handleReaction(post.id, 'dislike')"
                  >
                    <div class="thumb-icon">
                      <font-awesome-icon icon="fa-solid fa-thumbs-down"/> 
                    </div>
                    <span class="reaction-count">{{ post.dislikes_count || 0 }}</span>
                  </button>
                </div>
                
                <button class="view-btn" @click="navigateToBlog(post.id)">
                  <span>Megtekintés</span>
                  <div class="arrow-icon">
                        <font-awesome-icon icon="fa-solid fa-arrow-right"/>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      
        <div v-if="!loading && filteredPosts.length === 0" class="no-posts-container">
          <div class="empty-state">
            <div class="empty-icon">📝</div>
            <h3 class="empty-title">Nincsenek találatok</h3>
            <p class="empty-subtitle">Próbálj másik szűrőt vagy keresési kifejezést!</p>
          </div>
        </div>
      </section>
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
  faFilter
} from '@fortawesome/free-solid-svg-icons'

library.add(faCalendar, faHeart, faArrowRight,
  faArrowCircleUp, faThumbsUp, faThumbsDown,
  faMagnifyingGlass, faChevronDown, faArrowDown,
  faArrowUp, faSortAlphaUp, faSortAlphaDown,
  faFilter)

import fallbackImage from '@/assets/Public/b-pl1.jpg'

const router = useRouter()
const authStore = useAuthStore()
const posztok = ref([])
const allPosts = ref([]) // Store original posts
const loading = ref(true)
const error = ref(null)
const searchTerm = ref('')
const selectedCimkek = ref([]);
const tagOptions = ref([]);

const isAuthenticated = computed(() => authStore.isAuthenticated)

// Computed properties for filtering
const activeCimkek = computed(() =>
  tagOptions.value.filter(tag => selectedCimkek.value.includes(tag.id))
);

// Fix: Proper filtering logic
const filteredPosts = computed(() => {
  // Start with all posts
  let filtered = [...allPosts.value];
  
  // Apply search filter if there's a search term
  if (searchTerm.value.trim()) {
    const searchLower = searchTerm.value.toLowerCase().trim();
    filtered = filtered.filter(post => {
      return (
        (post.cim && post.cim.toLowerCase().includes(searchLower)) ||
        (post.kivonat && post.kivonat.toLowerCase().includes(searchLower)) ||
        (post.tartalom && post.tartalom.toLowerCase().includes(searchLower))
      );
    });
  }
  
  // Apply tag filter if tags are selected
  if (selectedCimkek.value.length > 0) {
    filtered = filtered.filter(post => {
      // Check if post has any of the selected tags
      // First, let's check the structure of post.cimkek
      if (!post.cimkek || !Array.isArray(post.cimkek)) {
        return false; // No tags on this post
      }
      
      // If cimkek are objects with id property
      if (post.cimkek.length > 0 && typeof post.cimkek[0] === 'object') {
        return post.cimkek.some(postTag => 
          selectedCimkek.value.includes(postTag.id)
        );
      } 
      // If cimkek are tag names (strings)
      else if (typeof post.cimkek[0] === 'string') {
        // Get the names of selected tags
        const selectedTagNames = selectedCimkek.value.map(tagId => {
          const tag = tagOptions.value.find(t => t.id === tagId);
          return tag ? tag.name : null;
        }).filter(Boolean);
        
        return post.cimkek.some(postTagName => 
          selectedTagNames.includes(postTagName)
        );
      }
      
      return false;
    });
  }
  
  return filtered;
});

// Sorting options
const options = [
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

const selected = ref({
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
  selected.value = option;
  open.value = false;
  applySorting();
}

function handleClickOutside(event) {
  if (dropdown.value && !dropdown.value.contains(event.target)) {
    open.value = false;
  }
}

function removeCimke(id) {
  const index = selectedCimkek.value.indexOf(id);
  if (index !== -1) {
    selectedCimkek.value.splice(index, 1);
  }
}

function applySorting() {
  const sortOption = selected.value.value;
  
  allPosts.value.sort((a, b) => {
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

// Watch for changes in selected tags and log for debugging
watch(selectedCimkek, (newVal) => {
  console.log('Selected tags changed:', newVal);
  console.log('Active tags:', activeCimkek.value);
  console.log('Filtered posts count:', filteredPosts.value.length);
}, { deep: true });

const navigateToBlog = (postId) => {
  router.push(`/blog/${postId}`)
}

const fetchBlogPosts = async () => {
  try {
    loading.value = true
    error.value = null
    
    const response = await api.get('/api/blog')
    allPosts.value = response.data;
    posztok.value = [...allPosts.value]; // Initialize posztok as well
    console.log('Fetched posts:', allPosts.value);
    console.log('First post cimkek:', allPosts.value[0]?.cimkek);
    
    applySorting(); // Apply initial sorting

    if (isAuthenticated.value) {
      await fetchUserReactions()
    }
    
  } catch (err) {
    console.error('Error fetching blog posts:', err)
    error.value = 'Hiba történt a blog bejegyzések betöltése közben.'
  } finally {
    loading.value = false
  }
}

const fetchUserReactions = async () => {
  try {
    const response = await api.get('/api/user/reactions')
    const userReactions = response.data
    
    allPosts.value = allPosts.value.map(post => ({
      ...post,
      userReaction: userReactions[post.id] || null
    }))
    posztok.value = [...allPosts.value];
    
  } catch (err) {
    console.error('Error fetching user reactions:', err)
  }
}

const handleReaction = async (postId, reactionType) => {
  if (!isAuthenticated.value) {
    alert('Kérjük, jelentkezzen be a reakciókhoz!')
    router.push('/Belepes')
    return
  }
  
  try {
    const response = await api.post(`/api/blog/${postId}/reaction`, {
      reaction: reactionType
    })
    
    const { likes_count, dislikes_count, user_reaction } = response.data
    
    const postIndex = allPosts.value.findIndex(post => post.id === postId)
    if (postIndex !== -1) {
      allPosts.value[postIndex].likes_count = likes_count
      allPosts.value[postIndex].dislikes_count = dislikes_count
      allPosts.value[postIndex].userReaction = user_reaction
      posztok.value = [...allPosts.value];
    }
    
  } catch (err) {
    console.error('Error updating reaction:', err)
    if (err.response?.status === 401) {
      alert('Hitelesítési hiba. Kérjük, jelentkezzen be újra.')
    }
  }
}

const handleImageError = (event) => {
  event.target.src = fallbackImage
}

const formatDate = (dateString) => {
  if (!dateString) return 'Ismeretlen dátum'
  return dateString
}

const fetchTagsFromDatabase = async () => {
    try {
        const response = await axios.get('/api/cimkek');
        
        tagOptions.value = response.data.map(tag => ({
            id: tag.id,
            name: tag.nev,
            code: tag.nev.toLowerCase().replace(/\s+/g, '_')
        }));
        console.log('Fetched tags:', tagOptions.value);
    } catch (error) {
        console.error('Error fetching tags:', error);
    }
};

onMounted(() => {
  document.addEventListener('click', handleClickOutside);
  fetchBlogPosts();
  fetchTagsFromDatabase();
});

onBeforeUnmount(() => {
  document.removeEventListener('click', handleClickOutside);
});

const isVisible = ref(false);

const handleScroll = () => {
  isVisible.value = window.scrollY > 200;
};

const scrollToTop = () => {
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

.content-wrapper {
  max-width: 1800px;
  margin: 0 auto;
  padding: 0 32px;
}

.szurok {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
  background-color: #999;
  border-radius: 14px;
  padding: 20px 24px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  flex-wrap: wrap;
  gap: 16px;
}

.active-filters {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  flex: 1;
  margin: 0 16px;
  min-height: 40px;
}

.filter-chip {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: #e3e8ff;
  border-radius: 999px;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
  border: 1px solid transparent;
}

.filter-chip:hover {
  background: #c7d4ff;
  transform: translateY(-1px);
}

.filter-chip .remove {
  cursor: pointer;
  font-weight: bold;
  opacity: 0.7;
  margin-left: 4px;
  font-size: 16px;
  line-height: 1;
}

.filter-chip .remove:hover {
  opacity: 1;
}

.filters-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.multiselect-container {
  width: 300px;
}

.custom-multiselect {
  width: 100%;
}

:deep(.p-multiselect) {
  border: 2px solid #e2e8f0 !important;
  border-radius: 10px !important;
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
}

:deep(.p-multiselect-panel) {
  border-radius: 10px !important;
  border: 1px solid #e2e8f0 !important;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1) !important;
}

:deep(.p-multiselect-chip .p-chip) {
  background: linear-gradient(135deg, #d49535 0%, #d45a35 100%) !important;
  color: white !important;
  border-radius: 20px !important;
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
  border-color: #667eea !important;
}

:deep(.p-multiselect-header) {
  padding: 12px 16px !important;
  border-bottom: 1px solid #e2e8f0 !important;
  background: #f8fafc !important;
  border-radius: 10px 10px 0 0 !important;
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

.dropdown {
  position: relative;
  width: 250px;
  font-size: 15px;
}

.dropdown__selected {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  cursor: pointer;
  background: white;
  transition: all 0.3s ease;
  min-height: 44px;
}

.dropdown__selected:hover {
  border-color: #cbd5e0;
}

.dropdown__selected:active {
  border-color: #d49535;
}

.dropdown__menu {
  position: absolute;
  top: calc(100% + 4px);
  width: 100%;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  background: white;
  z-index: 10;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.dropdown__item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 16px;
  cursor: pointer;
  transition: all 0.2s;
  border-bottom: 1px solid #f1f5f9;
}

.dropdown__item:last-child {
  border-bottom: none;
}

.dropdown__item:hover {
  background: #f8fafc;
  color: #d49535;
}

.chevron {
  margin-left: auto;
  transition: transform 0.3s ease;
}

.dropdown__selected.active .chevron {
  transform: rotate(180deg);
}

.search-container {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 16px;
  border: 2px solid #e2e8f0;
  border-radius: 10px;
  background: white;
  width: 300px;
  height: 44px;
  transition: all 0.3s ease;
}

.search-container:focus-within {
  border-color: #d49535;
  box-shadow: 0 0 0 3px rgba(77, 138, 240, 0.1);
}

.search-icon {
  color: #718096;
  display: flex;
  align-items: center;
  font-size: 16px;
}

.search-container input {
  border: none;
  outline: none;
  width: 100%;
  font-size: 15px;
  background: transparent;
  color: #4a5568;
}

.search-container input::placeholder {
  color: #a0aec0;
}


.back-to-top-control {
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

.cards-wrapper {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 64px;
  padding: 48px 0;
}

.card-grid-space {
  position: relative;
}

.card {
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

.card-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  opacity: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  color: var(--b-text-dark);
}

.card:hover .card-glow {
  opacity: 1;
  height: 3px;
}

.card-img-holder {
  height: 240px;
  position: relative;
  overflow: hidden;
  border-radius: 20px;
}

.card-img-holder::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(to bottom, transparent 50%, rgba(0, 0, 0, 0.3));
  z-index: 1;
}

.card-img-holder img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: all, var(--b-transition-time);
}

.card:hover .card-img-holder img {
  transform: scale(1.10);
}

.card-content {
  padding: 18px;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.card-header {
  margin-bottom: 16px;
}

.blog-title {
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

.card:hover .blog-title {
  color: var(--b-text-dark);
}

.meta-info {
  margin-bottom: 16px;
}

.blog-time {
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

.icon-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
}

.description {
  padding: 16px 0;
  font-size: 16px;
  margin: 0;
  line-height: 1.6;
  min-height: 80px;
  overflow: hidden;
}

.card:hover .description {
  color: var(--b-text-dark);  
}

.tags {
  display: flex;
  flex-wrap: wrap;
  margin: 16px 0;
  gap: 8px;
}

.tag {
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

.tag:hover {
  background: var(--b-tag-hover);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 0 0 3px rgba(237, 58, 58, 0.1);
}

.tag-hash {
  opacity: 0.7;
  font-size: 14px;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
  padding-top: 20px;
  border-top: 1px solid #d8c7c7;
}

.reaction-container {
  display: flex;
  gap: 8px;
  flex: 1;
}

.reaction-btn {
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

.reaction-btn:hover {
  transform: translateY(-2px);
}

.thumbs-up-btn:hover {
  background-color: #d1f7c4;
  border-color: #22c55e;
  color: #16a34a;
}

.thumbs-down-btn:hover {
  background-color: #ffe4e6;
  border-color: #f43f5e;
  color: #dc2626;
}

.reaction-btn.active {
  font-weight: 600;
}

.thumbs-up-btn.active {
  background-color: #bbf7d0;
  border-color: #16a34a;
  color: #15803d;
}

.thumbs-down-btn.active {
  background-color: #fecdd3;
  border-color: #e11d48;
  color: #be123c;
}

.thumb-icon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.reaction-count {
  font-weight: 500;
  min-width: 20px;
}

.view-btn {
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

.view-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(237, 58, 58, 0.3);
  background: var(--b-gomb-hover);
}

.arrow-icon {
  transition: transform 0.3s ease;
}

.view-btn:hover .arrow-icon {
  transform: translateX(3px);
}

.loading-container {
  grid-column: 1 / -1;
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 400px;
}

.loading-content {
  text-align: center;
}

.loading-text {
  font-size: 18px;
  color: #363636;
  margin-bottom: 32px;
  font-weight: 500;
}

.spinner-wrapper {
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

.error-container {
  grid-column: 1 / -1;
}

.error-card {
  background: white;
  border-radius: 20px;
  padding: 48px;
  text-align: center;
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
  border: 1px solid #e5e7eb;
}

.error-icon {
  font-size: 48px;
  margin-bottom: 24px;
}

.error-message {
  font-size: 18px;
  color: var(--text-dark);
  margin-bottom: 32px;
  line-height: 1.6;
}

.retry-btn {
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

.retry-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(124, 58, 237, 0.3);
}

/* Empty State */
.no-posts-container {
  grid-column: 1 / -1;
}

.empty-state {
  text-align: center;
  padding: 64px 32px;
  background: white;
  border-radius: 20px;
  box-shadow: var(--shadow-lg);
  border: 1px solid #e5e7eb;
}

.empty-icon {
  font-size: 64px;
  margin-bottom: 24px;
  opacity: 0.8;
}

.empty-title {
  font-family: 'Poppins', sans-serif;
  font-size: 28px;
  color: var(--text-dark);
  margin-bottom: 12px;
  font-weight: 600;
}

.empty-subtitle {
  color: #6b7280;
  font-size: 18px;
  max-width: 400px;
  margin: 0 auto;
}

@media (max-width: 1200px) {
  .cards-wrapper {
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
  
  .search-container,
  .multiselect-container,
  .dropdown {
    width: 100%;
  }
  
  .filters-right {
    width: 100%;
    flex-direction: column;
    gap: 16px;
  }
  
  .active-filters {
    margin: 0;
    justify-content: center;
  }
}

@media (max-width: 768px) {
  .title {
    font-size: 36px;
  }
  
  .content-wrapper {
    padding: 0 20px;
  }
  
  .cards-wrapper {
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
  
  .content-wrapper {
    padding: 0 16px;
  }
  
  .cards-wrapper {
    grid-template-columns: 1fr;
  }
  
  .card {
    max-width: 100%;
  }
  
  .card-footer {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }
  
  .view-btn {
    justify-content: center;
  }
}

</style>