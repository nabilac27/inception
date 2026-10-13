#!/bin/sh

set -e

# ------------------------ READ DB PASSWORD, PREPARE MARIADB DIRECTORY ------------------------
DB_PASSWORD=$(cat /run/secrets/db_password)

if [ -z "$DB_PASSWORD" ]; 
then
    echo "Error: MariaDB password is empty." >&2
    exit 1
fi

mkdir -p    /run/mysqld     /var/lib/mysql			            # Runtime files, including MariaDB's Unix socket
chown       mysql:mysql     /run/mysqld     /var/lib/mysql

# ------------------------ INIT MARIADB DIRECTORY ------------------------
if [ ! -d "/var/lib/mysql/mysql" ];                             # Init only if database files do not exist
then        
	echo 				"Initializing MariaDB database..."
	mariadb-install-db	--user=mysql --datadir=/var/lib/mysql
fi

# ------------------------ INIT WORDPRESS DATABASE AND USER  ------------------------
if [ ! -f "/var/lib/mysql/.wordpress_initialized" ]; 
then
    echo    "Creating database and user..."

    # ------------------------ CREATE TEMP MARIADB SERVER ------------------------
    mariadbd    --user=mysql    --skip-networking   &     
    MARIADB_PID=$!

    until   mariadb-admin   ping    --silent;                    # Wait for MariaDB to be ready
    do
        sleep 1
    done

    # ------------------------ EXECUTE SQL INITIALIZATION ------------------------
    mariadb <<EOF
	CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
	CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
	GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
	FLUSH PRIVILEGES;
EOF

    # ------------------------ STOP TEMP MARIADB SERVER ------------------------
    mariadb-admin 	shutdown               
    wait 			"$MARIADB_PID"

    # ------------------------ CREATE INITIIALIZATION "MARKER" ------------------------
    touch                   /var/lib/mysql/.wordpress_initialized
    chown   mysql:mysql     /var/lib/mysql/.wordpress_initialized
fi

# ------------------------ START MARIADB IN FOREGROUND ------------------------
exec mariadbd --user=mysql
