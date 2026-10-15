#!/bin/bash

set -e

# ------------------------ READ DATABASE AND WORDPRESS PASSWORDS ---------------------------
DB_PASSWORD=$(cat /run/secrets/db_password)

source /run/secrets/credentials

if [ -z "$DB_PASSWORD" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_USER_PASSWORD" ];
then
    echo "Error: WordPress password is empty." >&2
    exit 1
fi

# ------------------------ WAIT FOR MARIADB CONNECTION -------------------------------------
until mariadb                  \
    -h mariadb                  \
    -u "$MARIADB_USER"          \
    -p"$DB_PASSWORD"            \
       "$MARIADB_DATABASE"      \
    -e "SELECT 1;" >/dev/null 2>&1;
do
    sleep 2
done

# ------------------------ DOWNLOAD WORDPRESS ----------------------------------------------
if [ ! -f "/var/www/html/wp-includes/version.php" ];
then
    wp core download --version=6.8.3 --allow-root
fi

# ------------------------ CREATE WORDPRESS CONFIG -----------------------------------------
if [ ! -f wp-config.php ];
then
    wp config create               \
        --dbname="$MARIADB_DATABASE" \
        --dbuser="$MARIADB_USER"      \
        --dbpass="$DB_PASSWORD"       \
        --dbhost="mariadb:3306"       \
        --allow-root
else
    wp config set DB_NAME     "$MARIADB_DATABASE" --allow-root
    wp config set DB_USER     "$MARIADB_USER"     --allow-root
    wp config set DB_PASSWORD "$DB_PASSWORD"      --allow-root --quiet
    wp config set DB_HOST     "mariadb:3306"      --allow-root
fi

# ------------------------ CONFIGURE REDIS -------------------------------------------------
wp config set WP_REDIS_HOST "redis" --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root

# ------------------------ INSTALL CUSTOM THEME --------------------------------------------
if [ -d "/usr/local/share/custom-theme" ];
then
    mkdir -p wp-content/themes/custom-theme
    cp -r /usr/local/share/custom-theme/. wp-content/themes/custom-theme/
else
    echo "Error: Custom WordPress theme files not found." >&2
    exit 1
fi

# ------------------------ INSTALL WORDPRESS -----------------------------------------------
if ! wp core is-installed --allow-root;
then
    wp core install                         \
        --url="https://${DOMAIN_NAME}"        \
        --title="$WP_TITLE"                   \
        --admin_user="$WP_ADMIN_USER"         \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"       \
        --skip-email                          \
        --allow-root
fi

# ------------------------ CONFIGURE CUSTOM THEME ------------------------------------------
bash /usr/local/share/custom-theme/tools/init.sh

# ------------------------ INSTALL REDIS OBJECT CACHE --------------------------------------
if ! wp plugin is-installed redis-cache --allow-root;
then
    wp plugin install redis-cache --activate --allow-root
fi

wp plugin activate redis-cache --allow-root --quiet
wp redis enable --allow-root

# ------------------------ UPDATE WORDPRESS URL --------------------------------------------
wp option update home    "https://localhost:8443" --allow-root
wp option update siteurl "https://localhost:8443" --allow-root

# ------------------------ UPDATE WORDPRESS ADMIN PASSWORD ---------------------------------
wp user update "$WP_ADMIN_USER"         \
    --user_pass="$WP_ADMIN_PASSWORD"     \
    --allow-root --quiet

# ------------------------ CREATE / UPDATE WORDPRESS USER ----------------------------------
if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1;
then
    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD"          \
        --role=subscriber                          \
        --allow-root
else
    wp user update "$WP_USER"                    \
        --user_pass="$WP_USER_PASSWORD"          \
        --allow-root --quiet
fi

# ------------------------ START PHP-FPM ---------------------------------------------------
exec php-fpm8.2 -F
