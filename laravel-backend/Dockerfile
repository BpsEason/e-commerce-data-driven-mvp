FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    nginx \
    mysql-client \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    oniguruma-dev \
    libxml2-dev \
    # Added redis-dev for Redis extension
    redis-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd opcache zip \
    # Install Redis PHP extension
    && pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/local/bin/composer

# Copy existing application dependencies (composer.json and composer.lock)
# It's good practice to copy these first to leverage Docker cache
COPY composer.json composer.lock ./

# Install Composer dependencies
# Use --no-dev and --optimize-autoloader for production builds
# For development, you might remove --no-dev
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy the rest of the application
COPY . .

# Run Laravel specific commands (e.g., storage link, permissions)
RUN php artisan storage:link && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Command to run PHP-FPM
CMD ["php-fpm"]
