FROM debian:12


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
    && rm -rf /var/lib/apt/lists/*