import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/services/api.js'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const isAuthenticated = ref(false)

  const getCsrfCookie = async () => {
    try {
      await api.get('/sanctum/csrf-cookie')
    } catch (error) {
      console.error('Failed to get CSRF cookie:', error)
    }
  }

  const checkAuth = async () => {
    try {
      await getCsrfCookie()
      
      const response = await api.get('/api/user/check')
      isAuthenticated.value = response.data.loggedIn
      user.value = response.data.user
      return response.data.loggedIn
    } catch (error) {
      console.error('Auth check failed:', error)
      isAuthenticated.value = false
      user.value = null
      return false
    }
  }

  const login = async (credentials) => {
    try {
      await getCsrfCookie()
      
      const response = await api.post('/Belepes', credentials)
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
    }
  }

  return {
    user,
    isAuthenticated,
    checkAuth,
    login,
    logout
  }
})