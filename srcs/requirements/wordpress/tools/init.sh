#!/bin/bash

set     -e

# ------------------------ READ DB_PASSWORD AND WORDPRESS PASSWORD ------------------------
DB_PASSWORD=$(cat /run/secrets/db_password)

source  /run/secrets/credentials

if [ -z "$DB_PASSWORD" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_AUTHOR_PASSWORD" ]; 
then
    echo    "Error: WordPress password is empty." >&2
    exit    1
fi

# ------------------------ WAIT FOR MARIADB CONNECTION -------------------------------------
until  mariadb              \
    -h mariadb              \
    -u "$MARIADB_USER"      \
    -p"$DB_PASSWORD"        \
       "$MARIADB_DATABASE"  \
    -e "SELECT 1;" >/dev/null 2>&1; 
do
    sleep 2
done

# ------------------------ DOWNLOAD WORDPRESS ----------------------------------------------
if [ ! -f "/var/www/html/wp-includes/version.php" ]; 
then
    wp core download    --version=6.8.3     --allow-root
fi

# ------------------------ CREATE WORDPRESS CONFIG -----------------------------------------
if [ ! -f wp-config.php ]; 
then
    wp  config   create              \
        --dbname="$MARIADB_DATABASE" \
        --dbuser="$MARIADB_USER"     \
        --dbpass="$DB_PASSWORD"      \
        --dbhost="mariadb:3306"      \
        --allow-root
else
    wp  config set  DB_NAME     "$MARIADB_DATABASE" --allow-root
    wp  config set  DB_USER     "$MARIADB_USER"     --allow-root
    wp  config set  DB_PASSWORD "$DB_PASSWORD"      --allow-root    --quiet
    wp  config set  DB_HOST     "mariadb:3306"      --allow-root
fi


# ------------------------ INSTALL CUSTOM THEME --------------------------------------------
if [ -d "/usr/local/share/inception-theme" ];
then
    mkdir -p wp-content/themes/inception
    cp    -r /usr/local/share/inception-theme/. wp-content/themes/inception/
fi

# ------------------------ INSTALL WORDPRESS -----------------------------------------------
if ! wp core  is-installed      --allow-root; 
then
    wp  core   install                        \
        --url="https://${DOMAIN_NAME}"        \
        --title="$WP_TITLE"                   \
        --admin_user="$WP_ADMIN_USER"         \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"       \
        --skip-email                          \
        --allow-root
fi

# ------------------------ CREATE POSTS PAGE ---------------------------------------
if ! wp post get posts --post_type=page --field=ID --allow-root >/dev/null 2>&1; then
    wp post create \
        --post_type=page \
        --post_title="Posts" \
        --post_name="posts" \
        --post_status=publish \
        --allow-root
fi

if [ -d "/usr/local/share/inception-theme" ];
then
    wp theme activate   inception        --allow-root
else
    wp theme activate   twentytwentyfive --allow-root
fi


# ------------------------ UPDATE WORDPRESS URL ------------------------------------
# wp option update home "https://${DOMAIN_NAME}" --allow-root
# wp option update siteurl "https://${DOMAIN_NAME}" --allow-root

# ------------------------ CREATE / UPDATE WORDPRESS ADMIN PASSWORD ------------------------
wp  user update "$WP_ADMIN_USER"             \
    --user_pass="$WP_ADMIN_PASSWORD"         \
    --allow-root --quiet

# ------------------------ CREATE / UPDATE WORDPRESS AUTHOR --------------------------------
if ! wp user get "$WP_AUTHOR"   --allow-root    >/dev/null 2>&1;
then
    wp user create  "$WP_AUTHOR" "$WP_AUTHOR_EMAIL" \
        --user_pass="$WP_AUTHOR_PASSWORD"           \
        --role=subscriber                           \
        --allow-root
else
    wp user update  "$WP_AUTHOR"                    \
        --user_pass="$WP_AUTHOR_PASSWORD"           \
        --allow-root --quiet
fi

# ------------------------ START PHP-FPM ---------------------------------------------------
exec    php-fpm8.2  -F

