import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useCartStore = defineStore('cart', () => {
  const cartItems = ref([])

  const cartTotal = computed(() => {
    return cartItems.value.reduce((sum, item) => sum + (Number(item.ar || item.price) * Number(item.quantity || 1)), 0)
  })

  function addToCart(item, quantity = 1) {
    const stock = item.darab || item.stock || 0
    const existing = cartItems.value.find(i => i.id === item.id)
    
    if (existing) {
      // Már van a kosárban, ellenőrizni, hogy lehet-e még hozzáadni
      const currentTotal = existing.quantity + quantity
      if (currentTotal > stock) {
        // Túllépné a limitet
        const canAdd = stock - existing.quantity
        if (canAdd <= 0) {
          return {
            success: false,
            message: `Már a maximum mennyiséget (${stock} db) hozzáadtad ebből a termékből!`,
            added: 0
          }
        }
        // Csak annyit adunk hozzá, amennyit még lehet
        existing.quantity = stock
        return {
          success: true,
          message: `Csak még ${canAdd} db adható hozzá. Hozzáadva: ${canAdd} db`,
          added: canAdd
        }
      }
      // Normal hozzáadás
      existing.quantity += quantity
      return {
        success: true,
        message: `${quantity} db hozzáadva`,
        added: quantity
      }
    } else {
      // Nem volt a kosárban, normál hozzáadás
      if (quantity > stock) {
        return {
          success: false,
          message: `Csak ${stock} db van raktáron!`,
          added: 0
        }
      }
      cartItems.value.push({
        ...item,
        quantity: quantity
      })
      return {
        success: true,
        message: `${quantity} db hozzáadva`,
        added: quantity
      }
    }
  }

  function removeFromCart(id) {
    const idx = cartItems.value.findIndex(i => i.id === id)
    if (idx !== -1) cartItems.value.splice(idx, 1)
  }

  function updateQuantity(id, quantity) {
    const item = cartItems.value.find(i => i.id === id)
    if (item) item.quantity = Math.max(1, quantity)
  }

  function clearCart() {
    cartItems.value = []
  }

  return {
    cartItems,
    cartTotal,
    addToCart,
    removeFromCart,
    updateQuantity,
    clearCart
  }
})
