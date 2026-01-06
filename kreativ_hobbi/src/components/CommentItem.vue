<template>
  <div class="comment-item" :class="{ 'is-reply': isReply }">
    <div class="comment-glow"></div>
    
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
        v-if="canDelete" 
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
    
    <!-- Replies -->
    <div v-if="comment.gyermekKommentek && comment.gyermekKommentek.length > 0" class="replies">
      <div class="reply-connector"></div>
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

<script>
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faUserCircle, faReply, faTrash } from '@fortawesome/free-solid-svg-icons'

library.add(faUserCircle, faReply, faTrash)

export default {
  name: 'CommentItem',
  props: {
    comment: {
      type: Object,
      required: true
    },
    isReply: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    canDelete() {
      return true;
    }
  },
  methods: {
    formatDate(dateString) {
      if (!dateString) return '';
      const date = new Date(dateString);
      return date.toLocaleDateString('hu-HU', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    }
  },
  components: {
    FontAwesomeIcon
  }
}
</script>

<style scoped>

.comment-item {
  background: #ffffff;
  border-radius: 16px;
  padding: 1.5rem;
  margin-bottom: 1.25rem;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  position: relative;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid #e5e7eb;
  overflow: hidden;
}

.comment-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
}

.comment-glow {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, var(--b-komment-fo) 0%, #e6d7cb 50%, var(--b-komment-fo) 100%);
  opacity: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.comment-item:hover .comment-glow {
  opacity: 1;
}

.comment-item.is-reply {
  margin-left: 2.5rem;
  margin-top: 1.25rem;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-left: 4px solid var(--b-komment-fo);
  position: relative;
}

.comment-item.is-reply::before {
  content: '';
  position: absolute;
  left: -2.5rem;
  top: 50%;
  width: 2.5rem;
  height: 2px;
  background: #e5e7eb;
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.comment-author {
  flex: 1;
}

.avatar-container {
  display: flex;
  align-items: center;
  gap: 0.875rem;
}

.avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, #ede9fe 0%, #ddd6fe 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid white;
  box-shadow: 0 2px 4px rgba(124, 58, 237, 0.1);
}

.user-icon {
  font-size: 1.75rem;
  color: var(--b-komment-fo);
}

.author-info {
  display: flex;
  flex-direction: column;
}

.author-name {
  font-weight: 600;
  color: var(--b-text-dark);
  font-size: 1rem;
  margin-bottom: 0.25rem;
}

.comment-date {
  font-size: 0.75rem;
  color: var(--b-text-light);
  display: flex;
  align-items: center;
  gap: 0.375rem;
}

.comment-date::before {
  content: '•';
  opacity: 0.5;
}

.delete-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 8px;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  color: var(--b-text-light);
}

.delete-btn:hover {
  background: #fef2f2;
  color: #be0606;
  transform: scale(1.05);
}

.delete-icon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.comment-content {
  margin-bottom: 1.25rem;
}

.content-text {
  line-height: 1.7;
  color: var(--b-text-dark);
  font-size: 0.95rem;
  padding: 0.75rem;
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
  gap: 1rem;
}

.reply-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  color: var(--b-komment-fo);
  border: 1px solid #ede9fe;
  padding: 0.625rem 1.25rem;
  border-radius: 12px;
  cursor: pointer;
  font-size: 0.875rem;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.reply-btn:hover {
  background: linear-gradient(135deg, #ede9fe 0%, #ddd6fe 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgba(124, 58, 237, 0.1);
}

.reply-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
}

.replies {
  margin-top: 1.5rem;
  position: relative;
}

.reply-connector {
  position: absolute;
  left: -1.5rem;
  top: 0;
  bottom: 0;
  width: 2px;
  background: linear-gradient(to bottom, transparent, #ede9fe, transparent);
}

.replies::before {
  content: '';
  position: absolute;
  left: -1.5rem;
  top: 0;
  width: 2px;
  height: 100%;
  background: linear-gradient(to bottom, transparent, #ede9fe, transparent);
}

/* Animation for new comments */
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

/* Responsive */
@media (max-width: 640px) {
  .comment-item {
    padding: 1.25rem;
  }
  
  .comment-item.is-reply {
    margin-left: 1.5rem;
  }
  
  .avatar {
    width: 40px;
    height: 40px;
  }
  
  .user-icon {
    font-size: 1.5rem;
  }
  
  .content-text {
    padding: 0.625rem;
    font-size: 0.9rem;
  }
}
</style>