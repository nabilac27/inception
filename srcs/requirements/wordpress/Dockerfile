FROM debian:12

# 1. Install PHP-FPM, PHP extensions and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php-fpm \
        php-mysql \
        php-curl \
        php-gd \
        php-mbstring \
        php-xml \
        php-zip \
        mariadb-client \
        curl \
        ca-certificates \
        tar \
    && rm -rf /var/lib/apt/lists/*

# 2. Download WordPress into a temporary image directory
RUN mkdir -p /usr/src/wordpress && \
    curl -fsSL https://wordpress.org/wordpress-6.8.3.tar.gz \
    | tar -xz --strip-components=1 -C /usr/src/wordpress

# 3. Install WP-CLI
RUN curl -fsSL \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# 4. Configure PHP-FPM to listen on port 9000
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

# 5. Create PHP runtime directory
RUN mkdir -p /run/php

# 6. Copy initialization script
COPY tools/init.sh /usr/local/bin/init.sh

RUN chmod +x /usr/local/bin/init.sh

# 7. Set working directory
WORKDIR /var/www/html

# 8. Expose PHP-FPM port
EXPOSE 9000

# 9. Run initialization script
ENTRYPOINT ["/usr/local/bin/init.sh"]