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