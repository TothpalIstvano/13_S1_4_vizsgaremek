<template>
  <main class="single-blog">
    <div v-if="loading" class="loading">
      <p>Bejegyzés betöltése...</p>
    </div>
    <div v-else-if="error" class="error">
      <p>{{ error }}</p>
      <button @click="$router.go(-1)" class="back-btn">← Vissza a bloghoz</button>
    </div>
    <div v-else class="blog-content">
      <button @click="$router.go(-1)" class="back-btn">← Vissza a bloghoz</button>
      
      <article>
        <h1 class="blog-title">{{ post.title }}</h1>
        
        <div class="blog-meta">
          <span class="blog-time">
            <font-awesome-icon icon="fa-solid fa-calendar" />
            {{ formatDate(post.created_at) }}
          </span>
          <span class="blog-author">
            <font-awesome-icon icon="fa-solid fa-user" />
            Szerző: {{ post.author || 'Ismeretlen' }}
          </span>
        </div>
        
        <div class="featured-image" v-if="post.main_image">
          <img :src="getImageUrl(post.main_image)" :alt="post.title" @error="handleImageError" />
        </div>
        
        <div class="tags">
          <span class="tag" v-for="tag in post.tags" :key="tag">{{ tag }}</span>
        </div>
        
        <div class="blog-body">
          <div v-if="post.content" v-html="formatContent(post.content)"></div>
          <div v-else>
            <p>{{ post.excerpt }}</p>
          </div>
        </div>
        
        <!-- Additional images gallery -->
        <div class="image-gallery" v-if="post.images && post.images.length > 0">
          <h3>További képek</h3>
          <div class="gallery-grid">
            <div class="gallery-item" v-for="(image, index) in post.images" :key="index">
              <img :src="getImageUrl(image.url)" :alt="image.alt || post.title" @error="handleImageError" />
            </div>
          </div>
        </div>
      </article>
    </div>
  </main>
</template>

<script>
import api from '@/services/api.js'

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
        if (error.response && error.response.status === 404) {
          this.error = 'A blog bejegyzés nem található.';
        } else {
          this.error = 'Hiba történt a bejegyzés betöltése közben.';
        }
      } finally {
        this.loading = false;
      }
    },
    getImageUrl(imagePath) {
      if (!imagePath || typeof imagePath !== 'string') {
        return require('@/assets/Public/b-pl1.jpg');
      }
      
      if (imagePath.startsWith('http')) {
        return imagePath;
      }
      
      return `http://localhost:8000/storage/${imagePath}`;
    },
    handleImageError(event) {
      event.target.src = require('@/assets/Public/b-pl1.jpg');
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
  color: var(--b-text-light);
  font-size: 16px;
}

.blog-meta span {
  display: flex;
  align-items: center;
  gap: 8px;
}

.featured-image {
  margin-bottom: 40px;
  border-radius: 8px 60px 8px 60px;
  overflow: hidden;
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

.loading, .error {
  text-align: center;
  padding: 100px 20px;
  font-size: 20px;
}

.error {
  color: #ff6b6b;
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