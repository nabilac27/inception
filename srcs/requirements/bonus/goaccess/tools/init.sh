#!/bin/sh

set -eu

LOG_FILE="/var/log/nginx/access.log"
REPORT="/var/www/goaccess/index.html"

touch "$LOG_FILE"

exec goaccess /var/log/nginx/access.log \
    --log-format=COMBINED               \
    --real-time-html                    \
    --output=/var/www/goaccess/index.html \
    --ws-url=wss://nchairun.42.fr/ws    \
    --addr=0.0.0.0                      \
    --port=7890