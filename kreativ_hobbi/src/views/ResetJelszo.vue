<template>
  <div class="reset-wrapper">
    <div class="reset-box">
      <h2 class="title">Új jelszó megadása</h2>

      <div v-if="!success" class="form">
        <div class="input-wrapper">
          <input class="form__input" :type="showPassword ? 'text' : 'password'" placeholder="Új jelszó (min. 8 karakter)" v-model="password" />
          <button type="button" class="eye-btn" @click="showPassword = !showPassword">
            <svg class="eye-icon" :class="{ 'eye-open': showPassword, 'eye-closed': !showPassword }" viewBox="0 0 24 24" fill="none">
              <path class="eye-outer" d="M1 12C1 12 5 4 12 4C19 4 23 12 23 12C23 12 19 20 12 20C5 20 1 12 1 12Z" stroke="#8b0404" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
              <circle class="eye-pupil" cx="12" cy="12" r="3" stroke="#8b0404" stroke-width="1.8"/>
              <line class="eye-slash" x1="3" y1="3" x2="21" y2="21" stroke="#8b0404" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </button>
        </div>

        <div class="input-wrapper">
          <input class="form__input" :type="showPasswordConfirm ? 'text' : 'password'" placeholder="Jelszó megerősítése" v-model="password_confirmation" />
          <button type="button" class="eye-btn" @click="showPasswordConfirm = !showPasswordConfirm">
            <svg class="eye-icon" :class="{ 'eye-open': showPasswordConfirm, 'eye-closed': !showPasswordConfirm }" viewBox="0 0 24 24" fill="none">
              <path class="eye-outer" d="M1 12C1 12 5 4 12 4C19 4 23 12 23 12C23 12 19 20 12 20C5 20 1 12 1 12Z" stroke="#8b0404" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
              <circle class="eye-pupil" cx="12" cy="12" r="3" stroke="#8b0404" stroke-width="1.8"/>
              <line class="eye-slash" x1="3" y1="3" x2="21" y2="21" stroke="#8b0404" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </button>
        </div>

        <label v-if="errorMsg" class="error-message">{{ errorMsg }}</label>
        <button class="button" @click="resetPassword">Mentés</button>
      </div>

      <div v-else>
        <p class="success-message">✓ Jelszó sikeresen megváltoztatva! Átirányítás...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import axios from 'axios'

const route = useRoute()
const router = useRouter()

const password = ref('')
const password_confirmation = ref('')
const errorMsg = ref('')
const success = ref(false)
const showPassword = ref(false)
const showPasswordConfirm = ref(false)

const resetPassword = async () => {
  errorMsg.value = ''
  if (password.value.length < 8) {
    errorMsg.value = 'A jelszónak legalább 8 karakter hosszúnak kell lennie.'
    return
  }
  if (password.value !== password_confirmation.value) {
    errorMsg.value = 'A két jelszó nem egyezik.'
    return
  }
  try {
    await axios.get('/sanctum/csrf-cookie')
    await axios.post('/reset-password', {
      token: route.query.token,
      email: route.query.email,
      password: password.value,
      password_confirmation: password_confirmation.value,
    }, { withCredentials: true })

    success.value = true
    setTimeout(() => router.push('/belepes'), 2500)
  } catch (err) {
    errorMsg.value = err.response?.data?.errors?.email?.[0]
      || err.response?.data?.message
      || 'Érvénytelen vagy lejárt token.'
  }
}
</script>

<style scoped>
.reset-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 80vh;
}

.reset-box {
  background: #ecf0f3;
  border-radius: 12px;
  padding: 50px 60px;
  box-shadow: 10px 10px 10px #d1d9e6, -10px -10px 10px #f9f9f9;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
}

.title {
  font-size: 28px;
  font-weight: 700;
  color: #181818;
  margin-bottom: 10px;
  line-height: 2;
}

.form {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  gap: 8px;
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  width: 320px;
  margin: 4px 0;
}

.input-wrapper .form__input {
  width: 100%;
  margin: 0;
  padding-right: 44px;
}

.form__input {
  width: 320px;
  height: 40px;
  padding-left: 20px;
  border: none;
  outline: none;
  border-radius: 8px;
  background: #ecf0f3;
  box-shadow: inset 2px 2px 4px #d1d9e6, inset -2px -2px 4px #f9f9f9;
  font-size: 13px;
  font-family: 'Montserrat', sans-serif;
  transition: .25s ease;
}

.form__input::placeholder {
  color: #8b0404a1;
}

.form__input:focus {
  box-shadow: inset 4px 4px 4px #d1d9e6, inset -4px -4px 4px #f9f9f9;
}

.eye-btn {
  position: absolute;
  right: 10px;
  background: none;
  border: none;
  outline: none;
  cursor: pointer;
  padding: 4px;
  display: flex;
  align-items: center;
  border-radius: 50%;
  transition: background 0.2s;
}

.eye-btn:hover { background: rgba(139,4,4,0.08); }
.eye-icon { width: 20px; height: 20px; overflow: visible; }
.eye-outer, .eye-pupil, .eye-slash { transition: opacity 0.3s ease, transform 0.35s ease; transform-origin: 12px 12px; }
.eye-open .eye-slash { opacity: 0; transform: scaleX(0); }
.eye-open .eye-outer { opacity: 1; }
.eye-open .eye-pupil { opacity: 1; transform: scale(1); }
.eye-closed .eye-slash { opacity: 1; }
.eye-closed .eye-outer { opacity: 0.35; }
.eye-closed .eye-pupil { opacity: 0; transform: scale(0); }
.eye-open { animation: eyeOpen 0.35s ease forwards; }
.eye-closed { animation: eyeClose 0.35s ease forwards; }
@keyframes eyeOpen { 0% { transform: scaleY(0.1); } 60% { transform: scaleY(1.15); } 100% { transform: scaleY(1); } }
@keyframes eyeClose { 0% { transform: scaleY(0.1); } 40% { transform: scaleY(1.1); } 100% { transform: scaleY(1); } }

.button {
  width: 180px;
  height: 50px;
  border-radius: 25px;
  margin-top: 20px;
  font-weight: 700;
  font-size: 14px;
  letter-spacing: 1.15px;
  background-color: #8b0404;
  color: #f9f9f9;
  box-shadow: 8px 8px 16px #d1d9e6, -8px -8px 16px #f9f9f9;
  border: none;
  outline: none;
  cursor: pointer;
}

.button:active, .button:focus {
  box-shadow: 2px 2px 6px #d1d9e6, -2px -2px 6px #f9f9f9;
  transform: scale(.97);
  transition: .25s;
}

.error-message {
  color: #e74c3c;
  font-size: 13px;
  width: 320px;
  padding-left: 10px;
  font-family: 'Montserrat', sans-serif;
}

.success-message {
  color: #2ecc71;
  font-weight: 600;
  margin-top: 20px;
  font-family: 'Montserrat', sans-serif;
}
</style>