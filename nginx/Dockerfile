# FROM composer:2 AS vendor

# WORKDIR /app

# COPY . ./
# RUN composer install \
#     --no-dev \
#     --prefer-dist \
#     --no-interaction \
#     --optimize-autoloader

# FROM node:25-alpine AS npm

# WORKDIR /app

# COPY --from=vendor /app ./

# RUN npm install && npm run build

FROM nginx:alpine

COPY nginx/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

COPY . ./
