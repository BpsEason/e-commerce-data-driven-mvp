<template>
  <aside class="app-sidebar">
    <nav>
      <ul>
        <li><router-link to="/dashboard">Dashboard Overview</router-link></li>
        <li><router-link to="/products">Browse Products</router-link></li>
        <li><router-link to="/orders">My Orders</router-link></li>
        <!-- Add more links for admin/user functionality -->
      </ul>
    </nav>
  </aside>
</template>

<style scoped>
.app-sidebar {
  width: 200px;
  background-color: #f0f0f0;
  padding: 20px;
  height: 100vh; /* Full height */
  box-sizing: border-box;
}
ul {
  list-style: none;
  padding: 0;
}
li {
  margin-bottom: 10px;
}
a {
  text-decoration: none;
  color: #333;
  font-weight: bold;
}
a:hover {
  color: #42b983;
}
</style>
