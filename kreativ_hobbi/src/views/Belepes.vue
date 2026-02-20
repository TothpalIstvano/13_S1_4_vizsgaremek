<template>
  <div class="main">
    <!-- Sign Up Container -->
    <div class="container a-container" :class="{ 'is-txl': isSignInMode }">
      <form class="form" @submit.prevent="handleSignUp">
        <h2 class="title">Fiók készítése</h2>
        <label v-if="registerError !== ''" class="error-message">{{ registerError }}</label>
        <input class="form__input" autocomplete="username" name="username" type="text" placeholder="Felhasználónév" v-model="signUpForm.name" required>
        <input class="form__input" autocomplete="email" type="email" name="email" placeholder="Email" v-model="signUpForm.email" required>
        
        <div class="input-wrapper">
          <input class="form__input" autocomplete="new-password" name="password" :type="showSignUpPassword ? 'text' : 'password'" placeholder="Jelszó" v-model="signUpForm.password" minlength="8" required>
          <button type="button" class="eye-btn" @click="showSignUpPassword = !showSignUpPassword">
            <svg class="eye-icon" :class="{ 'eye-open': showSignUpPassword, 'eye-closed': !showSignUpPassword }" viewBox="0 0 24 24" fill="none">
              <path class="eye-outer" d="M1 12C1 12 5 4 12 4C19 4 23 12 23 12C23 12 19 20 12 20C5 20 1 12 1 12Z" stroke="#8b0404" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
              <circle class="eye-pupil" cx="12" cy="12" r="3" stroke="#8b0404" stroke-width="1.8"/>
              <line class="eye-slash" x1="3" y1="3" x2="21" y2="21" stroke="#8b0404" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </button>
        </div>

        <transition-group name="error">
        <label for="password" v-if="!isSignInMode && !passwordValid" v-for="error in errors" :key="error" :style="{}" class="error-message">{{ error }}</label>
        </transition-group>
        <input class="form__input" autocomplete="new-password" name="password_confirmation" type="password" placeholder="Jelszó megerositése" v-model="signUpForm.password_confirmation" minlength="8" required>
        <label for="password_confirmation" v-if="signUpForm.password && signUpForm.password_confirmation && signUpForm.password !== signUpForm.password_confirmation" class="error-message">A két jelszó nem egyezik!</label>
        <label class='form__checkbox'>
        <input type='checkbox' name='terms' v-model="signUpForm.terms" required/> Elolvastam és elfogadom a Felhasználási feltételeket
        </label>
        <label class='form__checkbox'>
          <input type="checkbox" required name="checkbox" v-model="signUpForm.privacy" /> Elolvastam és elfogadom a Adatvédelmi irányelveket
        </label>
        <button class="button" type="submit" :disabled="buttonflag  ">Fiók létrehozása</button>
      </form>
    </div>

    <!-- Sign In Container -->
    <div class="container b-container" :class="{ 'is-txl is-z200': isSignInMode }">
      <form class="form" @submit.prevent="handleSignIn" method="post" action="/login" redirect="/">
        <h2 class="title">Lépj be a fiókodba</h2>
        <label v-if="loginError !== ''" class="error-message">{{ loginError }}</label>
        <input class="form__input" name="email" autocomplete="email" type="email" placeholder="Email" v-model="signInForm.email" required>
        
        <div class="input-wrapper">
          <input class="form__input" name="password" autocomplete="current-password" minlength="8" :type="showSignUpPassword ? 'text' : 'password'" placeholder="Jelszó" v-model="signInForm.password" required>
          <button type="button" class="eye-btn" @click="showSignUpPassword = !showSignUpPassword">
            <svg class="eye-icon" :class="{ 'eye-open': showSignUpPassword, 'eye-closed': !showSignUpPassword }" viewBox="0 0 24 24" fill="none">
              <path class="eye-outer" d="M1 12C1 12 5 4 12 4C19 4 23 12 23 12C23 12 19 20 12 20C5 20 1 12 1 12Z" stroke="#8b0404" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
              <circle class="eye-pupil" cx="12" cy="12" r="3" stroke="#8b0404" stroke-width="1.8"/>
              <line class="eye-slash" x1="3" y1="3" x2="21" y2="21" stroke="#8b0404" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
          </button>
        </div>
        
        <a class="form__link" href="#" @click.prevent="showForgotPassword = true">Elfelejtetted a jelszavad?</a>
        <button class="button" type="submit">Bejelentkezés</button>
      </form>
    </div>

    <!-- Switch Panel -->
    <div class="switch" :class="{ 'is-txr': isSignInMode }">
      <div class="switch__circle" :style="{ transform: isSignInMode ? 'translateX(0%)' : 'translateX(60%)' }"></div>
      <div class="switch__circle switch__circle--t" :style="{ transform: isSignInMode ? 'translateX(0%)' : 'translateX(-60%)' }"></div>
      <div class="switch__container" :class="{ 'is-hidden': isSignInMode }">
        <h2 class="title">Üdvözöljük vissza!</h2>
        <p class=" description">A kapcsolat fenntartásához kérjük, jelentkezzen be személyes adataival</p>
        <button class="switch__button button" @click="toggleForm">Bejelentkezés</button>
      </div>
      <div class="switch__container" :class="{ 'is-hidden': !isSignInMode }">
        <h2 class="title">Helló Barátom!</h2>
        <p class=" description">Add meg személyes adataidat, és kezdd el az utazást velünk</p>
        <button class="switch__button button" @click="toggleForm" >Regisztráció</button>
      </div>
    </div>
  </div>
  <!-- Elfelejtett jelszó modal -->
  <transition name="fade">
    <div v-if="showForgotPassword" class="modal-overlay" @click.self="showForgotPassword = false">
      <div class="modal-box">
        <h3 class="modal-title">Jelszó visszaállítása</h3>

        <div v-if="!forgotSent">
          <p class="modal-desc">Add meg az email címedet és küldünk egy visszaállító linket.</p>
          <input
            class="form__input"
            type="email"
            placeholder="Email cím"
            v-model="forgotEmail"
            style="width:100%; margin: 12px 0;"
          />
          <label v-if="forgotError" class="error-message">{{ forgotError }}</label>
          <button class="button" style="margin-top:16px; width:100%;" @click="sendForgotPassword">
            Link küldése
          </button>
        </div>

        <div v-else>
          <p class="modal-desc" style="color: #2ecc71; font-weight:600;">
            ✓ Elküldtük a visszaállító linket! Ellenőrizd az emailedet.
          </p>
        </div>

        <button class="close-btn" @click="showForgotPassword = false">✕</button>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { onMounted, ref, watch } from 'vue'
import axios from 'axios' 
import router from '@/router/router'

async function check (){
    try {
      const response = await axios.get('/api/user/check', { withCredentials: true })
      if (response.data.loggedIn) {
        router.push('/profil')
      }
    } catch (error) {
      console.log(error)
    }
  }

onMounted(() => {
  check();
});


const isSignInMode = ref(true)
const loading = ref(false)
const loginError = ref('')
const registerError = ref('')
const errors = ref([])
const passwordValid = ref(false)
const buttonflag = ref(false)
const showSignInPassword = ref(false)
const showSignUpPassword = ref(false)
const showSignUpPasswordConfirm = ref(false)
const signUpForm = ref({
  name: '',
  email: '',
  password: '',
  password_confirmation: '',
  terms: false,
  privacy: false,
})

const signInForm = ref({
  email: '',
  password: '',
})

const showForgotPassword = ref(false)
const forgotEmail = ref('')
const forgotError = ref('')
const forgotSent = ref(false)

const sendForgotPassword = async () => {
  forgotError.value = ''
  if (!forgotEmail.value.includes('@')) {
    forgotError.value = 'Kérjük, adj meg egy érvényes email címet.'
    return
  }
  try {
    await axios.get('/sanctum/csrf-cookie')
    await axios.post('/forgot-password', { email: forgotEmail.value }, { withCredentials: true })
    forgotSent.value = true
  } catch (err) {
    forgotError.value = err.response?.data?.message || 'Hiba történt, próbáld újra.'
  }
}

const toggleForm = () => {
  document.documentElement.style.setProperty('--errorColor', isSignInMode.value ? 'green' : 'grey');
  isSignInMode.value = !isSignInMode.value
  loginError.value = ''
}

const validatePassword = (password) => {
  const error = []

  if (password.length < 8) {
    error.push('*A jelszónak legalább 8 karakter hosszúnak kell lennie.')
  }
  if (!/[A-Z]/.test(password)|| !/[a-z]/.test(password)) {
    error.push('*Tartalmaznia kell kis és nagybetűt.')
  }
  if (!/[0-9]/.test(password)) {
    error.push('*Tartalmaznia kell számot.')
  }
  if (!/[^a-zA-Z0-9\s]/.test(password)) {
    error.push('*Tartalmaznia kell speciális karaktert.')
  }
  if (/\s/.test(password)) {
    error.push('*A jelszó nem tartalmazhat szóközt.')
  }
  return error
}

watch(
  () => signUpForm.value.password,
  (newPassword) => {
    errors.value = validatePassword(newPassword)
    passwordValid.value = errors.value.length === 0
  }
)
watch(
  () => [signUpForm.value.password, signUpForm.value.terms, signUpForm.value.privacy, buttonflag.value, signUpForm.value.email, signUpForm.value.name, signUpForm.value.password_confirmation],
  ([password, terms, privacy, buttonFlag, email, name, passwordConfirmation]) => {
    buttonflag.value = !passwordValid.value || !terms || !privacy || !email || !name || !passwordConfirmation || password !== passwordConfirmation
  }
)

const handleSignIn = async () => {

  loading.value = true
  loginError.value = ref('')

  try {
    // Frontend validation
    if (!signInForm.value.email || !signInForm.value.password) {
      throw new Error('Please fill in all fields')
    }
    
    if (!signInForm.value.email.includes('@')) {
      throw new Error('Please enter a valid email')
    }
    
    if (signInForm.value.password.length < 8) {
      throw new Error('Password must be at least 8 characters')
    }
    
    // API call to login
    await axios.get('/sanctum/csrf-cookie') // Get CSRF cookie if needed

    const response = await axios.post('/login', {
      email: signInForm.value.email,
      password: signInForm.value.password,
    },{
      withCredentials: true
    })
    console.log('Login response:', response);

    if (response.status === 204) {
      router.push('/Profil') // Redirect to profile page on successful login
      // Dispatch a custom event
      window.dispatchEvent(new Event('user-logged-in'));

    }
    else {
      throw new Error('Login failed. Please check your credentials.')
    }
    // Redirect to dashboard or home
    
  } catch (error) {
    loginError.value = error.response?.data?.message || error.message || 'Login failed. Please try again.'
  } finally {
    loading.value = false
  }
}

const handleSignUp = async () => {

  loading.value = true
  loginError.value = ''
  buttonflag.value = true

  try {
    if (!signUpForm.value.name || !signUpForm.value.email || !signUpForm.value.password) {
      throw new Error('Please fill in all fields')
    }

    if (!signUpForm.value.email.includes('@')) {
      throw new Error('Please enter a valid email')
    }

    if (signUpForm.value.password.length < 3) {
      throw new Error('Password must be at least 3 characters')
    }

    // API call to register
    await axios.get('/sanctum/csrf-cookie') // Get CSRF cookie if needed

    console.log(signUpForm.value.password)

    const response = await axios.post('/register', {
      felhasz_nev: signUpForm.value.name,
      email: signUpForm.value.email,
      password: signUpForm.value.password,
      password_confirmation: signUpForm.value.password_confirmation,
    }, {
      withCredentials: true
    })

    console.log('Registration response:', response);

    // backend returns noContent() (204) after registering and logging in the user
    if (response.status === 204 || response.status === 201) {
      router.push('/Profil')
      window.dispatchEvent(new Event('user-logged-in'));
    } else {
      throw new Error('Registration failed. Please try again.')
    }
    }
  catch (error) {
    if (error.response?.status === 422 && error.response.data?.errors) {
      // join validation errors into a single message
      const errs = Object.values(error.response.data.errors).flat().join(' ')
      registerError.value = errs || error.response.data.message || error.message
      console.log('Validation errors:', error.response.data.errors);
    } else {
      registerError.value = error.response?.data?.message?.includes('felhasz_nev', 'duplicate') ? 'Username already exists.' : 'Registration failed. Please try again.'
    }
  } finally {
    loading.value = false
    buttonflag.value = false
  }
}

</script>

<style scoped>
*, *::after, *::before {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    user-select: none;
}

/* Generic */
.error-message {
  color:#e74c3c;
  font-size: 12px;
  width: 350px;
  margin: 6px 0;
  padding-left: 10px;
  font-size: 13px;
  letter-spacing: .15px;
  font-family: 'Montserrat', sans-serif;
  text-align: left;
}

.error-enter-active {
  animation: alertPopup 0.5s ease-out forwards;
}

/* LEAVE */
.error-leave-active {
  animation: alertFadeOut 0.6s ease-in-out forwards;
}

/* Prevent jump when leaving */
.error-leave-to {
  opacity: 0;
}
/*
.success-fade.error-leave-active {
  color: green;
}
*/
@keyframes alertPopup {
    0% {
        opacity: 0;
    }
    100% {
        opacity: 1;
    }
}

@keyframes alertFadeOut {
    0% {
        opacity: 1;
    }
    60% {
       color: var(--errorColor);
    }
    100% {
        opacity: 0;
    }
}

/**/
.main {
    margin: 6.5% auto 0; 
    position: relative;
    width: 1000px;
    min-width: 1000px;
    min-height: 600px;
    height: 650px;
    padding: 25px;
    background-color: #ecf0f3;
    box-shadow:
        10px 10px 10px #d1d9e6,
        -10px -10px 10px #f9f9f9;
    border-radius: 12px;
    overflow: hidden;
}

@media(max-width: 1200px) {
    .main {
        transform: scale(.7);
    }
}

@media(max-width: 1000px) {
    .main {
        transform: scale(.6);
    }
}

@media(max-width: 800px) {
    .main {
        transform: scale(.5);
    }
}

@media(max-width: 600px) {
    .main {
        transform: scale(.4);
    }
}

.container {
    display: flex;
    justify-content: center;
    align-items: center;
    position: absolute;
    top: 0;
    width: 600px;
    height: 100%;
    padding: 25px;
    background-color: #ecf0f3;
    transition: 1.25s;
}

.form {

    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    width: 100%;
    height: 100%;
}

.form__icon {
    object-fit: contain;
    width: 30px;
    margin: 0 5px;
    opacity: .5;
    transition: .15s;
}

.form__icon:hover {
    opacity: 1;
    transition: .15s;
    cursor: pointer;
}

.form__input {
    width: 350px;
    height: 40px;
    margin: 4px 0;
    padding-left: 25px;
    font-size: 13px;
    letter-spacing: .15px;
    border: none;
    outline: none;
    font-family: 'Montserrat', sans-serif;
    background-color: #ecf0f3;
    transition: .25s ease;
    border-radius: 8px;
    box-shadow:
        inset 2px 2px 4px #d1d9e6,
        inset -2px -2px 4px #f9f9f9;
}

.form__input::placeholder {
    color: #8b0404a1;
}

.form__input:focus {
    box-shadow:
        inset 4px 4px 4px #d1d9e6,
        inset -4px -4px 4px #f9f9f9;
}

.form__checkbox {
    display: flex;
    align-items: center;
    font-size: 16   px;
    margin-top: 15px;
    color: #181818;
    cursor: pointer;
}

.form__checkbox input {
    width: 15px;
    height: 15px;
    margin-right: 10px;
    cursor: pointer;
}

.form__checkbox input:checked {
    accent-color: #8b0404;
}

.form__span {
    margin-top: 30px;
    margin-bottom: 12px;
}

.form__link {
    color: #181818;
    font-size: 15px;
    margin-top: 25px;
    border-bottom: 1px solid #8b0404;
    line-height: 2;
    text-decoration: none;
}

.input-wrapper { 
  position: relative;
  display: flex; 
  align-items: center; 
  width: 350px; 
  margin: 4px 0; 
}

.input-wrapper .form__input { 
  width: 100%; 
  margin: 0; 
  padding-right: 44px; 
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

.title {
    font-size: 34px;
    font-weight: 700;
    line-height: 3;
    color: #181818;
}

.description {
    font-size: 14px;
    letter-spacing: .25px;
    text-align: center;
    line-height: 1.6;
}

.button {
    width: 180px;
    height: 50px;
    border-radius: 25px;
    margin-top: 50px;
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 1.15px;
    background-color: #8b0404;
    color: #f9f9f9;
    box-shadow:
        8px 8px 16px #d1d9e6,
        -8px -8px 16px #f9f9f9;
    border: none;
    outline: none;
    cursor: pointer;
}

/**/
.a-container {
    z-index: 1;
    left: calc(100% - 600px);
}

.b-container {
    left: calc(100% - 600px);
    z-index: 0;
}

.switch {
    display: flex;
    justify-content: center;
    align-items: center;
    position: absolute;
    top: 0;
    left: 0;
    height: 100%;
    width: 400px;
    padding: 50px;
    z-index: 2;
    transition: 2s;
    background-color: #ecf0f3;
    overflow: hidden;
    box-shadow:
        4px 4px 10px #d1d9e6,
        -4px -4px 10px #f9f9f9;
}

.switch__circle {
    position: absolute;
    width: 500px;
    height: 500px;
    border-radius: 50%;
    background-color: #ecf0f3;
    box-shadow:
        inset 8px 8px 12px #8b040442,
        inset -8px -8px 12px #8b040442;
    bottom: -60%;
    left: -60%;
    transition: 1.25s;
    transform: translateX(60%);
}

.switch__circle--t {
    top: -30%;
    left: 60%;
    width: 300px;
    height: 300px;
    transition: 1.25s;
}

.switch__container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    position: absolute;
    width: 400px;
    padding: 50px 55px;
    transition: 1.25s;
}

.switch__button {
    cursor: pointer;
}

.switch__button:hover {
    box-shadow:
        6px 6px 10px #d1d9e6,
        -6px -6px 10px #f9f9f9;
    transform: scale(.985);
    transition: .25s;
}

.switch__button:active,
.switch__button:focus,
.button:active,
.button:focus {
    box-shadow:
        2px 2px 6px #d1d9e6,
        -2px -2px 6px #f9f9f9;
    transform: scale(.97);
    transition: .25s;
}

/**/
.is-txr {
    left: calc(100% - 400px);
    transition: 1.25s;
    transform-origin: left;
}

.is-txl {
    left: 0;
    transition: 2s;
    transform-origin: right;
}

.is-z200 {
    z-index: 2;
    transition: 2s;
}

.is-hidden {
    visibility: hidden;
    opacity: 0;
    position: absolute;
    transition: 1.25s;
}

.is-gx {
    animation: is-gx 1.25s ease-in-out forwards;
}

@keyframes is-gx {
    0%, 10%, 100% {
        width: 400px;
    }
    30%, 50% {
        width: 500px;
    }

}

.modal-overlay {
  position: fixed; inset: 0; background: rgba(0,0,0,0.35);
  display: flex; justify-content: center; align-items: center; z-index: 999;
}
.modal-box {
  position: relative; background: #ecf0f3; border-radius: 12px;
  padding: 40px 50px; width: 400px;
  box-shadow: 10px 10px 10px #d1d9e6, -10px -10px 10px #f9f9f9;
  display: flex; flex-direction: column; align-items: center;
}
.modal-title { font-size: 22px; font-weight: 700; color: #181818; margin-bottom: 8px; }
.modal-desc { font-size: 13px; color: #555; text-align: center; }
.close-btn {
  position: absolute; top: 12px; right: 16px;
  background: none; border: none; font-size: 18px; cursor: pointer; color: #8b0404;
}
.fade-enter-active, .fade-leave-active { transition: opacity 0.3s; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>