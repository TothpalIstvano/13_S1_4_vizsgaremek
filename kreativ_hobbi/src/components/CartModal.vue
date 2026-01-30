<template>
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="isOpen" class="modal-overlay" @click="close">
        <div class="modal-content" @click.stop>
          <button class="close-btn" @click="close">✕</button>
          
          <div class="modal-success">
            <div class="success-icon">✓</div>
            <h2>Sikeresen hozzáadva!</h2>
            
            <div class="cart-preview">
              <img v-if="item?.termek_fo_kep?.url_Link || item?.image" 
                   :src="item?.termek_fo_kep?.url_Link || item?.image" 
                   :alt="item?.nev || item?.name"
                   class="preview-image" />
              
              <div class="item-details">
                <p class="item-name">{{ item?.nev || item?.name }}</p>
                <p class="item-quantity">
                  <strong>{{ quantity }}x</strong> – 
                  <span class="price">{{ ((item?.ar || item?.price) * quantity).toLocaleString('hu-HU') }} Ft</span>
                </p>
              </div>
            </div>

            <div class="modal-actions">
              <button class="btn-continue" @click="close">
                Folytat a vásárlással
              </button>
              <router-link to="/kosar" class="btn-checkout">
                Kosár megtekintése
              </router-link>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const isOpen = ref(false)
const item = ref(null)
const quantity = ref(1)

function open(cartItem, qty = 1) {
  item.value = cartItem
  quantity.value = qty
  isOpen.value = true
  
  // Auto-close after 5 seconds
  setTimeout(() => {
    close()
  }, 5000)
}

function close() {
  isOpen.value = false
}

defineExpose({
  open,
  close
})
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  backdrop-filter: blur(2px);
}

.modal-content {
  background: white;
  border-radius: 16px;
  padding: 40px;
  max-width: 500px;
  width: 90%;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  position: relative;
  animation: slideUp 0.4s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(40px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.close-btn {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 36px;
  height: 36px;
  border: none;
  background: #f3f4f6;
  border-radius: 50%;
  cursor: pointer;
  font-size: 20px;
  color: #666;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: #e5e7eb;
  color: #333;
}

.modal-success {
  text-align: center;
}

.success-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: linear-gradient(135deg, #059669 0%, #047857 100%);
  color: white;
  font-size: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
  font-weight: bold;
  box-shadow: 0 8px 24px rgba(5, 150, 105, 0.3);
}

.modal-success h2 {
  margin: 0 0 32px 0;
  font-size: 28px;
  color: #1a2332;
}

.cart-preview {
  display: flex;
  gap: 16px;
  padding: 20px;
  background: #f9fafb;
  border-radius: 12px;
  margin-bottom: 32px;
  align-items: center;
}

.preview-image {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 10px;
  background: white;
}

.item-details {
  flex: 1;
  text-align: left;
}

.item-name {
  margin: 0 0 8px 0;
  font-weight: 700;
  color: #1a2332;
  font-size: 16px;
  line-height: 1.3;
}

.item-quantity {
  margin: 0;
  color: #6b7280;
  font-size: 14px;
}

.price {
  color: #059669;
  font-weight: 700;
  font-size: 16px;
}

.modal-actions {
  display: flex;
  gap: 12px;
  flex-direction: column;
}

.btn-continue,
.btn-checkout {
  padding: 14px 24px;
  border: none;
  border-radius: 10px;
  font-size: 16px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-continue {
  background: white;
  color: #3f51b5;
  border: 2px solid #3f51b5;
}

.btn-continue:hover {
  background: #f0f4ff;
}

.btn-checkout {
  background: linear-gradient(135deg, #3f51b5 0%, #2f3fa3 100%);
  color: white;
  box-shadow: 0 4px 16px rgba(63, 81, 181, 0.3);
}

.btn-checkout:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(63, 81, 181, 0.4);
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
