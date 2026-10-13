FROM    debian:bookworm

RUN     apt-get update &&  \
        apt-get install -y \
        php-fpm            \
        php-mysql          \
        php-curl           \
        php-gd             \
        php-mbstring       \
        php-xml            \
        php-zip            \
        mariadb-client     \
        curl               \
        ca-certificates    \
        tar                \
        && rm -rf /var/lib/apt/lists/*

# RUN     mkdir -p        /usr/src/wordpress && \
#         curl -fsSL      https://wordpress.org/wordpress-6.8.3.tar.gz \
#         | tar -xz --strip-components=1 -C /usr/src/wordpress

RUN     curl      -fsSL \
        https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o        /usr/local/bin/wp && \
        chmod +x  /usr/local/bin/wp

RUN     sed -i    's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' \
        /etc/php/8.2/fpm/pool.d/www.conf

RUN     mkdir -p        /run/php

COPY    tools/init.sh   /usr/local/bin/init.sh

RUN     chmod +x        /usr/local/bin/init.sh

WORKDIR /var/www/html

EXPOSE  9000

ENTRYPOINT ["/usr/local/bin/init.sh"]