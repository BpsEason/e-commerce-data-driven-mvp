<script setup>
import { ref, onMounted } from 'vue'
import { getSalesTrends, getUserRecommendations } from '../../services/dataAnalysisService'
import Sidebar from '../../components/Sidebar.vue'

const salesTrends = ref([])
const userRecommendations = ref([])
const loading = ref(true)
const error = ref('')
const currentUser = ref(null)

onMounted(async () => {
  currentUser.value = JSON.parse(localStorage.getItem('user'))
  loading.value = true
  error.value = ''
  try {
    // Fetch sales trends from Python backend
    const trends = await getSalesTrends()
    salesTrends.value = trends

    // Fetch user recommendations from Python backend (if user is logged in)
    if (currentUser.value && currentUser.value.id) {
      const recommendations = await getUserRecommendations(currentUser.value.id)
      userRecommendations.value = recommendations
    }
  } catch (err) {
    console.error('Dashboard data fetch error:', err)
    error.value = err.response?.data?.message || 'Failed to load dashboard data. Please try again.'
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="dashboard-container">
    <Sidebar />
    <div class="dashboard-content">
      <h2>Welcome to Your Dashboard, {{ currentUser ? currentUser.name : 'Guest' }}!</h2>

      <section class="sales-trends">
        <h3>Sales Trends (from Python Backend)</h3>
        <p v-if="loading">Loading sales trends...</p>
        <p v-else-if="error" class="error-message">{{ error }}</p>
        <ul v-else-if="salesTrends.length > 0">
          <li v-for="(trend, index) in salesTrends" :key="index">
            Date: {{ trend.date }}, Sales: ${{ trend.daily_sales.toFixed(2) }}
          </li>
        </ul>
        <p v-else>No sales trend data available.</p>
      </section>

      <section class="user-recommendations">
        <h3>Recommended Products for You (from Python Backend)</h3>
        <p v-if="loading">Loading recommendations...</p>
        <p v-else-if="error" class="error-message">{{ error }}</p>
        <div v-else-if="userRecommendations.length > 0" class="product-recommendations-grid">
          <div v-for="product in userRecommendations" :key="product.id" class="recommendation-card">
            <h4>{{ product.name }}</h4>
            <p>{{ product.description }}</p>
            <p>Price: ${{ product.price.toFixed(2) }}</p>
            <p>Relevance Score: {{ product.score.toFixed(2) }}</p>
          </div>
        </div>
        <p v-else>No personalized recommendations available at the moment. Explore more products!</p>
      </section>

      <!-- Add more dashboard widgets here (e.g., recent orders, popular products from Laravel) -->
    </div>
  </div>
</template>

<style scoped>
.dashboard-container {
  display: flex;
}
.dashboard-content {
  flex-grow: 1;
  padding: 20px;
}
section {
  background-color: #fff;
  padding: 20px;
  margin-bottom: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
ul {
  list-style: none;
  padding: 0;
}
li {
  padding: 5px 0;
  border-bottom: 1px dotted #eee;
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
