<template>
  <main>
    <a v-show="isVisible" href="#" class="back-to-top-control" @click.prevent="scrollToTop">
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" stroke-width="1" stroke="currentColor" fill="none" stroke-linecap="round" stroke-linejoin="round">
			<path stroke="none" d="M0 0h24v24H0z" fill="none" />
			<path d="M17 3.34a10 10 0 1 1 -14.995 8.984l-.005 -.324l.005 -.324a10 10 0 0 1 14.995 -8.336zm-4.98 3.66l-.163 .01l-.086 .016l-.142 .045l-.113 .054l-.07 .043l-.095 .071l-.058 .054l-4 4l-.083 .094a1 1 0 0 0 1.497 1.32l2.293 -2.293v5.586l.007 .117a1 1 0 0 0 1.993 -.117v-5.585l2.293 2.292l.094 .083a1 1 0 0 0 1.32 -1.497l-4 -4l-.082 -.073l-.089 -.064l-.113 -.062l-.081 -.034l-.113 -.034l-.112 -.02l-.098 -.006z" stroke-width="0" fill="currentColor" />
		</svg>
	</a>
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

<script setup>
import {
  ref, onMounted, onBeforeUnmount, watch, computed
} from 'vue'
import { useRoute } from 'vue-router'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faCalendar, faUser, faPaperPlane, faClock, faExpand, faReply } from '@fortawesome/free-solid-svg-icons'
import api from '@/services/api.js'
import CommentItem from '@/components/CommentItem.vue'
import fallbackImage from '@/assets/Public/b-pl1.jpg'

library.add(faCalendar, faUser, faPaperPlane, faClock, faExpand, faReply)

const route = useRoute()

// Reactive state
const post = ref({})
const loading = ref(true)
const error = ref(null)
const comments = ref([])
const newComment = ref('')
const loadingComments = ref(false)
const replyTo = ref(null)

// Computed
const postId = computed(() => route.params.id)

// Methods
const fetchPost = async () => {
  try {
    loading.value = true
    error.value = null
    
    await api.get('/sanctum/csrf-cookie')
    
    const response = await api.get(`/api/blog/${postId.value}`)
    post.value = response.data
  } catch (err) {
    console.error('Error fetching blog post:', err)
    
    if (err.response?.status === 404) {
      error.value = 'A blog bejegyzés nem található.'
    } else {
      error.value = 'Hiba történt a bejegyzés betöltése közben.'
    }
  } finally {
    loading.value = false
  }
}

const calculateReadTime = (content) => {
  if (!content) return '?'
  const words = content.split(/\s+/).length
  const minutes = Math.ceil(words / 200)
  return minutes || '1'
}

const fetchComments = async () => {
  try {
    loadingComments.value = true
    const response = await api.get(`/api/blog/${postId.value}/comments`)
    comments.value = response.data
  } catch (err) {
    console.error('Error fetching comments:', err)
  } finally {
    loadingComments.value = false
  }
}

const addComment = async () => {
  if (!newComment.value.trim()) return
  
  try {
    loadingComments.value = true
    const response = await api.post(`/api/blog/${postId.value}/comments`, {
      komment: newComment.value,
      elozo_komment_id: replyTo.value
    })
    
    if (replyTo.value) {
      addReplyToParent(replyTo.value, response.data.comment)
    } else {
      comments.value.unshift(response.data.comment)
    }
    
    newComment.value = ''
    replyTo.value = null
  } catch (err) {
    console.error('Error adding comment:', err)
    alert('Hiba történt a hozzászólás küldése közben.')
  } finally {
    loadingComments.value = false
  }
}

const addReplyToParent = (parentId, reply) => {
  const findAndAdd = (commentList) => {
    for (let comment of commentList) {
      if (comment.id === parentId) {
        if (!comment.gyermekKommentek) {
          comment.gyermekKommentek = []
        }
        comment.gyermekKommentek.push(reply)
        return true
      }
      if (comment.gyermekKommentek && comment.gyermekKommentek.length > 0) {
        if (findAndAdd(comment.gyermekKommentek)) return true
      }
    }
    return false
  }
  
  findAndAdd(comments.value)
}

const handleReply = (commentId) => {
  replyTo.value = commentId
  const textarea = document.querySelector('.comment-textarea')
  if (textarea) {
    textarea.focus()
    textarea.scrollIntoView({ behavior: 'smooth', block: 'center' })
  }
}

const handleDelete = async (commentId) => {
  if (!confirm('Biztosan törölni szeretnéd ezt a hozzászólást?')) return
  
  try {
    await api.delete(`/api/comments/${commentId}`)
    removeComment(commentId)
  } catch (err) {
    console.error('Error deleting comment:', err)
    alert('Hiba történt a hozzászólás törlése közben.')
  }
}

const removeComment = (commentId) => {
  const removeFromArray = (commentList) => {
    return commentList.filter(comment => {
      if (comment.id === commentId) return false
      if (comment.gyermekKommentek && comment.gyermekKommentek.length > 0) {
        comment.gyermekKommentek = removeFromArray(comment.gyermekKommentek)
      }
      return true
    })
  }
  
  comments.value = removeFromArray(comments.value)
}

const viewImage = (imageUrl) => {
  window.open(getImageUrl(imageUrl), '_blank')
}

const getImageUrl = (imagePath) => {
  if (!imagePath || typeof imagePath !== 'string') {
    return fallbackImage
  }
  
  if (imagePath.startsWith('http')) {
    return imagePath
  }
  
  return `http://localhost:8000/storage/${imagePath}`
}

const handleImageError = (event) => {
  event.target.src = fallbackImage
}

const formatDate = (dateString) => {
  if (!dateString) return 'Ismeretlen dátum'
  return dateString
}

const formatContent = (content) => {
  return content
}

// Lifecycle
onMounted(() => {
  fetchPost()
  fetchComments()
})

// Watchers
watch(
  () => route.params.id,
  () => {
    if (route.params.id) {
      fetchPost()
      fetchComments()
    }
  }
)

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
  padding: 32px;
}

.loading-content {
  text-align: center;
  background: var(--b-hatter);
  padding: 48px 64px;
  border-radius: 20px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  border: 1px solid white;
}

.loading-text {
  font-size: 20px;
  color: var(--b-text-dark);
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
  padding: 48px;
  text-align: center;
  max-width: 500px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  border: 1px solid white;
}

.error-icon {
  font-size: 64px;
  margin-bottom: 24px;
  opacity: 0.8;
}

.error-title {
  font-family: 'Poppins', sans-serif;
  font-size: 28px;
  color: var(--b-text-dark);
  margin-bottom: 16px;
  font-weight: 600;
}

.error-message {
  color: var(--b-text-light);
  margin-bottom: 32px;
  line-height: 1.6;
}

.error-back-btn {
  margin: 0 auto;
}

.blog-content {
  max-width: 1500px;
  margin: 0 auto;
  padding: 32px;
}

.navigation-container {
  margin-bottom: 40px;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  background: var(--b-hatter);
  color: var(--b-text-dark);
  border: 1px solid white;
  padding: 14px 24px;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

.back-btn:hover {
  background: var(--b-gomb-hover);
  color: var(--b-text-light);
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

.blog-article {
  background: rgb(252, 244, 242);
  border-radius: 24px;
  padding: 48px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  border: 1px solid white;
}

.article-header {
  margin-bottom: 48px;
  text-align: center;
}

.title-container {
  margin-bottom: 32px;
}

.blog-title {
  font-family: 'Poppins', sans-serif;
  font-size: 48px;
  font-weight: 700;
  color: var(--b-text-dark);
  margin-bottom: 16px;
  line-height: 1.2;
  display: inline-block;
  background-image: linear-gradient(90deg, #a08283, #4d0303);
  background-repeat: no-repeat;
  background-position: 0 100%;
  background-size: 100% 4px;
  padding-bottom: 6px;
}

.blog-meta {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 32px;
  margin-top: 32px;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
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
  font-size: 15px;
  color: var(--b-text-dark);
  font-weight: 500;
}

.featured-image-container {
  margin: 48px 0;
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
  margin: 48px 0;
  text-align: left;
}

.content-wrapper {
  margin: 0 auto;
}

.content-html {
  font-family: 'Inter', sans-serif;
  font-size: 18px;
  line-height: 1.8;
  color: var(--b-text-dark);
}

.content-html h2 {
  font-family: 'Poppins', sans-serif;
  font-size: 32px;
  font-weight: 600;
  margin: 40px 0 24px;
  color: var(--b-text-dark);
  position: relative;
  padding-left: 16px;
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
  font-size: 24px;
  font-weight: 600;
  margin: 32px 0 16px;
  color: var(--b-text-dark);
}

.content-html p {
  margin-bottom: 24px;
}

.content-html img {
  max-width: 100%;
  height: auto;
  border-radius: 12px;
  margin: 32px 0;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.content-html code {
  background: var(--b-hatter);
  padding: 0.32px 8px;
  border-radius: 6px;
  font-family: 'SF Mono', Monaco, 'Cascadia Mono', 'Segoe UI Mono', monospace;
  font-size: 14px;
  color: var(--b-tag);
}

.content-html pre {
  background: #1e293b;
  color: #e2e8f0;
  padding: 24px;
  border-radius: 12px;
  overflow-x: auto;
  margin: 32px 0;
  border: 1px solid #334155;
}

.content-html blockquote {
  border-left: 4px solid var(--b-tag);
  padding-left: 32px;
  margin: 32px 0;
  font-style: italic;
  color: var(--b-text-light);
  background: var(--b-hatter);
  padding: 24px 32px;
  border-radius: 12px;
}

.content-html ul, .content-html ol {
  margin: 24px 0;
  padding-left: 32px;
}

.content-html li {
  margin-bottom: 8px;
}

.no-content {
  text-align: center;
  padding: 48px;
  color: var(--b-text-light);
  font-style: italic;
  background: var(--b-hatter);
  border-radius: 12px;
  border: 1px dashed white;
}

.tags-section {
  border-top: 2px groove rgb(255, 198, 198);
  border-bottom: 2px groove rgb(255, 198, 198);
  padding-bottom: 30px;
}

.section-title {
  font-family: 'Poppins', sans-serif;
  font-size: 24px;
  font-weight: 600;
  color: var(--b-text-dark);
}

.tags {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.tag {
  background: var(--b-tag-hover);
  color: var(--b-text-light);
  padding: 10px 20px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid white;
}

.tag:hover {
  background: var(--b-tag);
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.tag-hash {
  opacity: 0.7;
  font-weight: 600;
}

.image-gallery {
  margin: 20px 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.section-subtitle {
  color: var(--b-text-light);
  font-size: 16px;
  font-weight: 500;
  background: rgb(161, 73, 51);
  padding: 6px 16px;
  border-radius: 20px;
}

.gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 24px;
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
  margin-top: 64px;
  border-top: 2px groove rgb(255, 198, 198);
}

.add-comment {
  background: var(--b-hatter);
  border-radius: 20px;
  padding: 32px;
  margin-bottom: 48px;
  border: 1px solid white;
}

.form-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.form-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: rgb(253, 239, 239);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--b-tag);
  font-size: 24px;
}

.form-title {
  font-family: 'Poppins', sans-serif;
  font-size: 20px;
  font-weight: 600;
  color: var(--b-text-dark);
}

.comment-count {
  background-color: rgb(161, 73, 51);
  color: var(--b-text-light);
  padding: 8px 20px;
  border-radius: 20px;
}

.comment-textarea {
  width: 95%;
  padding: 20px;
  border: 2px solid white;
  border-radius: 12px;
  font-family: 'Inter', sans-serif;
  font-size: 16px;
  resize: vertical;
  min-height: 120px;
  margin-bottom: 24px;
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
}

.form-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
}

.reply-indicator {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--b-text-light);
  font-size: 14px;
  font-weight: 500;
  background: rgb(136, 85, 52);
  padding: 8px 16px;
  border-radius: 20px;
}

.cancel-reply {
  background: none;
  border: none;
  color: var(--b-text-light);
  background-color: #5f0000;
  font-size: 12px;
  cursor: pointer;
  padding: 0.25rem 8px;
  border-radius: 4px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.cancel-reply:hover {
  color: var(--b-text-dark);
  background: rgba(199, 133, 123, 0.836);
}

.comment-submit-btn {
  background: var(--b-gomb);
  color: white;
  border: none;
  padding: 14px 32px;
  border-radius: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 120px;
  justify-content: center;
  box-shadow: 0 4px 6px -1px rgba(237, 58, 58, 0.2);
}

.comment-submit-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(237, 58, 58, 0.3);
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
  gap: 16px;
  padding: 48px;
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
  padding: 48px;
  background: var(--b-hatter);
  border-radius: 20px;
  border: 1px dashed white;
}

.no-comments .empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
  opacity: 0.6;
}

.no-comments h4 {
  font-family: 'Poppins', sans-serif;
  font-size: 20px;
  color: var(--b-text-dark);
  margin-bottom: 8px;
}

.no-comments p {
  color: var(--b-text-light);
}

.comments-container {
  display: flex;
  flex-direction: column;
  gap: 24px;
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
    padding: 40px;
  }
  
  .blog-title {
    font-size: 40px;
  }
  
  .gallery-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  }
}

@media (max-width: 768px) {
  .blog-content {
    padding: 16px;
  }
  
  .blog-article {
    padding: 32px;
  }
  
  .blog-title {
    font-size: 32px;
  }
  
  .blog-meta {
    flex-direction: column;
    gap: 16px;
    align-items: center;
  }
  
  .gallery-grid {
    grid-template-columns: 1fr;
  }
  
  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
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
    padding: 24px;
  }
  
  .blog-title {
    font-size: 28px;
  }
  
  .content-html {
    font-size: 16px;
  }
  
  .content-html h2 {
    font-size: 24px;
  }
  
  .content-html h3 {
    font-size: 20px;
  }
  
  .add-comment {
    padding: 24px;
  }
}
</style>