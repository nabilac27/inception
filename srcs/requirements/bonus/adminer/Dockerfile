FROM    debian:bookworm

RUN     apt-get update      && \
        apt-get install -y     \
        apache2                \
        php8.2                 \
        libapache2-mod-php8.2  \
        php8.2-mysql           \
        curl                && \
        curl -fsSL https://www.adminer.org/latest.php \
        -o /var/www/html/index.php  && \
        apt-get purge -y curl       && \
        apt-get autoremove -y       && \
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