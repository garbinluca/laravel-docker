# Use PHP 7.2 FPM with Debian Stretch
FROM php:7.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    netcat \
    iputils-ping \
    nginx \
    supervisor \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libicu-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by Laravel and PHP 7.2
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip \
    opcache \
    intl \
    json

# Install mcrypt separately (removed from PHP 7.2 core but available via PECL)
RUN pecl install mcrypt-1.0.1 && docker-php-ext-enable mcrypt

# Install Redis extension (compatible version for PHP 7.2)
RUN pecl install redis-4.3.0 && docker-php-ext-enable redis

# Install Composer (version 1.x for better PHP 7.2 compatibility)
COPY --from=composer:1.10 /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Change current user to www
USER www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www/html

# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]