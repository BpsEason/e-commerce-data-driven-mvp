<script setup>
import { ref, onMounted } from 'vue'
import { getOrders } from '../../services/orderService'

const orders = ref([])
const loading = ref(true)
const error = ref('')

onMounted(async () => {
  loading.value = true
  error.value = ''
  try {
    const data = await getOrders()
    orders.value = data
  } catch (err) {
    console.error('Error fetching orders:', err)
    error.value = err.response?.data?.message || 'Failed to load orders. Please log in or try again.'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="orders-container">
    <h2>Your Orders</h2>
    <p v-if="loading">Loading orders...</p>
    <p v-else-if="error" class="error-message">{{ error }}</p>
    <p v-else-if="orders.length === 0">You haven't placed any orders yet.</p>
    <div v-else class="order-list">
      <div v-for="order in orders" :key="order.id" class="order-card">
        <h3>Order #{{ order.id }}</h3>
        <p>Total: ${{ order.total_amount ? order.total_amount.toFixed(2) : 'N/A' }}</p>
        <p>Status: {{ order.status }}</p>
        <p>Ordered On: {{ new Date(order.created_at).toLocaleString() }}</p>
        <h4>Items:</h4>
        <ul>
          <li v-for="item in order.items" :key="item.id">
            {{ item.product ? item.product.name : 'Unknown Product' }} (x{{ item.quantity }}) - ${{ item.price ? item.price.toFixed(2) : 'N/A' }} each
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style scoped>
.orders-container {
  padding: 20px;
}
.order-list {
  display: grid;
  gap: 20px;
}
.order-card {
  border: 1px solid #ccc;
  padding: 15px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  text-align: left;
}
.order-card h3 {
  margin-top: 0;
  color: #333;
}
.order-card ul {
  list-style: disc;
  margin-left: 20px;
  padding: 0;
}
.order-card li {
  margin-bottom: 5px;
}
.error-message {
  color: red;
}
</style>
