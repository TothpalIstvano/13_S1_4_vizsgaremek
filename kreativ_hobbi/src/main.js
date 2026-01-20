import './assets/main.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

// PrimeVue dolgok
import PrimeVue from 'primevue/config'
import 'primevue/resources/themes/aura-light-green/theme.css'
import 'primevue/resources/primevue.min.css' // Core CSS
import 'primeicons/primeicons.css' // Icons
import 'quill/dist/quill.core.css'
import 'quill/dist/quill.snow.css'

import App from './App.vue'
import router from './router/router'
import axios from 'axios';

axios.defaults.baseURL = import.meta.env.VITE_API_URL;  // A Laravel API alap URL-je:contentReference[oaicite:7]{index=7}.
axios.defaults.withCredentials = true;                   // A cookie-k küldésének engedélyezése:contentReference[oaicite:8]{index=8}.
axios.defaults.withXSRFToken = true;                     // XSRF token küldése fejlécekben:contentReference[oaicite:9]{index=9}. // cookie-k engedélyezése

// Add token to all requests
axios.interceptors.request.use(config => {
    const token = localStorage.getItem('auth_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Handle 401 responses 
axios.interceptors.response.use(
    response => response,
    error => {
        if (error.response && error.response.status === 401) {
            // Token expired or invalid, redirect to login
            localStorage.removeItem('auth_token');
            localStorage.removeItem('user');
        }
        return Promise.reject(error);
    }
);


const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(PrimeVue)

//hogy minden szépen/jól működjön
import Button from 'primevue/button';
import InputText from 'primevue/inputtext';
import MultiSelect from 'primevue/multiselect';
import Editor from 'primevue/editor';
import Image from 'primevue/image';

app.component('Button', Button);
app.component('InputText', InputText);
app.component('MultiSelect', MultiSelect);
app.component('Editor', Editor);
app.component('Image', Image);

app.mount('#app')
