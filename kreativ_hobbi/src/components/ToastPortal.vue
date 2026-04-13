<script setup>
import { ref } from 'vue'

const toasts = ref([])
const errorModalLines = ref([])
const errorModalVisible = ref(false)
let toastId = 0

function showToast(message, type = 'success', subtitle = '') {
  const id = ++toastId
  toasts.value.push({ id, message, type, subtitle })
  setTimeout(() => removeToast(id), 4000)
}

function removeToast(id) {
  toasts.value = toasts.value.filter(t => t.id !== id)
}

function showErrorModal(lines) {
  errorModalLines.value = Array.isArray(lines) ? lines : [lines]
  errorModalVisible.value = true
}

defineExpose({ showToast, showErrorModal })
</script>

<template>
  <Teleport to="body">
    <div class="toast-container">
      <div
        v-for="t in toasts"
        :key="t.id"
        class="toast"
        :class="t.type"
      >
        <div class="toast-body">
          <strong>{{ t.message }}</strong>
          <span v-if="t.subtitle">{{ t.subtitle }}</span>
        </div>
        <button class="toast-close" @click="removeToast(t.id)">✕</button>
      </div>
    </div>

    <div
      v-if="errorModalVisible"
      class="modal-backdrop"
      @click.self="errorModalVisible = false"
    >
      <div class="modal">
        <div class="modal-header-row">
          <h3>Hibás adatok</h3>
          <button class="close-btn" @click="errorModalVisible = false">✕</button>
        </div>
        <ul class="error-list">
          <li v-for="(e, i) in errorModalLines" :key="i">{{ e }}</li>
        </ul>
        <div class="modal-actions">
          <button class="btn confirm" @click="errorModalVisible = false">Rendben</button>
        </div>
      </div>
    </div>
  </Teleport>
</template>

<style scoped>
.toast-container {
  position: fixed;
  top: 105px;       
  right: 24px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  z-index: 9999;
}

.toast {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 14px 16px;
  border-radius: 12px;
  border: 0.5px solid;
  min-width: 280px;
  max-width: 380px;
  animation: toastIn .25s ease;
  box-shadow: 0 4px 16px rgba(0,0,0,0.1);
}

@keyframes toastIn {
  from { opacity: 0; transform: translateY(-8px); } 
  to   { opacity: 1; transform: none; }
}

.toast.success { background: #EAF3DE; border-color: #97C459; color: #3B6D11; }
.toast.error   { background: #FCEBEB; border-color: #F09595; color: #A32D2D; }
.toast.info    { background: #E6F1FB; border-color: #85B7EB; color: #185FA5; }

.toast-body strong { display: block; font-size: 14px; font-weight: 600; }
.toast-body span   { font-size: 13px; opacity: .8; margin-top: 2px; display: block; }

.toast-close {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  opacity: .5;
  color: inherit;
  flex-shrink: 0;
  margin-left: auto;
}
.toast-close:hover { opacity: 1; }

.modal-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 16px;
}

.modal {
  background: #fff;
  border-radius: 14px;
  box-shadow: 0 20px 40px rgba(0,0,0,0.2);
  width: 100%;
  max-width: 420px;
  animation: modalIn .2s ease;
}

@keyframes modalIn {
  from { opacity: 0; transform: scale(0.95); }
  to   { opacity: 1; transform: scale(1); }
}

.modal-header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #e9ecef;
}

.modal-header-row h3 { margin: 0; font-size: 18px; }

.close-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #6c757d;
  padding: 4px 8px;
  border-radius: 6px;
}
.close-btn:hover { background: #e9ecef; }

.error-list {
  padding: 16px 24px;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 6px;
  color: #374151;
  font-size: 14px;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  padding: 12px 20px;
  border-top: 1px solid #e9ecef;
}

.btn {
  padding: 8px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 600;
}
.btn.confirm { background: #dc2626; color: #fff; }
</style>