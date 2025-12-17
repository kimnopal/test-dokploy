FROM node:25-alpine AS npm

WORKDIR /app

COPY . ./
RUN npm install && npm run build

FROM nginx:alpine

COPY default.conf /etc/nginx/conf.d/default.conf

WORKDIR /var/www/html

COPY . ./

COPY --from=npm /app/public/build ./public/build
