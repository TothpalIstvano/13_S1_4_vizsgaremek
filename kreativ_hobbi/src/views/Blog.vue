<template>
<main>
  <h1 class="title">Blog</h1>
    <section class="cards-wrapper">
      <!-- Loading state -->
      <div v-if="loading" class="loading">
        <p>Blog bejegyzések betöltése...</p>
      </div>
      
      <!-- Error state -->
      <div v-if="error" class="error">
        <p>{{ error }}</p>
      </div>
      
      <!-- Blog posts -->
      <div class="card-grid-space" v-for="post in posts" :key="post.id">
        <div class="card">
          <div class="card-img-holder">
            <img 
              :src="getImageUrl(post.main_image)" 
              :alt="post.title"
              @error="handleImageError"
            />
          </div>
          <h3 class="blog-title">{{ post.title }}</h3>
          <span class="blog-time"> 
            <font-awesome-icon icon="fa-solid fa-calendar" class="naptar"/> 
            {{ formatDate(post.created_at) }}
          </span>
          <p class="description">
            {{ post.excerpt || post.content || 'Nincs leírás...' }}
          </p>
          <div class="tags">
            <div class="tag" v-for="tag in post.tags" :key="tag">{{ tag }}</div>
          </div>
          <div class="options">
            <span>Teljes bejegyzés olvasása</span>
            <button class="btn" @click="navigateToBlog(post.id)">Blog →</button>
          </div>
        </div>
      </div>
      
      <!-- No posts message -->
      <div v-if="!loading && posts.length === 0" class="no-posts">
        <p>Még nincsenek blog bejegyzések.</p>
      </div>
    </section>
</main>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import api from '@/services/api.js'
// Import your fallback image at the top
import fallbackImage from '@/assets/Public/b-pl1.jpg'

export default {
  name: 'Blog',
  data() {
    return {
      posts: [],
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
        this.posts = response.data;
        
      } catch (error) {
        console.error('Error fetching blog posts:', error);
        this.error = 'Hiba történt a blog bejegyzések betöltése közben.';
        this.posts = this.getDummyPosts();
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

.cards-wrapper {
  display: grid;
  justify-content: center;
  align-items: center;
  grid-template-columns: 1fr 1fr 1fr;
  grid-gap: 64px;
  padding: 64px;
  margin: 0 auto;
  width: max-content;
  text-align: left;
}

.card-grid-space {
  position: relative;
}

.card {
  width: 520px;
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
  transition: all, var(--b-transition-time);
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 10px 30px rgba(0,0,0,0.15);
  color: var(--b-text-dark);
}

.card-img-holder {
  width: 100%;
  height: 240px;
  position: relative;
  overflow: hidden;
  border-radius: 6px 60px 6px 60px;
  margin-bottom: 16px;
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

.blog-title {
  padding: 16px 0 8px 0;
  font-size: 24px;
  margin: 0;
  transition: all, var(--b-transition-time);
}

.card:hover .blog-title {
  color: var(--b-text-dark);
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

.blog-time {
  font-size: 12px;
  display: block;
  opacity: 0.9;
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
  border-radius: 5px;
  padding: 5px 13px;
  line-height: 24px;
  transition: all, var(--b-transition-time);
  font-weight: 500;
  box-shadow: inset 0px 0px 10px 1px rgba(80, 33, 0, 0.5);
}

.card:hover .tag {
  background: var(--b-tag-hover);
  color: var(--b-text-dark);
  transform: translateY(-2px);
}

.options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-size: 16px;
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--b-text-light);
}

.options span {
  font-weight: 600;
  transition: all, var(--b-transition-time);
}

.card:hover .options {
  color: var(--b-text-dark);
  border-top: 1px solid var(--b-text-dark);
}

.btn {
  font-size: 16px;
  padding: 8px 24px;
  border-radius: 8px;
  font-weight: 400;
  letter-spacing: 0.7px;
  background: var(--b-gomb);
  color: var(--b-text-light);
  cursor: pointer;
  border: none;
  transition: all, var(--b-transition-time);
  box-shadow: inset 0px 0px 10px 1px rgba(255, 254, 254, 0.5);
}

.btn:hover {
  background: var(--b-gomb-hover);
  color: var(--b-text-dark);
  transform: translateY(-2px);
}

/* Loading and error states */
.loading, .error, .no-posts {
  grid-column: 1 / -1;
  text-align: center;
  padding: 40px;
  font-size: 18px;
  color: var(--b-text-light);
}

.error {
  color: #ff6b6b;
}

/* Animation for loading */
.loading p {
  animation: pulse 1.5s infinite;
}

@keyframes pulse {
  0% { opacity: 0.5; }
  50% { opacity: 1; }
  100% { opacity: 0.5; }
}

/* Card hover effects */
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
}

@media screen and (max-width: 1800px) {
  .card {
    width: 400px;
  }
}

@media screen and (max-width: 1200px) {
  .cards-wrapper {
    grid-template-columns: 1fr 1fr;
  }
}

@media screen and (max-width: 500px) {
  .cards-wrapper {
    padding: 64px 32px;
  }
  .cards-wrapper {
    grid-template-columns: 1fr;
  }
}
</style>