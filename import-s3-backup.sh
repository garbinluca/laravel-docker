#!/bin/bash

# Script to download the latest backup from S3 and restore it to the local database
# Usage: ./s3_mysql_restore.sh BUCKET_NAME DATABASE_NAME [DATABASE_USER] [DATABASE_PASSWORD]

# Path to XAMPP MySQL - Modify this path if necessary
XAMPP_MYSQL="/Applications/XAMPP/xamppfiles/bin/mysql"

# Check if XAMPP MySQL exists
if [ ! -f "$XAMPP_MYSQL" ]; then
    echo "Error: XAMPP MySQL not found at $XAMPP_MYSQL"
    echo "Modify the XAMPP_MYSQL path in the script."
    exit 1
fi

S3_BUCKET="xxx"
DB_NAME="projectname_local"
DB_USER="root"
DB_PASS="root"
S3_PROFILE="default"

# Temporary directory for download
TEMP_DIR="."
mkdir -p "$TEMP_DIR"

echo "=== Starting database restore process ==="
echo "S3 Bucket: $S3_BUCKET"
echo "Target database: $DB_NAME"
echo "MySQL user: $DB_USER"

# 1. Find and download the latest backup file from S3
echo "Searching for the latest available backup..."
LATEST_BACKUP=$(aws s3 ls "s3://$S3_BUCKET/" --profile $S3_PROFILE | grep ".sql" | sort -r | /usr/bin/head -n 1 | awk '{print $4}')

echo "Found the most recent backup: $LATEST_BACKUP"
echo "Download in progress..."

# File download
aws s3 cp "s3://$S3_BUCKET/$LATEST_BACKUP" "$TEMP_DIR/$LATEST_BACKUP" --profile $S3_PROFILE
if [ $? -ne 0 ]; then
    echo "Error during backup file download."
    exit 1
fi

echo "Download completed: $TEMP_DIR/$LATEST_BACKUP"

docker-compose exec -T mysql mysql -u $DB_USER -p$DB_PASS $DB_NAME < "$TEMP_DIR/$LATEST_BACKUP"

# # Cleanup temporary files
echo "Removing temporary files..."
rm -f "$TEMP_DIR/$LATEST_BACKUP"
rmdir "$TEMP_DIR" 2>/dev/null || true

echo "=== Database restore completed successfully ==="
echo "The backup '$LATEST_BACKUP' has been imported into the database '$DB_NAME'."