import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api.js'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const isAuthenticated = ref(false)
  const authChecked = ref(false)
  const szerepkor = ref(null)

  const getCsrfCookie = async () => {
    try {
      await api.get('/sanctum/csrf-cookie')
    } catch (error) {
      console.error('Failed to get CSRF cookie:', error)
    }
  }


  const checkAuth = async () => {
    try {
      const response = await api.get('/api/user/check')
      isAuthenticated.value = response.data.loggedIn
      szerepkor.value = response.data.szerepkor ?? null
      user.value = response.data.user
      return response.data.loggedIn
    } catch (error) {
      isAuthenticated.value = false
      user.value = null
      return false
    } finally {
      authChecked.value = true 
    }
  }

  const login = async (credentials) => {
    try {
      await getCsrfCookie()
      
      const response = await api.post('/login', credentials)
      if (response.data.success) {
        await checkAuth()
        return true
      }
      return false
    } catch (error) {
      console.error('Login failed:', error)
      return false
    }
  }

  const logout = async () => {
    try {
      await api.post('/logout')
    } catch (error) {
      console.error('Logout failed:', error)
    } finally {
      isAuthenticated.value = false
      user.value = null
      szerepkor.value = null
    }
  }

  return {
    user,
    szerepkor,
    isAuthenticated,
    authChecked,
    checkAuth,
    login,
    logout
  }
})