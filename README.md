# PHP 7.2 Docker Environment Setup Guide

## Key Changes for PHP 7.2 Compatibility

### Technology Stack
- **PHP 7.2-FPM** (instead of 8.1)
- **MySQL 5.7** (instead of 8.0) - better compatibility with older Laravel versions
- **Composer 1.10** (better PHP 7.2 support)
- **Node.js 12** (compatible with older build tools)
- **Redis 5** (stable version for PHP 7.2)

### Laravel Version Compatibility

**PHP 7.2 supports:**
- Laravel 5.5 LTS
- Laravel 5.6
- Laravel 5.7
- Laravel 5.8
- Laravel 6.0 LTS (with some configurations)

**Note:** Laravel 10.10 requires PHP 8.1+, so you'll need to use an older Laravel version with PHP 7.2.

## Setup Instructions

### 1. Project Structure
Create the following directory structure:

```
your-laravel-project/
├── docker/
│   ├── nginx/
│   │   └── nginx.conf (use the same as PHP 8.1 version)
│   ├── php/
│   │   └── local.ini
│   └── mysql/
│       └── my.cnf
├── docker-compose.yml
├── Dockerfile
└── [your Laravel files]
```

### 2. Build and Start Containers

```bash
# Build and start all services
docker-compose up -d --build

# Check container status
docker-compose ps
```

### 3. Install Laravel Dependencies

**For existing Laravel 5.x project:**
```bash
# Install Composer dependencies
docker-compose run --rm composer install

# Install Node.js dependencies
docker-compose run --rm node npm install
```

**For new Laravel 5.8 project:**
```bash
# Create new Laravel 5.8 project
docker-compose run --rm composer create-project --prefer-dist laravel/laravel:5.8.* .

# Install Node dependencies
docker-compose run --rm node npm install
```

### 4. Configure Environment

```bash
# Copy environment file
cp .env.example .env

# Generate application key
docker-compose exec app php artisan key:generate

# Update .env with database credentials:
```

```env
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8080

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel_user
DB_PASSWORD=laravel_password

BROADCAST_DRIVER=log
CACHE_DRIVER=redis
QUEUE_CONNECTION=sync
SESSION_DRIVER=redis
SESSION_LIFETIME=120

REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_DRIVER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
```

### 5. Run Database Migrations

```bash
# Run migrations
docker-compose exec app php artisan migrate

# Seed database (optional)
docker-compose exec app php artisan db:seed
```

### 6. Set Permissions

```bash
# Set storage and cache permissions
docker-compose exec app chmod -R 777 storage/
docker-compose exec app chmod -R 777 bootstrap/cache/
```

## PHP 7.2 Specific Configurations

### Extensions Included
- **mcrypt**: Installed via PECL (removed from PHP 7.2 core)
- **json**: Explicitly enabled
- **gd**: Configured with freetype and jpeg support
- **redis**: Version 4.3.0 (compatible with PHP 7.2)
- **opcache**: For performance optimization
- **intl**: For internationalization

### Compatibility Notes

**1. mcrypt Extension:**
```php
// Still available in PHP 7.2 via PECL
if (extension_loaded('mcrypt')) {
    // mcrypt functions available
    $encrypted = mcrypt_encrypt(MCRYPT_RIJNDAEL_256, $key, $data, MCRYPT_MODE_ECB);
}
```

**2. MySQL 5.7 Features:**
- Query cache available (disabled in MySQL 8.0)
- Traditional SQL modes supported
- Better compatibility with older Laravel versions

**3. Composer Version:**
```bash
# Using Composer 1.10 for better PHP 7.2 compatibility
docker-compose run --rm composer --version
# Composer version 1.10.x
```

## Development Workflow

### Common Commands

```bash
# Start development environment
docker-compose up -d

# View logs
docker-compose logs -f app nginx mysql

# Run Artisan commands
docker-compose exec app php artisan migrate
docker-compose exec app php artisan tinker
docker-compose exec app php artisan queue:work

# Install new packages
docker-compose run --rm composer require vendor/package

# Build assets (Laravel Mix)
docker-compose run --rm node npm run dev
docker-compose run --rm node npm run watch
docker-compose run --rm node npm run production
```

### Database Access

Same as PHP 8.1 setup:
- **Host:** localhost
- **Port:** 3306
- **Database:** laravel
- **Username:** laravel_user
- **Password:** laravel_password

## Performance Optimizations

### OPcache Settings
```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=4000
opcache.revalidate_freq=2
```

### MySQL 5.7 Query Cache
```ini
query_cache_type = 1
query_cache_size = 32M
query_cache_limit = 2M
```

### Redis Configuration
```env
CACHE_DRIVER=redis
SESSION_DRIVER=redis
REDIS_HOST=redis
```

## Troubleshooting

### 1. mcrypt Issues
```bash
# Check if mcrypt is loaded
docker-compose exec app php -m | grep mcrypt

# If missing, rebuild container
docker-compose build --no-cache app
```

### 2. Composer Memory Issues
```bash
# Increase Composer memory limit
docker-compose run --rm composer install --no-dev --optimize-autoloader

# Or set memory limit
docker-compose run --rm -e COMPOSER_MEMORY_LIMIT=-1 composer install
```

### 3. Node.js Version Issues
```bash
# Check Node version
docker-compose run --rm node node --version
# Should show v12.x.x

# Update package.json for compatibility
docker-compose run --rm node npm audit fix
```

### 4. Laravel Version Compatibility

**For Laravel 5.8:**
```json
{
    "require": {
        "php": "^7.1.3",
        "laravel/framework": "5.8.*"
    }
}
```

**For Laravel 6.0 LTS:**
```json
{
    "require": {
        "php": "^7.2",
        "laravel/framework": "^6.0"
    }
}
```

## Migration from PHP 8.1 to 7.2

### 1. Backup Current Data
```bash
# Export database
docker-compose exec mysql mysqldump -u root -proot_password laravel > backup.sql
```

### 2. Update Codebase
- Downgrade Laravel version if needed
- Update composer.json requirements
- Check for PHP 8.x specific syntax

### 3. Switch Docker Environment
```bash
# Stop current environment
docker-compose down

# Use PHP 7.2 docker-compose.yml
# Build new environment
docker-compose up -d --build

# Restore database
docker-compose exec -T mysql mysql -u root -proot_password laravel < backup.sql
```

## Security Considerations

### PHP 7.2 Security
- Use latest PHP 7.2.x patch version
- Keep extensions updated
- Monitor security advisories

### MySQL 5.7 Security
```sql
-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Secure root account
ALTER USER 'root'@'localhost' IDENTIFIED BY 'strong_password';
```

This PHP 7.2 environment provides a stable, compatible setup for older Laravel applications while maintaining modern containerization benefits!