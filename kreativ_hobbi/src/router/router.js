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
      name: 'Index',
      component: Index,
    },
    {
      path: '/aruhaz',
      name: 'Aruhaz',
      component: Aruhaz,
    },
    {
      path: '/belepes',
      name: 'Belepes',
      component: Belepes,
    },
    {
      path: '/regisztracio',
      name: 'Regisztracio',
      component: Regisztracio,
    },
    {
      path: '/blog',
      name: 'Blog',
      component: Blog,
    },
    {
      path: '/kosar/fizetes',
      name: 'Fizetes',
      component: Fizetes,
    },
    {
      path: '/kosar',
      name: 'Kosar',
      component: Kosar,
    },
    {
      path: '/mintakeszito',
      name: 'Mintakeszito',
      component: Mintakeszito,
    },
    {
      path: '/profil',
      name: 'Profil',
      component: Profil,
    },
    {
      path: '/rolunk',
      name: 'Rolunk',
      component: Rolunk,
    },
    {
      path: '/mintakeszito/mintavaltoztato',
      name: 'Mintavaltoztato',
      component: Mintavaltoztato
    },
  ],
})

export default router
