import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth.js'
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
import NotFound from "@/views/NotFound.vue";
import NewPost from '@/components/NewPost.vue'
import EmailVerified from '@/components/EmailVerified.vue'
import EmailAlreadyVerified from '@/components/EmailAlreadyVerified.vue'
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
      meta:{guestOnly: true}
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
      meta:{requiresAuth: true}
    },
    {
      path: '/editpost/:id',
      name: 'EditPost',
      component: NewPost,
      props: route => ({ postId: route.params.id }),
      meta:{requiresAuth: true}
    },
    {
      path: '/kosar/fizetes/:id',
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
      meta:{requiresAuth: true}
    },
    {
      path: '/rolunk',
      name: 'Rolunk',
      component: Rolunk,
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      component: Dashboard,
      meta: { requiresAuth: true, roles: ['admin', 'moderator'] }
    },
    {
      path: '/email-verified',
      name: 'EmailVerified',
      component: EmailVerified
    },
    {
      path: '/email-already-verified',
      name: 'EmailAlreadyVerified',
      component: EmailAlreadyVerified
    },

    {
      path: '/reset-password',
      name: 'ResetJelszo',
      component: ResetJelszo,
      meta: { guestOnly: true }
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      component: NotFound
    },
  ],
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition
    }
    if (to.hash) {
      return {
        el: to.hash,
        top: 100
      }
    }
    return { top: 0}
  }
})

router.beforeEach((to, from, next) => {  
  const authStore = useAuthStore()

  if (!authStore.authChecked) {
    authStore.checkAuth().then(() => next())
    return
  }

  const isLoggedIn = authStore.isAuthenticated
  const userRole = authStore.szerepkor

  if (to.name === 'ResetJelszo') {
    if (!to.query.token || !to.query.email) {
      return next({ name: 'Index' })
    }
  }

  if (to.meta.requiresAuth && !isLoggedIn) {
    return next({ name: 'Belepes', query: { redirect: to.fullPath } })
  }

  if (to.meta.guestOnly && isLoggedIn) {
    return next({ name: 'Index' })
  }

  if (to.meta.roles && !to.meta.roles.includes(userRole)) {
    return next({ name: 'NotFound' })
  }

  if ((to.name === 'NewPost' || to.name === 'EditPost') && userRole === 'felfuggesztett') {
    return next({ name: 'Index' })
  }

  next()
})
export default router