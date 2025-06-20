<script setup>
import { defineProps } from 'vue';
import { RouterLink } from 'vue-router';

const props = defineProps({
  product: Object
});
</script>

<template>
  <div v-if="product" class="product-card">
    <img :src="product.image_url || 'https://via.placeholder.com/150'" :alt="product.name" />
    <h3><RouterLink :to="`/products/${product.id}`">{{ product.name }}</RouterLink></h3>
    <p>{{ product.description }}</p>
    <p>Price: ${{ product.price ? product.price.toFixed(2) : 'N/A' }}</p>
    <p>Stock: {{ product.stock }}</p>
    <!-- Add "Add to Cart" button -->
  </div>
</template>

<style scoped>
.product-card {
  border: 1px solid #ccc;
  padding: 15px;
  margin: 10px;
  border-radius: 8px;
  text-align: left;
  box-shadow: 2px 2px 5px rgba(0,0,0,0.1);
  display: flex;
  flex-direction: column;
}
.product-card img {
  max-width: 100%;
  height: auto;
  border-radius: 4px;
  margin-bottom: 10px;
}
h3 {
  margin-top: 0;
  font-size: 1.2em;
}
p {
  margin-bottom: 5px;
  font-size: 0.9em;
  color: #555;
}
</style>
