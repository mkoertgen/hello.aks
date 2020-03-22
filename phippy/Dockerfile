FROM composer:1.10.1 AS build-env
WORKDIR /app
COPY . /app/
RUN composer install

FROM php:7.4.4-zts-alpine3.11
ENV PORT 3333
EXPOSE 3333
COPY --from=build-env /app /var/www/html
RUN usermod -u 1000 www-data; \
    a2enmod rewrite; \
    chown -R www-data:www-data /var/www/html
