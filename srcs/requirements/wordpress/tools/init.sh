#!/bin/bash
set -e

# 1. Read database password from Docker secret
DB_PASSWORD=$(cat /run/secrets/db_password)

# 2. Wait for MariaDB
echo "Waiting for MariaDB..."

until mariadb-admin ping \
    -h mariadb \
    -u "$MYSQL_USER" \
    -p"$DB_PASSWORD" \
    --silent; do
    sleep 2
done

echo "MariaDB is ready!"

# 3. Move to WordPress directory
cd /var/www/html
if [ ! -f wp-includes/version.php ]; then
    wp core download --allow-root
fi

# 4. Create WordPress configuration
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="mariadb:3306" \
        --allow-root
fi

# 5. Install WordPress
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    # 6. Create additional WordPress user
    wp user create \
        "$WP_USER" \
        "$WP_USER_EMAIL" \
        --user_pass="$(cat /run/secrets/wp_user_password)" \
        --role=author \
        --allow-root
fi

# 7. Start PHP-FPM in foreground
echo "Starting PHP-FPM..."

exec php-fpm8.2 -F