#!/bin/bash
set -e

# ------------------------ READ DB_PASSWORD, PREP MARIADB DIR ------------------------
DB_PASSWORD=$(cat /run/secrets/db_password)

source  /run/secrets/credentials

if [ -z "$DB_PASSWORD" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_AUTHOR_PASSWORD" ]; then
    echo "Error: WordPress password is empty." >&2
    exit 1
fi

until mariadb \
    -h mariadb \
    -u "$MARIADB_USER" \
    -p"$DB_PASSWORD" \
    "$MARIADB_DATABASE" \
    -e "SELECT 1;" >/dev/null 2>&1; do
    sleep 2
done

# ------------------------ DOWNLOAD WORDPRESS ------------------------
cd  /var/www/html
if [ ! -f "/var/www/html/wp-includes/version.php" ]; then
    wp core download --version=6.8.3 --allow-root
fi

# ------------------------ CREATE WORDPRESS CONFIG ------------------------
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$MARIADB_DATABASE" \
        --dbuser="$MARIADB_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root
else
    wp config set DB_NAME "$MARIADB_DATABASE" --allow-root
    wp config set DB_USER "$MARIADB_USER" --allow-root
    wp config set DB_PASSWORD "$DB_PASSWORD" --allow-root
    wp config set DB_HOST "mariadb:3306" --allow-root
fi

# ------------------------ INSTALL WORDPRESS ------------------------
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
fi

# ------------------------ UPDATE WORDPRESS ADMIN PASSWORD ------------------------
if wp user get "$WP_ADMIN_USER" --allow-root >/dev/null 2>&1; then
    if ! wp user check-password "$WP_ADMIN_USER" "$WP_ADMIN_PASSWORD" --allow-root >/dev/null 2>&1; then
        wp user update "$WP_ADMIN_USER" \
            --user_pass="$WP_ADMIN_PASSWORD" \
            --allow-root
    fi
fi

# ------------------------ CREATE/UPDATE WORDPRESS AUTHOR ------------------------ 
if ! wp user get "$WP_AUTHOR" --allow-root >/dev/null 2>&1; then
    wp user create \
        "$WP_AUTHOR" \
        "$WP_AUTHOR_EMAIL" \
        --user_pass="$WP_AUTHOR_PASSWORD" \
        --role=author \
        --allow-root
elif ! wp user check-password "$WP_AUTHOR" "$WP_AUTHOR_PASSWORD" --allow-root >/dev/null 2>&1; then
    wp user update "$WP_AUTHOR" \
        --user_pass="$WP_AUTHOR_PASSWORD" \
        --allow-root
fi

# ------------------------ START PHP-FPM ------------------------
exec php-fpm8.2 -F

