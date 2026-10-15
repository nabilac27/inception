FROM    php:8.2-apache

RUN     apt-get update                && \ 
        apt-get install               -y \
        curl                          && \
        docker-php-ext-install mysqli && \
        curl -fsSL https://www.adminer.org/latest.php \
        -o /var/www/html/index.php && \
        apt-get purge -y              \ 
        curl                       && \
        rm -rf /var/lib/apt/lists/*

EXPOSE  80

# -----------------------------------------------------------------------------------------------
# Browser
#    |
#    | HTTPS :8443/bonus-adminer/
#    v
# NGINX
#    |
#    | HTTP (Docker internal network)
#    v
# Adminer (Apache + PHP)
#    |
#    | MariaDB protocol :3306
#    v
# MariaDB
#    |
#    v
# WordPress Database