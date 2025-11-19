import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router/router'
import axios from 'axios';
axios.defaults.baseURL = import.meta.env.VITE_API_URL;   // backend URL
axios.defaults.withCredentials = true;                   // cookie-k engedélyezése


const app = createApp(App)

app.use(createPinia())
app.use(router)

app.mount('#app')
