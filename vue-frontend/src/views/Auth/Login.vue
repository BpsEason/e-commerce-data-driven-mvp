<script setup>
import { ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { loginUser } from '../../services/authService'

const email = ref('')
const password = ref('')
const error = ref('')
const router = useRouter()

const handleSubmit = async () => {
  error.value = ''
  try {
    const response = await loginUser({ email: email.value, password: password.value })
    localStorage.setItem('authToken', response.access_token)
    localStorage.setItem('user', JSON.stringify(response.user))
    router.push('/dashboard') // Redirect to dashboard on successful login
  } catch (err) {
    console.error('Login error:', err)
    error.value = err.response?.data?.message || 'Login failed. Please check your credentials.'
  }
}
</script>

<template>
  <div class="auth-container">
    <h2>Login</h2>
    <form @submit.prevent="handleSubmit">
      <p v-if="error" class="error-message">{{ error }}</p>
      <div>
        <label for="email">Email:</label>
        <input type="email" id="email" v-model="email" required />
      </div>
      <div>
        <label for="password">Password:</label>
        <input type="password" id="password" v-model="password" required />
      </div>
      <button type="submit">Login</button>
    </form>
    <p>Don't have an account? <RouterLink to="/register">Register here</RouterLink></p>
  </div>
</template>

<style scoped>
.auth-container {
  max-width: 400px;
  margin: 50px auto;
  padding: 20px;
  border: 1px solid #eee;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
form div {
  margin-bottom: 15px;
}
label {
  display: block;
  margin-bottom: 5px;
  font-weight: bold;
}
input[type="email"],
input[type="password"],
input[type="text"] {
  width: 100%;
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
}
button {
  background-color: #42b983;
  color: white;
  padding: 10px 15px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1em;
}
button:hover {
  background-color: #36a374;
}
.error-message {
  color: red;
  margin-bottom: 10px;
}
</style>
