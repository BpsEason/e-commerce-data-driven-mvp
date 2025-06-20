<script setup>
import { ref } from 'vue'
import { useRouter, RouterLink } from 'vue-router'
import { registerUser } from '../../services/authService'

const name = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const error = ref('')
const router = useRouter()

const handleSubmit = async () => {
  error.value = ''
  if (password.value !== passwordConfirmation.value) {
    error.value = 'Passwords do not match.'
    return
  }
  try {
    const response = await registerUser({
      name: name.value,
      email: email.value,
      password: password.value,
      password_confirmation: passwordConfirmation.value
    })
    localStorage.setItem('authToken', response.access_token)
    localStorage.setItem('user', JSON.stringify(response.user))
    router.push('/dashboard') // Redirect on successful registration
  } catch (err) {
    console.error('Registration error:', err)
    error.value = err.response?.data?.message || 'Registration failed. Please try again.'
  }
}
</script>

<template>
  <div class="auth-container">
    <h2>Register</h2>
    <form @submit.prevent="handleSubmit">
      <p v-if="error" class="error-message">{{ error }}</p>
      <div>
        <label for="name">Name:</label>
        <input type="text" id="name" v-model="name" required />
      </div>
      <div>
        <label for="email">Email:</label>
        <input type="email" id="email" v-model="email" required />
      </div>
      <div>
        <label for="password">Password:</label>
        <input type="password" id="password" v-model="password" required />
      </div>
      <div>
        <label for="password_confirmation">Confirm Password:</label>
        <input type="password" id="password_confirmation" v-model="passwordConfirmation" required />
      </div>
      <button type="submit">Register</button>
    </form>
    <p>Already have an account? <RouterLink to="/login">Login here</RouterLink></p>
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
