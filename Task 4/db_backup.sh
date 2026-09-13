#!/bin/bash

BACKUP_DIR="/var/backups/db"
DATE=$(date +%Y%m%d)
BACKUP_FILE="${BACKUP_DIR}/db_backup_${DATE}.sql.gz"

# Create backup directory
mkdir -p "${BACKUP_DIR}"

# Create MySQL backup
docker exec task2-database-1 \
mysqldump --no-tablespaces -u myuser -pmypassword myapp \
| gzip > "${BACKUP_FILE}"

# Check backup result
if [ $? -eq 0 ]; then
    echo "Backup created successfully: ${BACKUP_FILE}"
else
    echo "Backup failed!"
    exit 1
fi