# Laravel 10.10 Docker Setup Instructions

## Project Structure
Create the following directory structure in your Laravel project root:

```
your-laravel-project/
├── docker/
│   ├── nginx/
│   │   └── nginx.conf
│   ├── php/
│   │   └── local.ini
│   └── mysql/
│       └── my.cnf
├── docker-compose.yml
├── Dockerfile
└── [your Laravel files]
```

## Useful Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f app

# Install Composer dependencies
docker-compose run --rm composer install

# Install new Composer packages
docker-compose run --rm composer require [package]

# Build assets (if using Laravel Mix/Vite)
docker-compose run --rm node npm run build

# Access application container
docker-compose exec app bash

# Generate application key
docker-compose exec app php artisan key:generate

# Run Artisan commands
docker-compose exec app php artisan [command]

## Setup Steps

### 1. Create the Docker configuration files
Copy all the provided configuration files to their respective locations as shown in the project structure above.

### 2. Build and start the containers
```bash
# Build and start all services
docker-compose up -d --build

# Check if containers are running
docker-compose ps
```

### 3. Install Laravel dependencies
```bash
# Install Composer dependencies
docker-compose run --rm composer install

# Install Node.js dependencies (if using Laravel Mix/Vite)
docker-compose run --rm node npm install
```

### 4. Configure Laravel environment
```bash
# Copy environment file
cp .env.example .env

# Generate application key
docker-compose exec app php artisan key:generate

# Update .env with database credentials:
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel_user
DB_PASSWORD=laravel_password

# Optional: Add Redis configuration
REDIS_HOST=redis
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### 5. Run database migrations
```bash
# Run migrations
docker-compose exec app php artisan migrate

# Seed database (optional)
docker-compose exec app php artisan db:seed
```

### 6. Set proper permissions
```bash
# Set storage and cache permissions
docker-compose exec app chmod -R 777 storage/
docker-compose exec app chmod -R 777 bootstrap/cache/
```

## Access Points

- **Application**: http://localhost:8080
- **MySQL**: localhost:3306 (accessible from host for database tools)
- **Redis**: localhost:6379

## Database Persistence

The MySQL data is persisted using a Docker volume named `mysql_data`. This means:
- Data survives container restarts
- Data is stored on your local machine
- To completely reset the database: `docker-compose down -v` (removes volumes)

## Best Practices Implemented

1. **Volume Mounting**: Application code is mounted as a volume for easy development
2. **Multi-stage Build**: Optimized Dockerfile with proper layer caching
3. **Security**: Non-root user, proper file permissions
4. **Performance**: OPcache enabled, MySQL tuned for development
5. **Development Tools**: Composer and Node containers for package management
6. **Network Isolation**: Services communicate through a dedicated network
7. **Health Checks**: Dependencies properly managed with `depends_on`

## M1 Mac Compatibility

This setup is optimized for Apple Silicon (M1/M2) MacBooks:
- Uses multi-architecture images where available
- MySQL 8.0 has native ARM64 support
- PHP 8.1 FPM runs natively on ARM64
- Nginx Alpine image supports ARM64

## Troubleshooting

- If containers fail to start, check logs: `docker-compose logs`
- For permission issues: `docker-compose exec app chown -R www:www /var/www/html`
- To reset everything: `docker-compose down -v && docker-compose up -d --build`
