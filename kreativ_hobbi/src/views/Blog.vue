<template>
<main>
  <h1 class="title">Blog</h1>
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
            <div class="image-overlay"></div>
            <img 
              :src="getImageUrl(post.fo_kep)" 
              :alt="post.cim"
              @error="handleImageError"
              loading="lazy"
            />
            <div class="card-corner"></div>
          </div>
          
          <div class="card-content">
            <div class="card-header">
              <h3 class="blog-title">{{ post.cim }}</h3>
              <div class="title-underline"></div>
            </div>
            
            <div class="meta-info">
              <span class="blog-time"> 
                <div class="icon-wrapper">
                  <font-awesome-icon icon="fa-solid fa-calendar"/> 
                </div>
                {{ formatDate(post.letrehozas_datuma) }}
              </span>
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
                    <div class="icon-wrapper">
                      <font-awesome-icon icon="fa-solid fa-heart"/> 
                    </div>
                  </div>
                  <span class="like-count">2,050</span>
                </button>
              </div>
              
              <button class="view-btn" @click="navigateToBlog(post.id)">
                <span>Megtekintés</span>
                <div class="arrow-icon">
                  <div class="icon-wrapper">
                      <font-awesome-icon icon="fa-solid fa-arrow-right"/> 
                    </div>
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

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCalendar, faHeart, faArrowRight, faH } from '@fortawesome/free-solid-svg-icons'

library.add(faCalendar, faHeart, faArrowRight)

import api from '@/services/api.js'

// Import your fallback image at the top
import fallbackImage from '@/assets/Public/b-pl1.jpg'

export default {
  name: 'Blog',
  data() {
    return {
      posztok: [],
      loading: true,
      error: null
    }
  },
  methods: {
    async navigateToBlog(postId) {
      this.$router.push(`/blog/${postId}`);
    },
    async fetchBlogPosts() {
      try {
        this.loading = true;
        this.error = null;
        
        // Fetch blog posts
        const response = await api.get('/api/blog');
        this.posztok = response.data;
        
      } catch (error) {
        console.error('Error fetching blog posts:', error);
        this.error = 'Hiba történt a blog bejegyzések betöltése közben.';
        this.posztok = this.getDummyPosts();
      } finally {
        this.loading = false;
      }
    },
    getImageUrl(imagePath) {
      // If no image or invalid path, use default
      if (!imagePath || typeof imagePath !== 'string') {
        return fallbackImage; // Use the imported image
      }
      
      // If it's already a full URL, return as is
      if (imagePath.startsWith('http')) {
        return imagePath;
      }
      
      // Otherwise, assume it's a relative path from storage
      return `http://localhost:8000/storage/${imagePath}`;
    },
    handleImageError(event) {
      // Set fallback image - use the imported image directly
      event.target.src = fallbackImage;
    },
    formatDate(dateString) {
      if (!dateString) return 'Ismeretlen dátum';
      return dateString;
    },
    getDummyPosts() {
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
      ];
    }
  },
  mounted() {
    this.fetchBlogPosts();
  },
  components: {
    FontAwesomeIcon
  }
}
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
  display: inline-block;
  font-weight: 700;
  font-size: 45px;
  color: var(--mk-text-dark);
  background-image: linear-gradient(90deg, #a08283, #4d0303);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
}

.content-wrapper {
  max-width: 1800px;
  margin: 0 auto;
  padding: 0 2rem;
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
  padding: 3rem 0;
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
  overflow: hidden;
  position: relative;
  transition: var(--transition);
  box-shadow: var(--shadow-md);
  height: 100%;
  display: flex;
  flex-direction: column;
  border: 1px solid #e5e7eb;
}

.card-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(135deg, #7c3aed 0%, #a78bfa 100%);
  opacity: 0;
  transition: var(--transition);
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

.card-corner {
  position: absolute;
  top: 0;
  right: 0;
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #630101 0%, #aa0404 100%);
  clip-path: polygon(0 0, 100% 0, 100% 100%);
  z-index: 2;
}

.card-content {
  padding: 1.75rem;
  flex-grow: 1;
  display: flex;
  flex-direction: column;
}

.card-header {
  margin-bottom: 1rem;
}

.blog-title {
  padding: 16px 0 8px 0;
  font-size: 24px;
  margin: 0;
  transition: all, var(--b-transition-time);
}

.card:hover .blog-title {
  color: var(--b-text-dark);
}

.title-underline {
  width: 40px;
  height: 3px;
  background: linear-gradient(135deg, #7c3aed 0%, #a78bfa 100%);
  border-radius: 2px;
  margin-top: 0.5rem;
}

.meta-info {
  margin-bottom: 1rem;
}

.blog-time {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #6b7280;
  background: #f9fafb;
  padding: 0.375rem 0.75rem;
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
  gap: 0.25rem;
  transition: var(--transition);
  border: 1px solid #e5e7eb;
}

.tag:hover {
  background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%);
  color: white;
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}

.tag-hash {
  opacity: 0.7;
  font-size: 0.875em;
}

.card-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
  padding-top: 1.25rem;
  border-top: 1px solid #e5e7eb;
}

.like-container {
  flex: 1;
}

.like-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: none;
  border: none;
  color: #6b7280;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 10px;
  transition: var(--transition);
}

.like-btn:hover {
  background: #fef2f2;
  color: #ef4444;
}

.heart-icon {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.heart-icon svg {
  transition: var(--transition);
}

.like-btn:hover .heart-icon svg {
  fill: #ef4444;
  transform: scale(1.1);
}

.like-count {
  font-weight: 500;
  font-size: 0.875rem;
}

.view-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: linear-gradient(135deg, #7c3aed 0%, #8b5cf6 100%);
  color: white;
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: var(--transition);
  box-shadow: 0 4px 6px -1px rgba(124, 58, 237, 0.2);
}

.view-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(124, 58, 237, 0.3);
  background: linear-gradient(135deg, #6d28d9 0%, #7c3aed 100%);
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
  font-size: 1.125rem;
  color: #6b7280;
  margin-bottom: 2rem;
  font-weight: 500;
}

.spinner-wrapper {
  display: flex;
  justify-content: center;
  gap: 1rem;
}

.pulse-dot {
  width: 12px;
  height: 12px;
  background: linear-gradient(135deg, #7c3aed 0%, #8b5cf6 100%);
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
  padding: 3rem;
  text-align: center;
  box-shadow: var(--shadow-lg);
  border: 1px solid #e5e7eb;
}

.error-icon {
  font-size: 3rem;
  margin-bottom: 1.5rem;
}

.error-message {
  font-size: 1.125rem;
  color: var(--text-dark);
  margin-bottom: 2rem;
  line-height: 1.6;
}

.retry-btn {
  background: linear-gradient(135deg, #7c3aed 0%, #a78bfa 100%);
  color: white;
  border: none;
  padding: 0.875rem 2rem;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: var(--transition);
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
  padding: 4rem 2rem;
  background: white;
  border-radius: 20px;
  box-shadow: var(--shadow-lg);
  border: 1px solid #e5e7eb;
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 1.5rem;
  opacity: 0.8;
}

.empty-title {
  font-family: 'Poppins', sans-serif;
  font-size: 1.75rem;
  color: var(--text-dark);
  margin-bottom: 0.75rem;
  font-weight: 600;
}

.empty-subtitle {
  color: #6b7280;
  font-size: 1.125rem;
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
    gap: 2rem;
  }
}

@media (max-width: 768px) {
  .blog-header {
    padding: 3rem 1.5rem 2rem;
  }
  
  .title {
    font-size: 2.5rem;
  }
  
  .content-wrapper {
    padding: 0 1.5rem;
  }
  
  .cards-wrapper {
    grid-template-columns: 1fr;
    gap: 1.5rem;
    padding: 2rem 0;
  }
  
  .card {
    max-width: 100%;
  }
}

@media (max-width: 480px) {
  .blog-header {
    padding: 2rem 1rem 1.5rem;
  }
  
  .title {
    font-size: 2rem;
  }
  
  .content-wrapper {
    padding: 0 1rem;
  }
  
  .card-content {
    padding: 1.25rem;
  }
  
  .card-footer {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
  
  .view-btn {
    justify-content: center;
  }
}

</style>