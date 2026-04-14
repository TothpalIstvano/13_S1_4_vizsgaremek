<template>
  <Teleport to="body">
    <div
      v-if="visible"
      class="report-backdrop"
      @click.self="close"
    >
      <div class="report-modal" role="dialog" aria-modal="true">

        <!-- Fejléc -->
        <div class="report-header">
          <div class="report-header-left">
            <div class="report-header-icon">
              <font-awesome-icon icon="fa-solid fa-triangle-exclamation" />
            </div>
            <div>
              <p class="report-modal-title">Tartalom bejelentése</p>
              <p class="report-modal-subtitle">{{ type === 'post' ? 'Bejegyzés' : 'Hozzászólás' }}</p>
            </div>
          </div>
          <button class="report-close-btn" @click="close" aria-label="Bezárás">✕</button>
        </div>

        <!-- Alcím -->
        <p class="report-section-label">Miért szeretnéd bejelenteni ezt a tartalmat?</p>

        <!-- Okok -->
        <div class="report-reasons">
          <label
            v-for="reason in reasons"
            :key="reason.value"
            class="report-reason"
            :class="{ selected: selectedReason === reason.value }"
          >
            <input
              type="radio"
              name="report-reason"
              :value="reason.value"
              v-model="selectedReason"
              class="report-radio"
            />
            <div class="reason-text">
              <p class="reason-title">{{ reason.label }}</p>
              <p class="reason-desc">{{ reason.description }}</p>
            </div>
          </label>
        </div>

        <!-- Leírás -->
        <div class="report-description-wrap">
          <label class="report-desc-label">Leírás (opcionális)</label>
          <textarea
            v-model="description"
            rows="3"
            placeholder="Részletezd a bejelentés okát..."
            class="report-textarea"
          ></textarea>
        </div>

        <!-- Gombok -->
        <div class="report-actions">
          <button class="report-btn-cancel" @click="close">Mégse</button>
          <button
            class="report-btn-submit"
            :disabled="!selectedReason || loading"
            @click="submit"
          >
            <span v-if="loading" class="report-spinner"></span>
            <span v-else>Bejelentés küldése</span>
          </button>
        </div>

        <!-- Sikerüzenet -->
        <div v-if="submitted" class="report-success">
          <span>✔</span> Bejelentésed megkaptuk, köszönjük!
        </div>

      </div>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, watch } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { library } from '@fortawesome/fontawesome-svg-core'
import { faTriangleExclamation } from '@fortawesome/free-solid-svg-icons'
import api from '@/services/api.js'

library.add(faTriangleExclamation)

const props = defineProps({
  visible: {
    type: Boolean,
    default: false
  },
  // 'post' | 'comment'
  type: {
    type: String,
    default: 'post'
  },
  // a bejelentett tartalom id-ja
  targetId: {
    type: [Number, String],
    default: null
  }
})

const emit = defineEmits(['close'])

const selectedReason = ref(null)
const description = ref('')
const loading = ref(false)
const submitted = ref(false)

const reasons = [
  {
    value: 'serto',
    label: 'Sértő tartalom',
    description: 'Gyűlöletkeltés, bántalmazó vagy méltóságot sértő'
  },
  {
    value: 'spam',
    label: 'Spam vagy félrevezető',
    description: 'Reklám, kattintásvadász vagy hamis információ'
  },
  {
    value: '18plus',
    label: '18+ tartalom',
    description: 'Szexuális vagy erőszakos anyag'
  },
  {
    value: 'szemelyes',
    label: 'Személyes adatok',
    description: 'Engedély nélküli személyes vagy érzékeny adat'
  },
  {
    value: 'jogsertes',
    label: 'Szerzői jogi jogsértés',
    description: 'Engedély nélkül megosztott szerzői jogi védelem alatt álló tartalom'
  },
  {
    value: 'egyeb',
    label: 'Egyéb',
    description: 'A fentiek egyikébe sem illő ok'
  }
]

const close = () => {
  if (loading.value) return
  selectedReason.value = null
  description.value = ''
  submitted.value = false
  emit('close')
}

// Ha bezárjuk kívülről, reseteljük
watch(() => props.visible, (val) => {
  if (!val) {
    selectedReason.value = null
    description.value = ''
    submitted.value = false
    loading.value = false
  }
})

const submit = async () => {
  if (!selectedReason.value || loading.value) return

  try {
    loading.value = true

    // API hívás — a végpontot igazítsd a saját backendedhez
    await api.post(`/api/report`, {
      type: props.type,          // 'post' vagy 'comment'
      target_id: props.targetId,
      reason: selectedReason.value,
      description: description.value || null
    })

    submitted.value = true

    // 2 másodperc után automatikusan bezárjuk
    setTimeout(() => {
      close()
    }, 2000)

  } catch (err) {
    // Ha van globális toast, itt meghívhatod:
    // showToast('Hiba történt a bejelentés küldésekor.', 'error')
    console.error('Report error:', err)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.report-backdrop {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10000;
  padding: 16px;
}

.report-modal {
  background: #fff;
  border-radius: 16px;
  padding: 28px 24px 22px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.18);
  width: 100%;
  max-width: 460px;
  animation: reportSlideIn 0.22s ease;
}

@keyframes reportSlideIn {
  from { opacity: 0; transform: translateY(12px) scale(0.97); }
  to   { opacity: 1; transform: translateY(0) scale(1); }
}

/* Fejléc */
.report-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 18px;
}

.report-header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

.report-header-icon {
  width: 36px;
  height: 36px;
  border-radius: 50%;
  background: #fef2f2;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #dc2626;
  font-size: 16px;
}

.report-modal-title {
  font-size: 16px;
  font-weight: 600;
  color: #1e293b;
  margin: 0;
}

.report-modal-subtitle {
  font-size: 12px;
  color: #64748b;
  margin: 0;
}

.report-close-btn {
  background: none;
  border: none;
  cursor: pointer;
  color: #94a3b8;
  font-size: 18px;
  line-height: 1;
  padding: 4px 6px;
  border-radius: 6px;
  transition: background 0.15s, color 0.15s;
}

.report-close-btn:hover {
  background: #f1f5f9;
  color: #475569;
}

/* Alcím */
.report-section-label {
  font-size: 13px;
  color: #64748b;
  margin: 0 0 12px;
}

/* Okok */
.report-reasons {
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 18px;
}

.report-reason {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  padding: 10px 14px;
  border-radius: 10px;
  border: 1.5px solid #e2e8f0;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s;
}

.report-reason:hover {
  border-color: #fca5a5;
  background: #fff5f5;
}

.report-reason.selected {
  border-color: #dc2626;
  background: #fef2f2;
}

.report-radio {
  margin-top: 2px;
  accent-color: #dc2626;
  flex-shrink: 0;
}

.reason-title {
  font-size: 14px;
  font-weight: 500;
  color: #1e293b;
  margin: 0 0 2px;
}

.reason-desc {
  font-size: 12px;
  color: #64748b;
  margin: 0;
}

/* Leírás */
.report-description-wrap {
  margin-bottom: 20px;
}

.report-desc-label {
  font-size: 13px;
  color: #64748b;
  display: block;
  margin-bottom: 6px;
}

.report-textarea {
  width: calc(100% - 24px);
  padding: 10px 12px;
  border-radius: 10px;
  border: 1.5px solid #e2e8f0;
  font-size: 13px;
  resize: vertical;
  color: #1e293b;
  background: #fff;
  transition: border-color 0.15s;
  font-family: inherit;
}

.report-textarea:focus {
  outline: none;
  border-color: #dc2626;
}

/* Gombok */
.report-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.report-btn-cancel {
  padding: 9px 20px;
  border-radius: 10px;
  border: 1px solid #e2e8f0;
  background: none;
  font-size: 13px;
  cursor: pointer;
  color: #475569;
  font-weight: 500;
  transition: background 0.15s;
}

.report-btn-cancel:hover {
  background: #f1f5f9;
}

.report-btn-submit {
  padding: 9px 22px;
  border-radius: 10px;
  border: none;
  background: #dc2626;
  color: white;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: background 0.15s, opacity 0.15s;
}

.report-btn-submit:hover:not(:disabled) {
  background: #b91c1c;
}

.report-btn-submit:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Spinner */
.report-spinner {
  width: 14px;
  height: 14px;
  border: 2px solid rgba(255, 255, 255, 0.4);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  display: inline-block;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Sikerüzenet */
.report-success {
  margin-top: 14px;
  padding: 10px 14px;
  border-radius: 10px;
  background: #f0fdf4;
  color: #166534;
  font-size: 13px;
  font-weight: 500;
  border: 1px solid #bbf7d0;
  text-align: center;
  animation: reportSlideIn 0.2s ease;
}

/* Reszponzivitás */
@media (max-width: 480px) {
  .report-modal {
    padding: 20px 16px 18px;
  }

  .report-reason {
    padding: 9px 11px;
  }
}
</style>