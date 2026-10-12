#!/bin/sh

set -e

# ------------------------ READ DB PASSWORD, PREPARE MARIADB DIRECTORY ------------------------
DB_PASSWORD=$(cat /run/secrets/db_password)

mkdir 	-p /run/mysqld /var/lib/mysql			# Runtime files, including MariaDB's Unix socket
chown 	mysql:mysql /run/mysqld /var/lib/mysql

# ------------------------ INIT MARIADB DIRECTORY ------------------------
if [ ! -d "/var/lib/mysql/mysql" ]; then		# Persistent databa
	echo 				"Initializing MariaDB database..."
	mariadb-install-db	--user=mysql --datadir=/var/lib/mysql
fi

# ------------------------ CHECK WP DB, START TEMP MARIADB SERVER, CREATE WP DB, USER ------------------------
if [ ! -f "/var/lib/mysql/.wordpress_initialized" ]; then
    echo 		"Creating database and user..."

    mariadbd 	--user=mysql --skip-networking &
    MARIADB_PID=$!

    until mariadb-admin ping --silent; do
        sleep 1
    done

    mariadb <<EOF
	CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
	CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
	GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
	FLUSH PRIVILEGES;
EOF

    mariadb-admin 	shutdown
    wait 			"$MARIADB_PID"

    touch /var/lib/mysql/.wordpress_initialized
    chown mysql:mysql /var/lib/mysql/.wordpress_initialized
fi

# ------------------------ STOP TEMP MARIADB SERVER ------------------------
exec mariadbd --user=mysql
