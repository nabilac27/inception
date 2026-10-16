FROM    debian:bookworm

RUN     apt-get update && apt-get install -y \
        goaccess \
        ca-certificates \
        && rm -rf /var/lib/apt/lists/*

COPY    tools/init.sh /usr/local/bin/init.sh

RUN     chmod +x /usr/local/bin/init.sh \
        && mkdir -p /var/log/nginx /var/www/goaccess

ENTRYPOINT ["/usr/local/bin/init.sh"]