#!/bin/bash

LOG="/var/log/infra_health.log"
TIME=$(date '+%Y-%m-%d %H:%M:%S')
WARNING=0

echo "========================================" | tee -a "$LOG"
echo "Infrastructure Health Check - $TIME" | tee -a "$LOG"
echo "========================================" | tee -a "$LOG"

# CPU, RAM and Root Disk usage
CPU=$(top -bn1 | awk '/Cpu\(s\)/ {print 100 - $8}')
RAM=$(free | awk '/Mem:/ {printf "%.0f", $3/$2 * 100}')
DISK=$(df / | awk 'NR==2 {print $5}' | tr -d '%')

echo "CPU: ${CPU}% | RAM: ${RAM}% | Root Disk: ${DISK}%" | tee -a "$LOG"

# Check Docker
if systemctl is-active --quiet docker; then
    echo "Docker: RUNNING" | tee -a "$LOG"
else
    echo "[WARNING] Docker is NOT running!" | tee -a "$LOG"
    WARNING=1
fi

# Check Backend container
BACKEND_STATUS=$(sudo docker inspect -f '{{.State.Status}}' task2-backend-1 2>/dev/null)

if [ "$BACKEND_STATUS" = "running" ]; then
    echo "Backend App: RUNNING" | tee -a "$LOG"
else
    echo "[WARNING] Backend App is ${BACKEND_STATUS:-NOT FOUND}!" | tee -a "$LOG"
    WARNING=1
fi

# Check Root Disk usage
if [ "$DISK" -gt 85 ]; then
    echo "[WARNING] Root Disk usage is ${DISK}%!" | tee -a "$LOG"
    WARNING=1
else
    echo "Disk Status: OK" | tee -a "$LOG"
fi

echo "----------------------------------------" | tee -a "$LOG"

# Overall status
if [ "$WARNING" -eq 0 ]; then
    echo "STATUS: OK - Infrastructure is healthy." | tee -a "$LOG"
else
    echo "STATUS: WARNING - Check the issues above!" | tee -a "$LOG"
fi

echo "========================================" | tee -a "$LOG"

