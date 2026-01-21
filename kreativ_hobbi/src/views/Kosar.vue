<template>
  <div class="cart-page">
    <h2>Your Cart</h2>
    <div v-if="cartItems.length > 0" class="cart-container">
      <div class="cart-items">
      <div v-for="item in cartItems" :key="item.id" class="cart-item">
        <img :src="item.image" :alt="item.name" class="cart-item-image" />
        <div class="cart-item-info">
          <h3>{{ item.name }}</h3>
          <p>Price: ${{ item.price }}</p>
          <p>Quantity: 
            <button
              class="button2"
              id="jobb"
              @click="decreaseFromCart(item.id)"
              :disabled="item.quantity <= 1"
            >-</button>
            <input 
              type="number"
              :min="1"
              :max="item.quantity"
              class="number"
              v-model.number="item.quantity"
              @input="updateQuantity(item.id, $event.target.value)"
            >
            <button
              class="button2"
              id="bal"
              @click="addToCart(item, 1)"
              :disabled="productStock(item.id) <= 1"
            >+</button>
          </p>
          <p>Total: ${{ (item.price * item.quantity).toFixed(2) }}</p>
          <button @click="removeFromCart(item.id)" class="remove">Remove</button>
        </div>
      </div>
      </div>
      <div class="cart-summary">
    <div class="cart-summary">
      <h2>Cart Summary</h2>
      <p class="total-price">Items: {{ cartItems.reduce((total, item) => total + item.quantity, 0) }}</p>
      <p class="total-price">Total: ${{ cartTotal }}</p>

      <!-- Delivery Information Form -->
      <div class="delivery-form">
        <h3>Delivery Information</h3>
        <form @submit.prevent="handleSubmit">
          <div class="form-group">
            <label for="fullName">Full Name:</label>
            <input 
              type="text" 
              id="fullName" 
              v-model="deliveryDetails.fullName" 
              required
            >
          </div>

          <div class="form-group">
            <label for="email">Email:</label>
            <input 
              type="email" 
              id="email" 
              v-model="deliveryDetails.email" 
              required
            >
          </div>

          <div class="form-group">
            <label for="address">Street Address:</label>
            <input 
              type="text" 
              id="address" 
              v-model="deliveryDetails.address" 
              required
            >
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="city">City:</label>
              <input 
                type="text" 
                id="city" 
                v-model="deliveryDetails.city" 
                required
              >
            </div>

            <div class="form-group">
              <label for="zipCode">ZIP Code:</label>
              <input 
                type="text" 
                id="zipCode" 
                v-model="deliveryDetails.zipCode" 
                required
                pattern="\d{4,5}"
              >
            </div>
          </div>

          <div class="form-group">
            <label for="phone">Phone Number:</label>
            <input 
              type="tel" 
              id="phone" 
              v-model="deliveryDetails.phone" 
              required
              pattern="[0-9]{9,11}"
            >
          </div>
        </form>
      </div>

      <button @click="checkout" id="checkout">Checkout</button>
      <button @click="emptyCart(false)" id="emptyCart">Empty Cart</button>
    </div>
  </div>
    </div>
    <p v-else>Your cart is currently empty. <br> Browse our shop to find amazing products and add them to your cart. <br> Once you've added items, they'll appear here for checkout!</p>
  </div>
</template>

<script setup>

</script>

<style scoped>

/* Delivery Form Styling */
.delivery-form {
  margin: 25px 0;
  padding: 25px;
  border: 1px solid #e0e0e0;
  border-radius: 12px;
  background: #ffffff;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  
}

.delivery-form h3 {
  margin: 0 0 25px 0;
  color: #2c3e50;
  font-size: 1.4rem;
  font-weight: 600;
  border-bottom: 2px solid #f0f0f0;
  padding-bottom: 15px;
}

.form-group {
  margin-bottom: 20px;
  text-align: left;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #4a5568;
  font-size: 0.95rem;
}

.form-group input {
  width: 90%;
  padding: 10px 15px;
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: #f8fafc;
}

.form-group input:focus {
  outline: none;
  border-color: #439a57;
  background: #ffffff;
  box-shadow: 0 0 0 3px rgba(67, 154, 87, 0.1);
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

/* Validation Styles */
.form-group input:invalid:not(:focus):not(:placeholder-shown) {
  border-color: #fc8181;
}

.form-group input:invalid:not(:focus):not(:placeholder-shown) + .error-message {
  display: block;
}

/* Button Container */
.checkout-actions {
  margin-top: 25px;
  display: flex;
  gap: 15px;
  justify-content: space-between;
}

/* Enhanced Checkout Button */
#checkout {
  background-color: #439a57;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 12px 25px;
  font-size: 1.1rem;
  font-weight: 600;
  transition: all 0.3s ease;
  flex-grow: 1;
}

#checkout:hover {
  background-color: #218838;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(33, 136, 56, 0.2);
}

#checkout:active {
  transform: translateY(0);
}

/* Empty Cart Button */
#emptyCart {
  background-color: #c24653;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 12px 25px;
  font-size: 1.1rem;
  transition: all 0.3s ease;
}

#emptyCart:hover {
  background-color: #c82333;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(200, 35, 51, 0.2);
}

@media (max-width: 768px) {
  .cart-container {
    flex-direction: column;
  }
  
  .cart-items,
  .cart-summary {
    min-width: 100%;
    max-width: 100%;
  }
}

@media (max-width: 768px) {
  .delivery-form {
    padding: 20px;
  }
  
  .form-row {
    grid-template-columns: 1fr;
    gap: 15px;
  }
  
  .checkout-actions {
    flex-direction: column;
  }
  
  #checkout,
  #emptyCart {
    width: 100%;
  }
}

/* Matching Existing Cart Style */
.delivery-form {
  background-color: #f6f6f6;
  border-color: #ddd;
}

.delivery-form h3 {
  color: #2c3e50;
  text-shadow: none;
}

.form-group input {
  border-color: #cbd5e0;
}

.form-group input:focus {
  border-color: #2c3e50;
}
/* Add/update these styles */
.button2 {
  padding: 5px 12px;
  background-color: #ffffff;
  border: 1px solid #575656;
  cursor: pointer;
  transition: all 0.3s;
  font-weight: 500;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.button2:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  background-color: #f0f0f0;
}

.button2:active:not(:disabled) {
  transform: scale(0.95);
  box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
  background-color: #d0d0d0;
  transition: all 0.1s ease;
}

.number {
  -moz-appearance: textfield;
  -webkit-appearance: none;
  appearance: none;
  width: 60px;
  text-align: center;
  margin: 0 5px;
  padding: 5px;
  border: 1px solid #000000;
  border-radius: 4px;
}

.number::-webkit-inner-spin-button,
.number::-webkit-outer-spin-button {
  -webkit-appearance: none;
  margin: 0;
}

#bal {
  border-radius: 0px 10px 10px 0px;
}

#jobb {
  border-radius: 10px 0px 0px 10px;
  padding: 5px 14px;
  font-weight: 700;
}

/* Update existing button styles to match */
.remove, #checkout, #emptyCart {
  border-radius: 20px;
  transition: all 0.2s ease;
}

.remove:hover, #checkout:hover, #emptyCart:hover {
  transform: translateY(-1px);
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.15);
}


.cart-page {
  display: flex;
  flex-direction: column;
  align-items: center; /* Center content horizontally */
  justify-content: center; /* Center content vertically */
  text-align: center; /* Center text */
  padding: 20px;
}

.cart-item {
  display: flex;
  align-items: center; /* Center items vertically */
  justify-content: center; /* Center items horizontally */
  margin-bottom: 20px;
  width: 90%; /* Adjust width for better alignment */
  border: 1px solid #ddd;
  padding: 10px;
  border-radius: 8px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
  background-color: #f6f6f6;
}

.cart-item-image {
  width: 100px;
  margin-right: 20px;
}

.cart-item-info {
  flex: 1;
  text-align: left; /* Align text to the left inside the item */
}

button {
  margin-top: 10px;
}

.cart-page h2 {
  margin-bottom: 20px;
  font-size: 24px;
  font-weight: bold;
}

.cart-page {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.cart-page h2 {
  margin-bottom: 20px;
  font-size: 24px;
  font-weight: bold;
  text-align: center;
  margin-left: 30px;
}

.cart-container {
  display: flex;
  gap: 60px;
  width: 100%;
}

.cart-items {
  flex: 1;
  min-width: 400px;
}

.cart-summary {
  flex: 1;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
  height: fit-content;
  position: sticky;
  top: 20px;
  background-color: #f6f6f6;
  text-align: center;
  min-width: 400px; /* Set a minimum width for the form */
  max-width: 600px; /* Set a maximum width if needed */
}

.cart-item {
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  border: 1px solid #ddd;
  padding: 10px;
  border-radius: 8px;
  box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.cart-item-image {
  width: 100px;
  margin-right: 20px;
}

.cart-item-info {
  flex: 1;
  text-align: left;
}

.plus, .minus {
  cursor: pointer;
  background-color: #656565;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 5px 10px;
}

.remove {
  cursor: pointer;
  background-color: #5f3535;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 18px;
}

.total-price {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 20px;
}

#checkout {
  background-color: #439a57;
  margin-right: 10px;
  cursor: pointer;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 18px;
}

#checkout:hover {
  background-color: #218838;
}

#emptyCart {
  background-color: #c24653;
  cursor: pointer;
  color: white;
  border: none;
  border-radius: 4px;
  padding: 8px 18px;
}

#emptyCart:hover {
  background-color: #c82333;
}
</style>
