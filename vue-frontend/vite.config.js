import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  server: {
    host: true, // This makes the dev server accessible from outside the container
    port: 8080, // Default port for Vue dev server
  }
})
