<template>
  <div class="comment-item" :class="{ 'is-reply': isReply }">
    <div class="comment-header">
      <div class="comment-author">
        <font-awesome-icon icon="fa-solid fa-user-circle" class="user-icon" />
        <span class="author-name">{{ comment.felhasznalo?.felhasz_nev || 'Ismeretlen' }}</span>
        <span class="comment-date">
          {{ formatDate(comment.letrehozas_datuma) }}
        </span>
      </div>
      <button 
        v-if="canDelete" 
        @click="$emit('delete', comment.id)" 
        class="delete-btn"
        title="Törlés"
      >
        <font-awesome-icon icon="fa-solid fa-trash" />
      </button>
    </div>
    
    <div class="comment-content">
      {{ comment.komment }}
    </div>
    
    <div class="comment-actions">
      <button @click="$emit('reply', comment.id)" class="reply-btn">
        <font-awesome-icon icon="fa-solid fa-reply" /> Válasz
      </button>
    </div>
    
    <!-- Replies -->
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
      // Add your authorization logic here
      // For now, allow all deletions (you should implement proper auth)
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
  background: var(--b-card-bg, #ffffff);
  border-radius: 8px;
  padding: 16px;
  margin-bottom: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.comment-item.is-reply {
  margin-left: 32px;
  border-left: 3px solid var(--b-tag, #007bff);
  background: var(--b-card-bg-light, #f8f9fa);
}

.comment-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.comment-author {
  display: flex;
  align-items: center;
  gap: 8px;
}

.user-icon {
  font-size: 24px;
  color: var(--b-text-light, #6c757d);
}

.author-name {
  font-weight: 600;
  color: var(--b-text-dark, #343a40);
}

.comment-date {
  font-size: 12px;
  color: var(--b-text-light, #6c757d);
}

.delete-btn {
  background: none;
  border: none;
  color: var(--b-error, #dc3545);
  cursor: pointer;
  padding: 4px;
  font-size: 14px;
}

.delete-btn:hover {
  color: var(--b-error-dark, #bd2130);
}

.comment-content {
  line-height: 1.5;
  color: var(--b-text-dark, #343a40);
  margin-bottom: 12px;
  white-space: pre-wrap;
}

.comment-actions {
  display: flex;
  gap: 16px;
}

.reply-btn {
  background: none;
  border: none;
  color: var(--b-tag, #007bff);
  cursor: pointer;
  font-size: 14px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.reply-btn:hover {
  color: var(--b-tag-hover, #0056b3);
  text-decoration: underline;
}

.replies {
  margin-top: 16px;
  border-top: 1px solid var(--b-border-light, #e9ecef);
  padding-top: 16px;
}
</style>