#!/bin/bash
set -e

# ------------------------ READ DB PASSWORD, PREPARE MARIADB DIRECTORY ------------------------
DB_PASSWORD=$(cat /run/secrets/db_password)

until mariadb \
    -h mariadb \
    -u "$MARIADB_USER" \
    -p"$DB_PASSWORD" \
    "$MARIADB_DATABASE" \
    -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done

# ------------------------ MOVE TO WP DIRECTORY ------------------------
cd /var/www/html
if [ ! -f wp-includes/version.php ]; then
    cp -a /usr/src/wordpress/. /var/www/html/
fi

# ------------------------ CREATE WP CONFIG, INSTALL WP, CREATE ADDITIONAL WPUSER ------------------------
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$MARIADB_DATABASE" \
        --dbuser="$MARIADB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root
else
    wp config set DB_PASSWORD "$DB_PASSWORD" --allow-root
fi

if ! wp core is-installed --allow-root; then
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$(cat /run/secrets/wp_user_password)" \
        --role=author \
        --allow-root
fi

# ------------------------ START PHP-FPM ------------------------
exec php-fpm8.2 -F