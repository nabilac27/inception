#!/bin/sh

set -eu

LOG_FILE="/var/log/nginx/access.log"
REPORT="/var/www/goaccess/index.html"

echo "Waiting for NGINX access log..."

while [ ! -f "$LOG_FILE" ]; do
    sleep 2
done

echo "Starting GoAccess..."

while true; do
    goaccess "$LOG_FILE" \
        --log-format=COMBINED \
        --output="$REPORT"

    sleep 10
done