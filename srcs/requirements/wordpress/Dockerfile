FROM    debian:bookworm

# ------------------------ INSTALL DEPENDENCIES ------------------------
# REDIS
RUN     apt-get update &&   \
        apt-get install -y  \
        php8.2-fpm          \
        php8.2-mysql        \
        php8.2-mbstring     \
        php8.2-xml          \
        php8.2-curl         \
        php-redis           \   
        mariadb-client      \
        curl                \
        ca-certificates &&  \
        rm -rf /var/lib/apt/lists/*

# ------------------------ INSTALL WP-CLI ------------------------
RUN     curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o         /usr/local/bin/wp &&                                                      \
        chmod +x   /usr/local/bin/wp        

# ------------------------ CONFIGURE PHP-FPM ------------------------
RUN     sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' \
        /etc/php/8.2/fpm/pool.d/www.conf                            \
        && mkdir -p /run/php

# ------------------------ START WORDPRESS ------------------------
COPY    tools/init.sh   /usr/local/bin/init.sh
RUN     chmod +x        /usr/local/bin/init.sh
COPY    custom-theme/   /usr/local/share/custom-theme/

WORKDIR /var/www/html
EXPOSE  9000

ENTRYPOINT ["/usr/local/bin/init.sh"]