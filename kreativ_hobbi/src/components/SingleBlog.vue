<template>
  <main class="single-blog">
    <div v-if="loading" class="loading">
      <p>Blogbejegyzések betöltése...</p>
        <div class="three-body">
          <div class="three-body__dot"></div>
          <div class="three-body__dot"></div>
          <div class="three-body__dot"></div>
        </div>
    </div>
    <div v-else-if="error" class="error">
      <p>{{ error }}</p>
      <button @click="$router.go(-1)" class="back-btn">← Vissza a bloghoz</button>
    </div>
    <div v-else class="blog-content">
      <button @click="$router.go(-1)" class="back-btn">← Vissza a bloghoz</button>
      
      <article>
        <h1 class="blog-title">{{ post.cim }}</h1>
        
        <div class="blog-meta">
          <span class="blog-time">
            <font-awesome-icon icon="fa-solid fa-calendar" class="naptar"/> 
            {{ formatDate(post.letrehozas_datuma) }}
          </span>
          <span class="blog-author">
            <font-awesome-icon icon="fa-solid fa-user" />
            Szerző: {{ post.szerzo|| 'Ismeretlen' }}
          </span>
        </div>
        
        <div class="blog-body">
          <div v-if="post.tartalom" v-html="formatContent(post.tartalom)"></div>
          <div v-else>
            <p>{{ post.tartalom }}</p>
          </div>
        </div>

        <div class="featured-image" v-if="post.fo_kep">
          <img :src="getImageUrl(post.fo_kep)" :alt="post.cim" @error="handleImageError" />
        </div>
        
        <div class="tags">
          <span class="tag" v-for="tag in post.cimkek" :key="tag">{{ tag }}</span>
        </div>
        
        <!-- Additional images gallery -->
        <div class="image-gallery" v-if="post.kepek && post.kepek.length > 0">
          <h3>További képek</h3>
          <div class="gallery-grid">
            <div class="gallery-item" v-for="(image, index) in post.kepek" :key="index">
              <img :src="getImageUrl(image.url)" :alt="image.alt || post.cim" @error="handleImageError" />
            </div>
          </div>
        </div>

        <div class="kommnentek">
          <h1>Kommentek</h1>
        </div>
      </article>
    </div>
  </main>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCalendar, faUser } from '@fortawesome/free-solid-svg-icons'

library.add(faCalendar, faUser)

import api from '@/services/api.js'
// Import your fallback image at the top
import fallbackImage from '@/assets/Public/b-pl1.jpg'

export default {
  name: 'SingleBlog',
  data() {
    return {
      post: {},
      loading: true,
      error: null
    }
  },
  methods: {
    async fetchPost() {
      try {
        this.loading = true;
        this.error = null;
        
        // Get CSRF token
        await api.get('/sanctum/csrf-cookie');
        
        // Fetch the specific blog post
        const postId = this.$route.params.id;
        const response = await api.get(`/api/blog/${postId}`);
        this.post = response.data;
      } catch (error) {
        console.error('Error fetching blog post:', error);
        console.error('Error details:', error.response?.data);
        
        if (error.response && error.response.status === 404) {
          this.error = 'A blog bejegyzés nem található.';
        } else {
          this.error = 'Hiba történt a bejegyzés betöltése közben.';
          console.error('Full error:', error);
        }
      } finally {
        this.loading = false;
      }
    },
    getImageUrl(imagePath) {
      // If no image or invalid path, use default
      if (!imagePath || typeof imagePath !== 'string') {
        return fallbackImage; // Use the imported image
      }
      
      if (imagePath.startsWith('http')) {
        return imagePath;
      }
      
      return `http://localhost:8000/storage/${imagePath}`;
    },
    handleImageError(event) {
      // Set fallback image
      event.target.src = fallbackImage;
    },
    formatDate(dateString) {
      if (!dateString) return 'Ismeretlen dátum';
      return dateString;
    },
    formatContent(content) {
      return content;
    }
  },
  mounted() {
    this.fetchPost();
  },
  watch: {
    '$route.params.id': {
      handler() {
        this.fetchPost();
      },
      immediate: false
    }
  },
  components: {
    FontAwesomeIcon
  }
}
</script>

<style scoped>
.single-blog {
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 20px;
  min-height: 100vh;
}

.back-btn {
  background: var(--b-gomb);
  color: var(--b-text-light);
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  margin-bottom: 30px;
  font-size: 16px;
  font-weight: 500;
  transition: all var(--b-transition-time);
  box-shadow: inset 0px 0px 10px 1px rgba(255, 254, 254, 0.5);
}

.back-btn:hover {
  background: var(--b-gomb-hover);
  color: var(--b-text-dark);
  transform: translateY(-2px);
}

.blog-title {
  font-size: 48px;
  margin-bottom: 20px;
  color: var(--mk-text-dark);
  font-weight: 700;
  line-height: 1.2;
}

.blog-meta {
  display: flex;
  gap: 30px;
  margin-bottom: 40px;
  color: var(--b-text-dark);
  font-size: 16px;
}

.blog-meta span {
  display: flex;
  align-items: center;
  gap: 8px;
}

.featured-image {
  margin-bottom: 40px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.1);
}

.featured-image img {
  width: 100%;
  max-height: 600px;
  object-fit: cover;
  display: block;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 40px;
}

.tag {
  background: var(--b-tag);
  color: var(--b-text-light);
  padding: 8px 20px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  transition: all var(--b-transition-time);
}

.tag:hover {
  background: var(--b-tag-hover);
  color: var(--b-text-dark);
  transform: translateY(-2px);
}

.blog-body {
  line-height: 1.8;
  font-size: 18px;
  color: var(--b-text-dark);
  margin-bottom: 60px;
}

.blog-body h2 {
  margin-top: 40px;
  margin-bottom: 20px;
  font-size: 32px;
  color: var(--mk-text-dark);
}

.blog-body h3 {
  margin-top: 30px;
  margin-bottom: 15px;
  font-size: 24px;
  color: var(--mk-text-dark);
}

.blog-body p {
  margin-bottom: 25px;
}

.blog-body img {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  margin: 30px 0;
}

.blog-body code {
  background: #f4f4f4;
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
}

.blog-body pre {
  background: #f4f4f4;
  padding: 20px;
  border-radius: 8px;
  overflow-x: auto;
  margin: 30px 0;
}

.blog-body blockquote {
  border-left: 4px solid var(--b-tag);
  padding-left: 20px;
  margin: 30px 0;
  font-style: italic;
  color: #666;
}

.image-gallery {
  margin-top: 60px;
  padding-top: 40px;
  border-top: 1px solid var(--b-text-light);
}

.image-gallery h3 {
  font-size: 28px;
  margin-bottom: 30px;
  color: var(--mk-text-dark);
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
}

.gallery-item {
  border-radius: 8px;
  overflow: hidden;
  box-shadow: 0 5px 15px rgba(0,0,0,0.1);
  transition: transform var(--b-transition-time);
}

.gallery-item:hover {
  transform: translateY(-5px);
}

.gallery-item img {
  width: 100%;
  height: 200px;
  object-fit: cover;
  display: block;
}

.loading {
  text-align: center;
  align-items: center;
  margin: 0;
  padding-top: 60px;
}

.three-body {
 --uib-size: 35px;
 --uib-speed: 0.8s;
 --uib-color: #580303;
 position: relative;
 display: inline-block;
 height: var(--uib-size);
 width: var(--uib-size);
 animation: spin78236 calc(var(--uib-speed) * 2.5) infinite linear;
}

.three-body__dot {
 position: absolute;
 height: 100%;
 width: 30%;
}

.three-body__dot:after {
 content: '';
 position: absolute;
 height: 0%;
 width: 100%;
 padding-bottom: 100%;
 background-color: var(--uib-color);
 border-radius: 50%;
}

.three-body__dot:nth-child(1) {
 bottom: 5%;
 left: 0;
 transform: rotate(60deg);
 transform-origin: 50% 85%;
}

.three-body__dot:nth-child(1)::after {
 bottom: 0;
 left: 0;
 animation: wobble1 var(--uib-speed) infinite ease-in-out;
 animation-delay: calc(var(--uib-speed) * -0.3);
}

.three-body__dot:nth-child(2) {
 bottom: 5%;
 right: 0;
 transform: rotate(-60deg);
 transform-origin: 50% 85%;
}

.three-body__dot:nth-child(2)::after {
 bottom: 0;
 left: 0;
 animation: wobble1 var(--uib-speed) infinite
    calc(var(--uib-speed) * -0.15) ease-in-out;
}

.three-body__dot:nth-child(3) {
 bottom: -5%;
 left: 0;
 transform: translateX(116.666%);
}

.three-body__dot:nth-child(3)::after {
 top: 0;
 left: 0;
 animation: wobble2 var(--uib-speed) infinite ease-in-out;
}

@keyframes spin78236 {
 0% {
  transform: rotate(0deg);
 }

 100% {
  transform: rotate(360deg);
 }
}

@keyframes wobble1 {
 0%,
  100% {
  transform: translateY(0%) scale(1);
  opacity: 1;
 }

 50% {
  transform: translateY(-66%) scale(0.65);
  opacity: 0.8;
 }
}

@keyframes wobble2 {
 0%,
  100% {
  transform: translateY(0%) scale(1);
  opacity: 1;
 }

 50% {
  transform: translateY(66%) scale(0.65);
  opacity: 0.8;
 }
}

.error {
  color: #ff6b6b;
}

.kommnentek {
  margin-top: 60px;
  border-top: 1px solid var(--b-text-light);
}

@media screen and (max-width: 768px) {
  .blog-title {
    font-size: 36px;
  }
  
  .blog-meta {
    flex-direction: column;
    gap: 15px;
  }
  
  .blog-body {
    font-size: 16px;
  }
  
  .blog-body h2 {
    font-size: 28px;
  }
  
  .blog-body h3 {
    font-size: 22px;
  }
  
  .gallery-grid {
    grid-template-columns: 1fr;
  }
}

@media screen and (max-width: 500px) {
  .single-blog {
    padding: 20px 15px;
  }
  
  .blog-title {
    font-size: 28px;
  }
}
</style>