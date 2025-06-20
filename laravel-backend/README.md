# Laravel Backend for E-commerce Platform

This is the Laravel backend for the smart data-driven e-commerce platform MVP. It handles user authentication, product management, order processing, and API endpoints for the frontend.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url> e-commerce-data-driven-mvp
    cd e-commerce-data-driven-mvp/laravel-backend
    ```
2.  **Install Composer dependencies:**
    ```bash
    composer install
    ```
3.  **Copy .env file:**
    ```bash
    cp .env.example .env
    ```
    (Remember to configure your database connection in `.env`)
4.  **Generate application key:**
    ```bash
    php artisan key:generate
    ```
5.  **Run migrations:**
    ```bash
    php artisan migrate
    ```
6.  **Start the development server:**
    ```bash
    php artisan serve
    ```

## API Endpoints

Refer to `routes/api.php` for defined API endpoints.

## Database

Uses MySQL. See `database/migrations` for schema.
