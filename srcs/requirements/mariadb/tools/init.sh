#!/bin/sh

set -e

# ------------------------ READ DATABASE PASSWORDS -----------------------------------------
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ -z "$DB_PASSWORD" ] || [ -z "$DB_ROOT_PASSWORD" ];
then
    echo "Error: MariaDB password is empty." >&2
    exit 1
fi

# ------------------------ PREPARE MARIADB DIRECTORY ---------------------------------------
mkdir -p    /run/mysqld     /var/lib/mysql
chown       mysql:mysql     /run/mysqld     /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ];
then        
	echo 				"Initializing MariaDB database..."
	mariadb-install-db	--user=mysql    --datadir=/var/lib/mysql
fi

# ------------------------ START TEMPORARY MARIADB SERVER ----------------------------------
echo        "Synchronizing MariaDB users..."

mariadbd    --user=mysql    --skip-networking   &     
MARIADB_PID=$!
TRIES=0

# ------------------------ WAIT FOR MARIADB TO BE READY ------------------------------------
until mariadb -u root -e "SELECT 1" >/dev/null 2>&1;
do
    TRIES=$((TRIES + 1))

    if [ "$TRIES" -ge 30 ];
    then
            echo "Error: MariaDB failed to start or root socket authentication failed." >&2
            exit 1
    fi

    sleep 1
done

# ------------------------ CREATE DATABASE AND SYNCHRONIZE PASSWORDS ------------------------
mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
ALTER USER '${MARIADB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';

ALTER USER 'root'@'localhost'
    IDENTIFIED VIA mysql_native_password USING PASSWORD('${DB_ROOT_PASSWORD}')
    OR unix_socket;
EOF

# ------------------------ STOP TEMPORARY MARIADB SERVER ------------------------------------
mariadb-admin -u root shutdown
wait 			"$MARIADB_PID"

# ------------------------ START MARIADB IN FOREGROUND  -------------------------------------
exec mariadbd --user=mysql
