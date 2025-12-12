<template>
  <div class="main">
    <!-- Sign Up Container -->
    <div class="container a-container" :class="{ 'is-txl': isSignUpMode }">
      <form class="form" @submit.prevent="handleSignUp">
        <h2 class="title">Fiók készítése</h2>
        <input class="form__input" autocomplete="username" type="text" placeholder="Felhasználónév" v-model="signUpForm.name" required>
        <input class="form__input" autocomplete="email" type="email" placeholder="Email" v-model="signUpForm.email" required>
        <input class="form__input" autocomplete="new-password" type="password" placeholder="Jelszó" v-model="signUpForm.password" required>
        <label class='form__checkbox'>
        <input type='checkbox' name='terms' v-model="signUpForm.terms" required/> Elolvastam és elfogadom a Felhasználási feltételeket
        </label>
        <label class='form__checkbox'>
          <input type="checkbox" name="checkbox" v-model="signUpForm.privacy" /> Elolvastam és elfogadom a Adatvédelmi irányelveket
        </label>
        <button class="button" type="submit">Fiók létrehozása</button>
      </form>
    </div>

    <!-- Sign In Container -->
    <div class="container b-container" :class="{ 'is-txl is-z200': isSignUpMode }">
      <form class="form" @submit.prevent="handleSignIn" method="post" action="/login" redirect="/">
        <h2 class="title">Lépj be a fiókodba</h2>
        <input class="form__input" autocomplete="email" type="email" placeholder="Email" v-model="signInForm.email" required>
        <input class="form__input" autocomplete="current-password" type="password" placeholder="Jelszó" v-model="signInForm.password" required>
        <a class="form__link" href="#">Elfelejtetted a jelszavad?</a>
        <button class="button" type="submit">Bejelentkezés</button>
      </form>
    </div>

    <!-- Switch Panel -->
    <div class="switch" :class="{ 'is-txr': isSignUpMode }">
      <div class="switch__circle" :style="{ transform: isSignUpMode ? 'translateX(0%)' : 'translateX(60%)' }"></div>
      <div class="switch__circle switch__circle--t" :style="{ transform: isSignUpMode ? 'translateX(0%)' : 'translateX(-60%)' }"></div>
      <div class="switch__container" :class="{ 'is-hidden': isSignUpMode }">
        <h2 class="title">Üdvözöljük vissza!</h2>
        <p class=" description">A kapcsolat fenntartásához kérjük, jelentkezzen be személyes adataival</p>
        <button class="switch__button button" @click="toggleForm">Bejelentkezés</button>
      </div>
      <div class="switch__container" :class="{ 'is-hidden': !isSignUpMode }">
        <h2 class="title">Helló Barátom!</h2>
        <p class=" description">Add meg személyes adataidat, és kezdd el az utazást velünk</p>
        <button class="switch__button button" @click="toggleForm">Regisztráció</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios' 
import router from '@/router/router'

//#region reactive elements
const isSignUpMode = ref(true)
const loading = ref(false)
const loginError = ref('')

const signUpForm = ref({
  name: '',
  email: '',
  password: '',
  terms: false,
  privacy: false,
})

const signInForm = ref({
  email: '',
  password: '',
})

const toggleForm = () => {
  isSignUpMode.value = !isSignUpMode.value
  loginError.value = ''
}

const handleSignIn = async () => {

  loading.value = true
  loginError.value = ''

  try {
    // Frontend validation
    if (!signInForm.value.email || !signInForm.value.password) {
      throw new Error('Please fill in all fields')
    }
    
    if (!signInForm.value.email.includes('@')) {
      throw new Error('Please enter a valid email')
    }
    
    if (signInForm.value.password.length < 3) {
      throw new Error('Password must be at least 3 characters')
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
  // You can implement signup logic here similarly
  console.log('Sign up form submitted:', signUpForm.value)
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
  color: #e74c3c;
  margin-top: 10px;
  font-size: 14px;
  text-align: center;
}

/**/
.main {
    margin: 5% auto 0; 
    position: relative;
    width: 1000px;
    min-width: 1000px;
    min-height: 600px;
    height: 600px;
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

</style>