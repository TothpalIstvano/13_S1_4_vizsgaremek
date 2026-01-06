<template>
  <main class="single-blog">
    <div class="blog-background"></div>
    
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
    
    <div v-else-if="error" class="error-container">
      <div class="error-card">
        <div class="error-icon">📄</div>
        <h3 class="error-title">A bejegyzés nem található</h3>
        <p class="error-message">{{ error }}</p>
        <button @click="$router.go(-1)" class="back-btn error-back-btn">
          <div class="btn-icon">←</div>
          Vissza a bloghoz
        </button>
      </div>
    </div>
    
    <div v-else class="blog-content">
      <div class="navigation-container">
        <button @click="$router.go(-1)" class="back-btn">
          <div class="btn-icon">←</div>
          <span>Vissza a bloghoz</span>
        </button>
      </div>
      
      <article class="blog-article">
        <div class="article-header">
          <div class="title-container">
            <h1 class="blog-title">{{ post.cim }}</h1>
            <div class="title-underline"></div>
          </div>
          
          <div class="blog-meta">
            <div class="meta-item">
              <div class="meta-icon">
                <font-awesome-icon icon="fa-solid fa-calendar" />
              </div>
              <span class="meta-text">{{ formatDate(post.letrehozas_datuma) }}</span>
            </div>
            
            <div class="meta-item" v-if="post.szerzo">
              <div class="meta-icon">
                <font-awesome-icon icon="fa-solid fa-user" />
              </div>
              <span class="meta-text">Szerző: {{ post.szerzo }}</span>
            </div>
            
            <div class="meta-item">
              <div class="meta-icon">
                <font-awesome-icon icon="fa-solid fa-clock" />
              </div>
              <span class="meta-text">Olvasási idő: {{ calculateReadTime(post.tartalom) }} perc</span>
            </div>
          </div>
        </div>
        
        <div class="featured-image-container" v-if="post.fo_kep">
          <div class="image-wrapper">
            <img 
              :src="getImageUrl(post.fo_kep)" 
              :alt="post.cim" 
              @error="handleImageError" 
              loading="lazy"
              class="featured-image"
            />
            <div class="image-overlay"></div>
          </div>
        </div>
        
        <div class="blog-body">
          <div class="content-wrapper">
            <div v-if="post.tartalom" v-html="formatContent(post.tartalom)" class="content-html"></div>
            <div v-else>
              <p class="no-content">{{ post.tartalom || 'Nincs tartalom megadva.' }}</p>
            </div>
          </div>
        </div>
        
        <div class="tags-section">
          <h3 class="section-title">Címkék</h3>
          <div class="tags">
            <span class="tag" v-for="tag in post.cimkek" :key="tag">
              <span class="tag-hash">#</span>{{ tag }}
            </span>
          </div>
        </div>
        
        <!-- Additional images gallery -->
        <div class="image-gallery" v-if="post.kepek && post.kepek.length > 0">
          <div class="section-header">
            <h3 class="section-title">További képek</h3>
            <div class="section-subtitle">{{ post.kepek.length }} kép</div>
          </div>
          <div class="gallery-grid">
            <div class="gallery-item" v-for="(image, index) in post.kepek" :key="index">
              <div class="gallery-item-inner">
                <img 
                  :src="getImageUrl(image.url)" 
                  :alt="image.alt || post.cim" 
                  @error="handleImageError"
                  loading="lazy"
                />
                <div class="gallery-overlay">
                  <button class="gallery-view-btn" @click="viewImage(image.url)">
                    <font-awesome-icon icon="fa-solid fa-expand" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="kommentek-section">
          <div class="section-header">
            <h2 class="section-title">Hozzászólások</h2>
            <div class="comment-count">{{ comments.length }} hozzászólás</div>
          </div>
          
          <!-- Add Comment Form -->
          <div class="add-comment">
            <div class="form-header">
              <div class="form-avatar">
                <font-awesome-icon icon="fa-solid fa-user-circle" />
              </div>
              <h4 class="form-title">Hozzászólás írása</h4>
            </div>
            
            <textarea 
              v-model="newComment" 
              placeholder="Írd ide a hozzászólásodat..."
              rows="4"
              class="comment-textarea"
              :class="{ 'has-reply': replyTo }"
            ></textarea>
            
            <div class="form-footer">
              <div class="reply-indicator" v-if="replyTo">
                <font-awesome-icon icon="fa-solid fa-reply" />
                <span>Válaszolsz egy hozzászólásra</span>
                <button @click="replyTo = null" class="cancel-reply">Mégse</button>
              </div>
              
              <button 
                @click="addComment" 
                :disabled="!newComment.trim() || loadingComments"
                class="comment-submit-btn"
                :class="{ 'is-loading': loadingComments }"
              >
                <span v-if="!loadingComments">
                  <font-awesome-icon icon="fa-solid fa-paper-plane" />
                  Küldés
                </span>
                <span v-else class="loading-spinner"></span>
              </button>
            </div>
          </div>
          
          <!-- Comments List -->
          <div class="comments-list">
            <div v-if="loadingComments" class="loading-comments">
              <div class="loading-spinner"></div>
              <p>Kommentek betöltése...</p>
            </div>
            
            <div v-else-if="comments.length === 0" class="no-comments">
              <div class="empty-icon">💬</div>
              <h4>Még nincsenek hozzászólások</h4>
              <p>Legyél te az első, aki hozzászól!</p>
            </div>
            
            <div v-else class="comments-container">
              <CommentItem 
                v-for="comment in comments" 
                :key="comment.id" 
                :comment="comment"
                @reply="handleReply"
                @delete="handleDelete"
                class="comment-item-animate"
              />
            </div>
          </div>
        </div>
      </article>
    </div>
  </main>
</template>

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCalendar, faUser, faPaperPlane, faClock, faExpand, faReply } from '@fortawesome/free-solid-svg-icons'

library.add(faCalendar, faUser, faPaperPlane, faClock, faExpand, faReply)

import api from '@/services/api.js'
import CommentItem from '@/components/CommentItem.vue'
import fallbackImage from '@/assets/Public/b-pl1.jpg'

export default {
  name: 'SingleBlog',
  data() {
    return {
      post: {},
      loading: true,
      error: null,
      comments: [],
      newComment: '',
      loadingComments: false,
      replyTo: null,
    }
  },
  methods: {
    async fetchPost() {
      try {
        this.loading = true;
        this.error = null;
        
        await api.get('/sanctum/csrf-cookie');
        
        const postId = this.$route.params.id;
        const response = await api.get(`/api/blog/${postId}`);
        this.post = response.data;
      } catch (error) {
        console.error('Error fetching blog post:', error);
        
        if (error.response?.status === 404) {
          this.error = 'A blog bejegyzés nem található.';
        } else {
          this.error = 'Hiba történt a bejegyzés betöltése közben.';
        }
      } finally {
        this.loading = false;
      }
    },
    
    calculateReadTime(content) {
      if (!content) return '?';
      const words = content.split(/\s+/).length;
      const minutes = Math.ceil(words / 200);
      return minutes || '1';
    },
    
    async fetchComments() {
      try {
        this.loadingComments = true;
        const postId = this.$route.params.id;
        const response = await api.get(`/api/blog/${postId}/comments`);
        this.comments = response.data;
      } catch (error) {
        console.error('Error fetching comments:', error);
      } finally {
        this.loadingComments = false;
      }
    },
    
    async addComment() {
      if (!this.newComment.trim()) return;
      
      try {
        this.loadingComments = true;
        const postId = this.$route.params.id;
        const response = await api.post(`/api/blog/${postId}/comments`, {
          komment: this.newComment,
          elozo_komment_id: this.replyTo
        });
        
        if (this.replyTo) {
          this.addReplyToParent(this.replyTo, response.data.comment);
        } else {
          this.comments.unshift(response.data.comment);
        }
        
        this.newComment = '';
        this.replyTo = null;
      } catch (error) {
        console.error('Error adding comment:', error);
        alert('Hiba történt a hozzászólás küldése közben.');
      } finally {
        this.loadingComments = false;
      }
    },
    
    addReplyToParent(parentId, reply) {
      const findAndAdd = (comments) => {
        for (let comment of comments) {
          if (comment.id === parentId) {
            if (!comment.gyermekKommentek) {
              comment.gyermekKommentek = [];
            }
            comment.gyermekKommentek.push(reply);
            return true;
          }
          if (comment.gyermekKommentek && comment.gyermekKommentek.length > 0) {
            if (findAndAdd(comment.gyermekKommentek)) return true;
          }
        }
        return false;
      };
      
      findAndAdd(this.comments);
    },
    
    handleReply(commentId) {
      this.replyTo = commentId;
      const textarea = document.querySelector('.comment-textarea');
      if (textarea) {
        textarea.focus();
        textarea.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    },
    
    async handleDelete(commentId) {
      if (!confirm('Biztosan törölni szeretnéd ezt a hozzászólást?')) return;
      
      try {
        await api.delete(`/api/comments/${commentId}`);
        this.removeComment(commentId);
      } catch (error) {
        console.error('Error deleting comment:', error);
        alert('Hiba történt a hozzászólás törlése közben.');
      }
    },
    
    removeComment(commentId) {
      const removeFromArray = (comments) => {
        return comments.filter(comment => {
          if (comment.id === commentId) return false;
          if (comment.gyermekKommentek && comment.gyermekKommentek.length > 0) {
            comment.gyermekKommentek = removeFromArray(comment.gyermekKommentek);
          }
          return true;
        });
      };
      
      this.comments = removeFromArray(this.comments);
    },
    
    viewImage(imageUrl) {
      window.open(this.getImageUrl(imageUrl), '_blank');
    },
    
    getImageUrl(imagePath) {
      if (!imagePath || typeof imagePath !== 'string') {
        return fallbackImage;
      }
      
      if (imagePath.startsWith('http')) {
        return imagePath;
      }
      
      return `http://localhost:8000/storage/${imagePath}`;
    },
    
    handleImageError(event) {
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
    this.fetchComments();
  },
  
  watch: {
    '$route.params.id': {
      handler() {
        this.fetchPost();
        this.fetchComments();
      },
      immediate: false
    }
  },
  
  components: {
    FontAwesomeIcon,
    CommentItem
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Poppins:wght@400;500;600;700&display=swap');

.loading-container,
.error-container,
.blog-content {
  position: relative;
  z-index: 1;
}

.loading-container,
.error-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 2rem;
}

.loading-content {
  text-align: center;
  background: white;
  padding: 3rem 4rem;
  border-radius: 20px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  border: 1px solid white;
}

.loading-text {
  font-size: 1.25rem;
  color: var(--b-text-dark);
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
  background: linear-gradient(135deg, #8a3706 0%, #fab78b 100%);
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

.error-card {
  background: white;
  border-radius: 20px;
  padding: 3rem;
  text-align: center;
  max-width: 500px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  border: 1px solid white;
}

.error-icon {
  font-size: 4rem;
  margin-bottom: 1.5rem;
  opacity: 0.8;
}

.error-title {
  font-family: 'Poppins', sans-serif;
  font-size: 1.75rem;
  color: var(--b-text-dark);
  margin-bottom: 1rem;
  font-weight: 600;
}

.error-message {
  color: var(--b-text-light);
  margin-bottom: 2rem;
  line-height: 1.6;
}

.error-back-btn {
  margin: 0 auto;
}

.blog-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.navigation-container {
  margin-bottom: 2.5rem;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  background: white;
  color: var(--b-text-dark);
  border: 1px solid white;
  padding: 0.875rem 1.5rem;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

.back-btn:hover {
  background: var(--b-hatter);
  transform: translateX(-4px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.btn-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
}

.blog-article {
  background: white;
  border-radius: 24px;
  padding: 3rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  border: 1px solid white;
}

.article-header {
  margin-bottom: 3rem;
  text-align: center;
}

.title-container {
  margin-bottom: 2rem;
}

.blog-title {
  font-family: 'Poppins', sans-serif;
  font-size: 3rem;
  font-weight: 700;
  color: var(--b-text-dark);
  margin-bottom: 1rem;
  line-height: 1.2;
}

.title-underline {
  width: 80px;
  height: 4px;
  background: linear-gradient(135deg, #8a3706 0%, #fab78b 100%);
  border-radius: 2px;
  margin: 0 auto;
}

.blog-meta {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 2rem;
  margin-top: 2rem;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: var(--b-hatter);
  border-radius: 12px;
  border: 1px solid white;
}

.meta-icon {
  color: var(--b-tag);
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.meta-text {
  font-size: 0.95rem;
  color: var(--b-text-dark);
  font-weight: 500;
}

.featured-image-container {
  margin: 3rem 0;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: var(--shadow-xl);
}

.image-wrapper {
  position: relative;
}

.featured-image {
  width: 100%;
  max-height: 600px;
  object-fit: cover;
  display: block;
  transition: transform 0.8s ease;
}

.featured-image:hover {
  transform: scale(1.02);
}

.image-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 100px;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.3), transparent);
  pointer-events: none;
}

.blog-body {
  margin: 3rem 0;
}

.content-wrapper {
  max-width: 800px;
  margin: 0 auto;
}

.content-html {
  font-family: 'Inter', sans-serif;
  font-size: 1.125rem;
  line-height: 1.8;
  color: var(--b-text-dark);
}

.content-html h2 {
  font-family: 'Poppins', sans-serif;
  font-size: 2rem;
  font-weight: 600;
  margin: 2.5rem 0 1.5rem;
  color: var(--b-text-dark);
  position: relative;
  padding-left: 1rem;
}

.content-html h2::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 4px;
  background: linear-gradient(135deg, #8a3706 0%, #fab78b 100%);
  border-radius: 2px;
}

.content-html h3 {
  font-family: 'Poppins', sans-serif;
  font-size: 1.5rem;
  font-weight: 600;
  margin: 2rem 0 1rem;
  color: var(--b-text-dark);
}

.content-html p {
  margin-bottom: 1.5rem;
}

.content-html img {
  max-width: 100%;
  height: auto;
  border-radius: 12px;
  margin: 2rem 0;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.content-html code {
  background: var(--b-hatter);
  padding: 0.2rem 0.5rem;
  border-radius: 6px;
  font-family: 'SF Mono', Monaco, 'Cascadia Mono', 'Segoe UI Mono', monospace;
  font-size: 0.9em;
  color: var(--b-tag);
}

.content-html pre {
  background: #1e293b;
  color: #e2e8f0;
  padding: 1.5rem;
  border-radius: 12px;
  overflow-x: auto;
  margin: 2rem 0;
  border: 1px solid #334155;
}

.content-html blockquote {
  border-left: 4px solid var(--b-tag);
  padding-left: 2rem;
  margin: 2rem 0;
  font-style: italic;
  color: var(--b-text-light);
  background: var(--b-hatter);
  padding: 1.5rem 2rem;
  border-radius: 12px;
}

.content-html ul, .content-html ol {
  margin: 1.5rem 0;
  padding-left: 2rem;
}

.content-html li {
  margin-bottom: 0.5rem;
}

.no-content {
  text-align: center;
  padding: 3rem;
  color: var(--b-text-light);
  font-style: italic;
  background: var(--b-hatter);
  border-radius: 12px;
  border: 1px dashed white;
}

.tags-section {
  margin: 3rem 0;
  padding: 2rem 0;
  border-top: 1px solid white;
  border-bottom: 1px solid white;
}

.section-title {
  font-family: 'Poppins', sans-serif;
  font-size: 1.5rem;
  font-weight: 600;
  color: var(--b-text-dark);
  margin-bottom: 1.5rem;
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.tag {
  background: linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%);
  color: var(--b-text-dark);
  padding: 0.625rem 1.25rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 0.375rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid white;
}

.tag:hover {
  background: linear-gradient(135deg, #8a3706 0%, #fab78b 100%);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.tag-hash {
  opacity: 0.7;
  font-weight: 600;
}

.image-gallery {
  margin: 3rem 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.section-subtitle {
  color: var(--b-text-light);
  font-size: 0.95rem;
  font-weight: 500;
  background: var(--b-hatter);
  padding: 0.375rem 1rem;
  border-radius: 20px;
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.gallery-item {
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  position: relative;
}

.gallery-item:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

.gallery-item-inner {
  position: relative;
  height: 200px;
}

.gallery-item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.gallery-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.gallery-item:hover .gallery-overlay {
  opacity: 1;
}

.gallery-view-btn {
  background: white;
  border: none;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: var(--b-tag);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform: scale(0.8);
}

.gallery-item:hover .gallery-view-btn {
  transform: scale(1);
}

.gallery-view-btn:hover {
  background: var(--b-tag);
  color: white;
}

.kommentek-section {
  margin-top: 4rem;
}

.add-comment {
  background: var(--b-hatter);
  border-radius: 20px;
  padding: 2rem;
  margin-bottom: 3rem;
  border: 1px solid white;
}

.form-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.form-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--b-gomb) 0%, #ddd6fe 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--b-tag);
  font-size: 1.5rem;
}

.form-title {
  font-family: 'Poppins', sans-serif;
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--b-text-dark);
}

.comment-textarea {
  width: 100%;
  padding: 1.25rem;
  border: 2px solid white;
  border-radius: 12px;
  font-family: 'Inter', sans-serif;
  font-size: 1rem;
  resize: vertical;
  min-height: 120px;
  margin-bottom: 1.5rem;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: white;
}

.comment-textarea:focus {
  outline: none;
  border-color: var(--b-tag);
  box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1);
}

.comment-textarea.has-reply {
  border-color: var(--b-tag);
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
}

.form-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
}

.reply-indicator {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  color: var(--b-tag);
  font-size: 0.875rem;
  font-weight: 500;
  background: var(--b-gomb);
  padding: 0.5rem 1rem;
  border-radius: 20px;
}

.cancel-reply {
  background: none;
  border: none;
  color: var(--b-text-light);
  font-size: 0.75rem;
  cursor: pointer;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.cancel-reply:hover {
  color: var(--b-tag);
  background: rgba(124, 58, 237, 0.1);
}

.comment-submit-btn {
  background: linear-gradient(135deg, #8a3706 0%, #fab78b 100%);
  color: white;
  border: none;
  padding: 0.875rem 2rem;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 0.75rem;
  min-width: 120px;
  justify-content: center;
  box-shadow: 0 4px 6px -1px rgba(124, 58, 237, 0.2);
}

.comment-submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(124, 58, 237, 0.3);
}

.comment-submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.comment-submit-btn.is-loading {
  opacity: 0.8;
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.loading-comments {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 3rem;
  color: var(--b-text-light);
  text-align: center;
}

.loading-comments .loading-spinner {
  width: 40px;
  height: 40px;
  border-width: 3px;
}

.no-comments {
  text-align: center;
  padding: 3rem;
  background: var(--b-hatter);
  border-radius: 20px;
  border: 1px dashed white;
}

.no-comments .empty-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.6;
}

.no-comments h4 {
  font-family: 'Poppins', sans-serif;
  font-size: 1.25rem;
  color: var(--b-text-dark);
  margin-bottom: 0.5rem;
}

.no-comments p {
  color: var(--b-text-light);
}

.comments-container {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.comment-item-animate {
  animation: slideIn 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Responsive Design */
@media (max-width: 1024px) {
  .blog-article {
    padding: 2.5rem;
  }
  
  .blog-title {
    font-size: 2.5rem;
  }
  
  .gallery-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  }
}

@media (max-width: 768px) {
  .blog-content {
    padding: 1rem;
  }
  
  .blog-article {
    padding: 2rem;
  }
  
  .blog-title {
    font-size: 2rem;
  }
  
  .blog-meta {
    flex-direction: column;
    gap: 1rem;
    align-items: center;
  }
  
  .gallery-grid {
    grid-template-columns: 1fr;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .form-footer {
    flex-direction: column;
    align-items: stretch;
  }
  
  .comment-submit-btn {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .blog-article {
    padding: 1.5rem;
  }
  
  .blog-title {
    font-size: 1.75rem;
  }
  
  .content-html {
    font-size: 1rem;
  }
  
  .content-html h2 {
    font-size: 1.5rem;
  }
  
  .content-html h3 {
    font-size: 1.25rem;
  }
  
  .add-comment {
    padding: 1.5rem;
  }
}
</style>