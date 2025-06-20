<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, RouterLink } from 'vue-router'
import { getProductById } from '../../services/productService'
import { getProductRecommendations } from '../../services/dataAnalysisService'

const route = useRoute()
const productId = route.params.id

const product = ref(null)
const recommendations = ref([])
const loading = ref(true)
const error = ref('')

onMounted(async () => {
  loading.value = true
  error.value = ''
  try {
    const productData = await getProductById(productId)
    product.value = productData

    // Fetch product recommendations from Python backend
    const recs = await getProductRecommendations(productId)
    recommendations.value = recs
  } catch (err) {
    console.error('Error fetching product or recommendations:', err)
    error.value = err.response?.data?.message || 'Failed to load product details or recommendations.'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="product-detail-container">
    <p v-if="loading">Loading product details...</p>
    <p v-else-if="error" class="error-message">{{ error }}</p>
    <p v-else-if="!product">Product not found.</p>
    <div v-else class="product-info">
      <img :src="product.image_url || 'https://via.placeholder.com/300'" :alt="product.name" />
      <h2>{{ product.name }}</h2>
      <p>{{ product.description }}</p>
      <p><strong>Price: ${{ product.price.toFixed(2) }}</strong></p>
      <p>Stock: {{ product.stock }}</p>
      <p>Category: {{ product.category }}</p>
      <!-- Add "Add to Cart" button or quantity selector -->
    </div>

    <section class="related-products">
      <h3>Related Products (from Python Backend)</h3>
      <p v-if="loading">Loading related products...</p>
      <p v-else-if="recommendations.length > 0" class="product-recommendations-grid">
        <div v-for="rec in recommendations" :key="rec.id" class="recommendation-card">
          <h4>{{ rec.name }}</h4>
          <p>Price: ${{ rec.price.toFixed(2) }}</p>
          <p>Similarity: {{ rec.score.toFixed(2) }}</p>
          <RouterLink :to="`/products/${rec.id}`">View Details</RouterLink>
        </div>
      </p>
      <p v-else>No related products found.</p>
    </section>
  </div>
</template>

<style scoped>
.product-detail-container {
  padding: 20px;
}
.product-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 30px;
}
.product-info img {
  max-width: 300px;
  height: auto;
  margin-bottom: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}
.related-products {
  margin-top: 30px;
  border-top: 1px solid #eee;
  padding-top: 20px;
}
.product-recommendations-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
}
.recommendation-card {
  border: 1px solid #ddd;
  padding: 10px;
  border-radius: 6px;
  text-align: left;
}
.error-message {
  color: red;
}
</style>
