<script setup>
import { ref, onMounted } from 'vue'
import ProductCard from '../../components/ProductCard.vue'
import { getProducts } from '../../services/productService'

const products = ref([])
const loading = ref(true)
const error = ref('')

onMounted(async () => {
  loading.value = true
  error.value = ''
  try {
    const data = await getProducts()
    products.value = data
  } catch (err) {
    console.error('Error fetching products:', err)
    error.value = err.response?.data?.message || 'Failed to load products. Please try again later.'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="product-list-container">
    <h2>All Products</h2>
    <p v-if="loading">Loading products...</p>
    <p v-else-if="error" class="error-message">{{ error }}</p>
    <p v-else-if="products.length === 0">No products available.</p>
    <div v-else class="product-grid">
      <ProductCard v-for="product in products" :key="product.id" :product="product" />
    </div>
  </div>
</template>

<style scoped>
.product-list-container {
  padding: 20px;
}
.product-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 20px;
}
.error-message {
  color: red;
}
</style>
