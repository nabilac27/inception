FROM debian:12


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
        php-curl \
        php-gd \
        php-mbstring \
        php-xml \
        php-zip \
        curl \
        ca-certificates \
        tar \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    curl -fsSL https://wordpress.org/wordpress-6.8.3.tar.gz \
    | tar -xz --strip-components=1 -C /var/www/html