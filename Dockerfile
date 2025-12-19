FROM composer:2 AS vendor

WORKDIR /app

COPY . ./

RUN composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --optimize-autoloader \
    && php artisan octane:install --server=frankenphp

FROM php:8.4-cli AS frontend

WORKDIR /app

COPY --from=vendor /app ./

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash \
    && export NVM_DIR="/config/nvm" \
    && \. "$HOME/.nvm/nvm.sh" \
    && nvm install 24 \
    && npm install \
    && npm run build
    
FROM dunglas/frankenphp

WORKDIR /var/www/html

RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libpq-dev \
    unzip \
    git \
    supervisor \
    && docker-php-ext-install \
        pdo \
        pgsql \
        pdo_pgsql \
        mbstring \
        bcmath \
        pcntl \
        curl \
        zip \
    && rm -rf /var/lib/apt/lists/*
    
COPY --from=frontend /app ./

COPY docker/supervisor.conf /etc/supervisor/conf.d/octane.conf

RUN php artisan optimize

RUN chown -R www-data:www-data \
    storage bootstrap/cache \
    && chmod -R 777 storage

EXPOSE 8000

CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]