FROM composer:2 AS vendor

WORKDIR /app

COPY composer.json composer.lock ./
COPY . .
RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --optimize-autoloader

FROM php:8.4-fpm

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install \
        pdo \
        pgsql \
        pdo_pgsql \
        mbstring \
        bcmath \
        curl \
        zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=vendor /app/vendor ./vendor

COPY . .

RUN chown -R www-data:www-data \
    storage bootstrap/cache

RUN php artisan optimize

EXPOSE 9000

CMD ["php-fpm"]