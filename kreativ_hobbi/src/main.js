import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router/router'
import axios from 'axios';
axios.defaults.baseURL = import.meta.env.VITE_API_URL;  // A Laravel API alap URL-je:contentReference[oaicite:7]{index=7}.
axios.defaults.withCredentials = true;                   // A cookie-k küldésének engedélyezése:contentReference[oaicite:8]{index=8}.
axios.defaults.withXSRFToken = true;                     // XSRF token küldése fejlécekben:contentReference[oaicite:9]{index=9}. // cookie-k engedélyezése


const app = createApp(App)

app.use(createPinia())
app.use(router)

app.mount('#app')
