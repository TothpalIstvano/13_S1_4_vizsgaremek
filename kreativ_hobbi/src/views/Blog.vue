<template>
  <main>
    <h1 class="title">Blog</h1>
    <a v-show="isVisible" href="#" class="back-to-top-control" @click.prevent="scrollToTop">
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" stroke-width="1" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
			<path stroke="none" d="M0 0h24v24H0z" fill="none" />
			<path d="M17 3.34a10 10 0 1 1 -14.995 8.984l-.005 -.324l.005 -.324a10 10 0 0 1 14.995 -8.336zm-4.98 3.66l-.163 .01l-.086 .016l-.142 .045l-.113 .054l-.07 .043l-.095 .071l-.058 .054l-4 4l-.083 .094a1 1 0 0 0 1.497 1.32l2.293 -2.293v5.586l.007 .117a1 1 0 0 0 1.993 -.117v-5.585l2.293 2.292l.094 .083a1 1 0 0 0 1.32 -1.497l-4 -4l-.082 -.073l-.089 -.064l-.113 -.062l-.081 -.034l-.113 -.034l-.112 -.02l-.098 -.006z" stroke-width="0" fill="currentColor" />
		</svg>
	</a>
    <div class="content-wrapper">
      <section class="cards-wrapper">
        <!-- Loading state -->
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
      
        <!-- Error state -->
        <div v-if="error" class="error-container">
          <div class="error-card">
            <div class="error-icon">⚠️</div>
            <p class="error-message">{{ error }}</p>
            <button class="retry-btn" @click="fetchBlogPosts">Újra próbálom</button>
          </div>
        </div>
        
        <!-- Blog posts -->
        <div class="card-grid-space" v-for="post in posztok" :key="post.id">
          <div class="card">
            <div class="card-glow"></div>
            <div class="card-img-holder">
              <img 
                :src="getImageUrl(post.fo_kep)" 
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
                <div class="like-container">
                  <button class="like-btn">
                    <div class="heart-icon">
                        <font-awesome-icon icon="fa-solid fa-heart"/> 
                    </div>
                    <span class="like-count">2,050</span>
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
      
        <!-- No posts message -->
        <div v-if="!loading && posztok.length === 0" class="no-posts-container">
          <div class="empty-state">
            <div class="empty-icon">📝</div>
            <h3 class="empty-title">Még nincsenek blog bejegyzések</h3>
            <p class="empty-subtitle">Legyél te az első, aki megoszt valamit!</p>
          </div>
        </div>
      </section>
    </div>
  </main>
</template>

<script setup>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/services/api.js'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCalendar, faHeart, faArrowRight } from '@fortawesome/free-solid-svg-icons'

library.add(faCalendar, faHeart, faArrowRight)

// Import your fallback image at the top
import fallbackImage from '@/assets/Public/b-pl1.jpg'

const router = useRouter()
const posztok = ref([])
const loading = ref(true)
const error = ref(null)


const navigateToBlog = (postId) => {
  router.push(`/blog/${postId}`)
}

const fetchBlogPosts = async () => {
  try {
    loading.value = true
    error.value = null
    
    // Fetch blog posts
    const response = await api.get('/api/blog')
    posztok.value = response.data
    
  } catch (err) {
    console.error('Error fetching blog posts:', err)
    error.value = 'Hiba történt a blog bejegyzések betöltése közben.'
    posztok.value = getDummyPosts()
  } finally {
    loading.value = false
  }
}

const getImageUrl = (imagePath) => {
  // If no image or invalid path, use default
  if (!imagePath || typeof imagePath !== 'string') {
    return fallbackImage // Use the imported image
  }
  
  // If it's already a full URL, return as is
  if (imagePath.startsWith('http')) {
    return imagePath
  }
  
  // Otherwise, assume it's a relative path from storage
  return `http://localhost:8000/storage/${imagePath}`
}

const handleImageError = (event) => {
  // Set fallback image - use the imported image directly
  event.target.src = fallbackImage
}

const formatDate = (dateString) => {
  if (!dateString) return 'Ismeretlen dátum'
  return dateString
}

const getDummyPosts = () => {
  return [
    {
      id: 1,
      title: "HTML Syntax",
      excerpt: "The syntax of a language is how it works. How to actually write it. Learn HTML syntax…",
      created_at: "6 Oct 2017",
      tags: ["HTML"],
      main_image: null
    },
    {
      id: 2,
      title: "Basic types of HTML tags",
      excerpt: "Learn about some of the most common HTML tags…",
      created_at: "9 Oct 2017",
      tags: ["HTML", "CSS", "JavaScript", "Vue"],
      main_image: null
    }
  ]
}

onMounted(() => {
  fetchBlogPosts()
})

const isVisible = ref(false); // Tracks the button's visibility

// Function to check scroll position and toggle visibility
const handleScroll = () => {
	isVisible.value = window.scrollY > 200; // Show when scrolled > 200px
};

// Smoothly scroll to the top of the page
const scrollToTop = () => {
	window.scrollTo({ top: 0, behavior: 'smooth' });
};

// Add and remove scroll event listeners
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

.cards-wrapper {
  /*display: grid;
  justify-content: center;
  align-items: center;
  grid-template-columns: 1fr 1fr 1fr;
  grid-gap: 64px;
  padding: 64px;
  margin: 0 auto;
  width: max-content;
  text-align: left;*/
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(480px, 1fr));
  gap: 64px;
  padding: 48px 0;
}

.card-grid-space {
  position: relative;
}

.card {
  /*width: 520px;
  height: auto;
  background: var(--b-kartya);
  color: var(--b-text-light);
  border-radius: 8px;
  padding: 24px;
  overflow: hidden;
  position: relative;
  font-family: 'Rubik', sans-serif;
  box-sizing: border-box;
  box-shadow: 0 0 80px -16px rgba(0,0,0,0.1);
  transition: all, var(--b-transition-time);*/
  background: var(--b-kartya);
  border-radius: 20px;
  padding: 20px;
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
  /*border-radius: 6px 40px 6px 40px;
  margin-bottom: 16px;
  width: 100%;*/
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
  padding: 28px;
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

.like-container {
  flex: 1;
}

.like-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: none;
  border: none;
  color: #494d55;
  cursor: pointer;
  padding: 8px;
  border-radius: 10px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background-color: whitesmoke;
}

.like-btn:hover {
  background: #fce6e6;
  color: #ef4444;
}

.heart-icon {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.like-btn:hover .heart-icon {
  fill: #ef4444;
}

.like-count {
  font-weight: 500;
  font-size: 14px;
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

/* Loading State */
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

/* Error State */
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


/* Card hover effects 
.card:before, .card:after {
  content: '';
  transform: scale(0);
  transform-origin: top left;
  border-radius: 50%;
  position: absolute;
  left: -50%;
  top: -50%;
  z-index: -1;
  transition: all, var(--b-transition-time);
  transition-timing-function: ease-in-out;
}

.card:before {
  width: 250%;
  height: 250%;
}

.card:after {
  background: #ffffff80;
  width: 200%;
  height: 200%;
}

.card:hover:before, .card:hover:after {
  transform: scale(1);
}*/

@media (max-width: 1200px) {
  .cards-wrapper {
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 32px;
  }
}

@media (max-width: 768px) {
  .blog-header {
    padding: 48px 24px 32px;
  }
  
  .title {
    font-size: 40px;
  }
  
  .content-wrapper {
    padding: 0 24px;
  }
  
  .cards-wrapper {
    grid-template-columns: 1fr;
    gap: 24px;
    padding: 32px 0;
  }
  
  .card {
    max-width: 100%;
  }
}

@media (max-width: 480px) {
  .blog-header {
    padding: 32px 16px 24px;
  }
  
  .title {
    font-size: 32px;
  }
  
  .content-wrapper {
    padding: 0 16px;
  }
  
  .card-content {
    padding: 20px;
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