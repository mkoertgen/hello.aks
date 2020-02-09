FROM composer:1.9.3 AS build-env
WORKDIR /app
COPY . /app/
RUN composer install

FROM php:7.4.2-apache-buster
ENV PORT 3333
EXPOSE 3333
COPY --from=build-env /app /var/www/html
RUN usermod -u 1000 www-data; \
    a2enmod rewrite; \
    chown -R www-data:www-data /var/www/html
