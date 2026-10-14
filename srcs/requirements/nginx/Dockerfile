FROM    debian:bookworm

RUN     apt-get update                                       && \
        apt-get install -y   nginx openssl   ca-certificates && \
        rm -rf       /var/lib/apt/lists/*                    && \
        mkdir -p     /etc/nginx/ssl                          && \
        openssl req  -x509 -nodes -days 365                     \
        -newkey      rsa:2048                                   \
        -keyout      /etc/nginx/ssl/nginx.key                   \
        -out         /etc/nginx/ssl/nginx.crt                   \
        -subj        "/CN=nchairun.42.fr"                       \
        -addext      "subjectAltName=DNS:nchairun.42.fr,DNS:localhost"

EXPOSE  443

COPY    requirements/nginx/conf/default.conf    /etc/nginx/conf.d/default.conf
COPY    requirements/bonus/website/             /var/www/static/website/

CMD     ["nginx", "-g", "daemon off;"]