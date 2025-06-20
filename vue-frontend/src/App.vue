<script setup>
import { RouterView } from 'vue-router'
import Header from './components/Header.vue'
</script>

<template>
  <Header />
  <nav>
    <RouterLink to="/">Home</RouterLink>
    <RouterLink to="/products">Products</RouterLink>
    <RouterLink to="/orders">Orders</RouterLink>
    <RouterLink to="/dashboard">Dashboard</RouterLink>
    <RouterLink to="/login">Login</RouterLink>
    <RouterLink to="/register">Register</RouterLink>
  </nav>

  <main class="main-content">
    <RouterView />
  </main>
</template>

<style>
/* Basic styling for demonstration */
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
nav {
  padding: 30px;
}
nav a {
  font-weight: bold;
  color: #2c3e50;
  margin: 0 15px;
}
nav a.router-link-exact-active {
  color: #42b983;
}
</style>
