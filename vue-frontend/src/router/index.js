import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import LoginView from '../views/Auth/Login.vue'
import RegisterView from '../views/Auth/Register.vue'
import DashboardView from '../views/Dashboard/Dashboard.vue'
import ProductListView from '../views/Products/ProductList.vue'
import ProductDetailView from '../views/Products/ProductDetail.vue'
import OrderListView from '../views/Orders/OrderList.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView
    },
    {
      path: '/login',
      name: 'login',
      component: LoginView
    },
    {
      path: '/register',
      name: 'register',
      component: RegisterView
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: DashboardView,
      meta: { requiresAuth: true } // Example meta field for auth guard
    },
    {
      path: '/products',
      name: 'products',
      component: ProductListView
    },
    {
      path: '/products/:id',
      name: 'productDetail',
      component: ProductDetailView,
      props: true // Pass route params as props to component
    },
    {
      path: '/orders',
      name: 'orders',
      component: OrderListView,
      meta: { requiresAuth: true }
    }
  ]
})

// Navigation guard example (basic authentication check)
router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth && !localStorage.getItem('authToken')) {
    next('/login') // Redirect to login if not authenticated
  } else {
    next() // Proceed
  }
})

export default router
