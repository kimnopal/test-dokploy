FROM composer:2 AS vendor

WORKDIR /app

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

COPY --from=vendor /app .

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && \. "$HOME/.nvm/nvm.sh" \
    && nvm install 24 \
    && npm install \
    && npm run build


RUN chown -R www-data:www-data \
    storage bootstrap/cache

RUN php artisan optimize

EXPOSE 9000

CMD ["php-fpm"]