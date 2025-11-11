https://dev.to/robin-ivi/laravel-12-and-vue-3-ultimate-starter-guide-3bmd
https://benjamincrozat.com/laravel-vue



**laravel letöltése composerrel:**

composer create-project --prefer-dist laravel/laravel my-laravel-app

cd my-laravel-app



**duplikáljuk az .env.example fájlt:**

cp .env.example .env

php artisan key:generate



**adatbázis frissítése és migrálása:**

DB\_DATABASE=mydatabase

DB\_USERNAME=root

DB\_PASSWORD=mysql

php artisan migrate



**a vue-hoz letöltjük a vite plugint:**

npm install vue @vitejs/plugin-vue



**a vite.config.js-t átírjuk:**

import { defineConfig } from 'vite';

import vue from '@vitejs/plugin-vue';

import laravel from 'laravel-vite-plugin';

export default defineConfig({

  plugins: \[

  laravel({

  input: \['resources/js/app.js'],

  refresh: true,

  }),

  vue(),

  ],

});



**a laravelben változtatunk:**

**resources/js/app.js:**

import { createApp } from 'vue';

import App from './components/App.vue';

import router from './router';

createApp(App).use(router).mount('#app');

**resources/js/components/App.vue:**

<template>

  <div>

  <h1>Welcome to Laravel 12 with Vue 3</h1>

  </div>

</template>

