import { createRouter, createWebHistory } from 'vue-router'
import Aruhaz from '../views/Aruhaz.vue'
import Belepes from '../views/Belepes.vue'
import Blog from '../views/Blog.vue'
import SingleBlog from '../components/SingleBlog.vue'
import SingleItem from '../components/SingleItem.vue'
import Fizetes from '../views/Fizetes.vue'
import Kosar from '../views/Kosar.vue'
import Mintakeszito from '../views/Mintakeszito.vue'
import Profil from '../views/Profil.vue'
import Rolunk from '../views/Rolunk.vue'
import Index from '@/views/index.vue'
import Dino from "@/views/Dino.vue";
import NotFound from "@/views/NotFound.vue";
import NewPost from '@/components/NewPost.vue'
import EmailVerified from '@/components/EmailVerified.vue'
import Dashboard from '@/views/Dashboard.vue'
import ResetJelszo from '@/views/ResetJelszo.vue'

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
      path: '/aruhaz/:id',
      name: 'SingleItem',
      component: SingleItem,
      props: true
    },
    {
      path: '/belepes',
      name: 'Belepes',
      component: Belepes,
    },
    {
      path: '/blog',
      name: 'Blog',
      component: Blog,
    },
    {
      path: '/blog/:id',
      name: 'SingleBlog',
      component: SingleBlog,
      props: true
    },
    {
      path: '/newpost',
      name: 'NewPost',
      component: NewPost,
    },
    {
      path: '/editpost/:id',
      name: 'EditPost',
      component: NewPost,
      props: route => ({ postId: route.params.id })
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
      path: '/dino',
      name: 'Dino',
      component: Dino
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      component: Dashboard
    },
    {
      path: '/email-verified',
      name: 'EmailVerified',
      component: EmailVerified
    },
    {
      path: '/reset-password',
      name: 'ResetJelszo',
      component: ResetJelszo
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      component: NotFound
    },
  ],
})

router.beforeEach((to, from, next) => {
  if (to.name === 'NotFound') {
    console.warn(`Navigation to non-existent route: ${to.fullPath}`)
  }
  next()
})

export default router