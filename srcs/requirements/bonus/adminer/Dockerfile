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
