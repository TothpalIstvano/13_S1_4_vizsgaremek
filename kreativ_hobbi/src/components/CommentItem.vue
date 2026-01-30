<script setup>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faUserCircle, faReply, faTrash } from '@fortawesome/free-solid-svg-icons'
import { defineProps, defineEmits } from 'vue'

library.add(faUserCircle, faReply, faTrash)

const props = defineProps({
  comment: {
    type: Object,
    required: true
  },
  isReply: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['reply', 'delete'])

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('hu-HU', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}
</script>

<template>
  <div class="comment-item" :class="{ 'is-reply': isReply }">
    <div class="comment-header">
      <div class="comment-author">
        <div class="avatar-container">
          <div class="avatar">
            <font-awesome-icon icon="fa-solid fa-user-circle" class="user-icon" />
          </div>
          <div class="author-info">
            <span class="author-name">{{ comment.felhasznalo?.felhasz_nev || 'Ismeretlen' }}</span>
            <span class="comment-date">
              {{ formatDate(comment.letrehozas_datuma) }}
            </span>
          </div>
        </div>
      </div>
      
      <button 
        @click="$emit('delete', comment.id)" 
        class="delete-btn"
        title="Törlés"
      >
        <div class="delete-icon">
          <font-awesome-icon icon="fa-solid fa-trash" />
        </div>
      </button>
    </div>
    
    <div class="comment-content">
      <div class="content-text">
        {{ comment.komment }}
      </div>
    </div>
    
    <div class="comment-actions">
      <button @click="$emit('reply', comment.id)" class="reply-btn">
        <div class="reply-icon">
          <font-awesome-icon icon="fa-solid fa-reply" />
        </div>
        <span>Válasz</span>
      </button>
    </div>
    
    <div v-if="comment.gyermekKommentek && comment.gyermekKommentek.length > 0" class="replies">
      <CommentItem 
        v-for="reply in comment.gyermekKommentek" 
        :key="reply.id" 
        :comment="reply"
        :isReply="true"
        @reply="$emit('reply', $event)"
        @delete="$emit('delete', $event)"
      />
    </div>
  </div>
</template>

<style scoped>

.comment-item {
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 20px;
  position: relative;
  overflow: hidden;
}

.comment-item.is-reply {
  margin-left: 40px;
  margin-top: 20px;
  background: var(--b-komment-hatter);
  border-left: 4px solid var(--b-komment-fo);
  position: relative;
}

.comment-item.is-reply::before {
  content: '';
  position: absolute;
  left: -40px;
  top: 50%;
  width: 40px;
  height: 2px;
  background: var(--b-komment-hatter);
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.comment-author {
  flex: 1;
}

.avatar-container {
  display: flex;
  align-items: center;
  gap: 14px;
}

.avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: var(--b-text-light);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(124, 58, 237, 0.1);
}

.user-icon {
  font-size: 34px;
  color: var(--b-text-dark);
}

.author-info {
  display: flex;
  flex-direction: column;
}

.author-name {
  font-weight: 600;
  color: var(--b-text-dark);
  font-size: 16px;
  margin-bottom: 4px;
}

.comment-date {
  font-size: 12px;
  color: var(--b-text-light);
  display: flex;
  align-items: center;
  gap: 6px;
}

.comment-date::before {
  content: '•';
  opacity: 0.5;
}

.delete-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  color: rgb(104, 3, 3);
  background-color: #ffd8d8;
}

.delete-btn:hover {
  background: #fef2f2;
  color: #be0606;
}

.delete-icon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.comment-content {
  margin-bottom: 20px;
}

.content-text {
  line-height: 1.7;
  color: var(--b-text-dark);
  font-size: 15px;
  padding: 12px;
  background: #f9fafb;
  border-radius: 12px;
  border-left: 3px solid var(--b-komment-fo);
  position: relative;
}

/*.content-text::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 3px;
  background: linear-gradient(to bottom, var(--b-komment-fo), #a78bfa);
  border-radius: 3px 0 0 3px;
}*/

.comment-actions {
  display: flex;
  gap: 16px;
}

.reply-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--b-gomb);
  color: var(--b-text-light);
  border: 1px solid #ede9fe;
  padding: 10px 20px;
  border-radius: 12px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.reply-btn:hover {
  background: var(--b-gomb-hover);
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgba(237, 58, 58, 0.1);
}

.reply-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
}

.replies {
  margin-top: 24px;
  position: relative;
}

.comment-item-enter-active {
  animation: slideIn 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 640px) {
  .comment-item {
    padding: 20px;
  }
  
  .comment-item.is-reply {
    margin-left: 24px;
  }
  
  .avatar {
    width: 40px;
    height: 40px;
  }
  
  .user-icon {
    font-size: 24px;
  }
  
  .content-text {
    padding: 10px;
    font-size: 14px;
  }
}
</style>