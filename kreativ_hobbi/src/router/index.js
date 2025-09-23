import { createRouter, createWebHistory } from 'vue-router'
import Aruhaz from '../views/Aruhaz.vue'
import Belepes from '../views/Belepes.vue'
import Blog from '../views/Blog.vue'
import Fizetes from '../views/Fizetes.vue'
import Kosar from '../views/Kosar.vue'
import Mintakeszito from '../views/Mintakeszito.vue'
import Profil from '../views/Profil.vue'
import Regisztracio from '../views/Regisztracio.vue'
import Rolunk from '../views/Rolunk.vue'
import Index from '@/views/index.vue'
import Mintavaltoztato from "@/views/Mintavaltoztato.vue";

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'index',
      component: Index,
    },
    {
      path: '/aruhaz',
      name: 'aruhaz',
      component: Aruhaz,
    },
    {
      path: '/belepes',
      name: 'belepes',
      component: Belepes,
    },
    {
      path: '/blog',
      name: 'blog',
      component: Blog,
    },
    {
      path: '/fizetes',
      name: 'fizetes',
      component: Fizetes,
    },
    {
      path: '/kosar',
      name: 'kosar',
      component: Kosar,
    },
    {
      path: '/mintakeszito',
      name: 'mintakeszito',
      component: Mintakeszito,
    },
    {
      path: '/profil',
      name: 'profil',
      component: Profil,
    },
    {
      path: '/regisztracio',
      name: 'regisztracio',
      component: Regisztracio,
    },
    {
      path: '/rolunk',
      name: 'rolunk',
      component: Rolunk,
    },
    {
      path: '/',
      component: Mintakeszito
    },
    {
      path: '/mintavaltoztato',
      component: Mintavaltoztato
    },
  ],
})

export default router
