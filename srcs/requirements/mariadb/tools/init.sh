#!/bin/sh

set -e

# Read database password from Docker secret
DB_PASSWORD=$(cat /run/secrets/db_password)

# Start MariaDB temporarily without network access
mariadbd --skip-networking &
MARIADB_PID=$!

# Wait until MariaDB is ready
until mariadb-admin ping --silent; do
	sleep 1
done

# Create database and user
mariadb <<EOF
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Stop temporary MariaDB
mariadb-admin shutdown
wait "$MARIADB_PID"

# Start MariaDB normally as PID 1
exec mariadbd



# ------ with bootstrap but need to fix
# #!/bin/sh

# set -e


# echo "Starting MariaDB..."

# # Read password from Docker secret
# DB_PASSWORD=$(cat /run/secrets/db_password)

# # Initialize MariaDB system files if needed
# if [ ! -d "/var/lib/mysql/mysql" ]; then
# 	echo "Initializing MariaDB database..."
# 	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
# fi

# # Create WordPress database and database user if needed
# if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
# 	echo "Creating database and user..."


# 	mariadbd --user=mysql --bootstrap <<EOF
# 		CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
# 		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
# 		GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
# 		FLUSH PRIVILEGES;
# EOF
# fi

# # Start MariaDB normally as PID 1
# exec mariadbd