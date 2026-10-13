#!/bin/sh

set -e

# ------------------------ READ DB PASSWORD, PREPARE MARIADB DIRECTORY ------------------------
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ -z "$DB_PASSWORD" ] || [ -z "$DB_ROOT_PASSWORD" ];
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
    TRIES=0

    until   mariadb-admin   ping    --silent;                    # Wait for MariaDB to be ready
    do
        TRIES=$((TRIES + 1))

        if [ "$TRIES" -ge 30 ];
        then
                echo "Error: MariaDB failed to start." >&2
                exit 1
        fi
        sleep 1
    done

    # ------------------------ EXECUTE SQL INITIALIZATION ------------------------
    mariadb <<EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
    FLUSH PRIVILEGES;
EOF

#     mariadb <<EOF
# 	CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
# 	CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
# 	GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
# 	FLUSH PRIVILEGES;
# EOF

    # ------------------------ STOP TEMP MARIADB SERVER ------------------------
    mariadb-admin -u root -p"$DB_ROOT_PASSWORD" shutdown
    # mariadb-admin 	shutdown               
    wait 			"$MARIADB_PID"

    # ------------------------ CREATE INITIIALIZATION "MARKER" ------------------------
    touch                   /var/lib/mysql/.wordpress_initialized
    chown   mysql:mysql     /var/lib/mysql/.wordpress_initialized
fi

# ------------------------ START MARIADB IN FOREGROUND ------------------------
exec mariadbd --user=mysql
