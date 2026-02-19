<template>
  <div class="reset-wrapper">
    <div class="reset-box">
      <h2 class="title">Új jelszó megadása</h2>

      <div v-if="!success">
        <input class="form__input" type="password" placeholder="Új jelszó (min. 8 karakter)" v-model="password" />
        <input class="form__input" type="password" placeholder="Jelszó megerősítése" v-model="password_confirmation" style="margin-top: 8px;" />
        <label v-if="errorMsg" class="error-message">{{ errorMsg }}</label>
        <button class="button" @click="resetPassword">Mentés</button>
      </div>

      <div v-else>
        <p style="color: #2ecc71; font-weight: 600; margin-top: 20px;">
          ✓ Jelszó sikeresen megváltoztatva! Átirányítás...
        </p>
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
  display: flex; justify-content: center; align-items: center; min-height: 80vh;
}
.reset-box {
  background: #ecf0f3;
  border-radius: 12px;
  padding: 50px 60px;
  box-shadow: 10px 10px 10px #d1d9e6, -10px -10px 10px #f9f9f9;
  display: flex; flex-direction: column; align-items: center; gap: 12px;
}
.form__input {
  width: 320px; height: 40px; padding-left: 20px;
  border: none; outline: none; border-radius: 8px;
  background: #ecf0f3;
  box-shadow: inset 2px 2px 4px #d1d9e6, inset -2px -2px 4px #f9f9f9;
  font-size: 13px;
}
.button {
  width: 180px; height: 50px; border-radius: 25px; margin-top: 20px;
  font-weight: 700; font-size: 14px; background-color: #8b0404;
  color: #f9f9f9; border: none; cursor: pointer;
}
.error-message { color: #e74c3c; font-size: 13px; }
.title { font-size: 28px; font-weight: 700; color: #181818; margin-bottom: 10px; }
</style>