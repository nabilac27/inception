FROM	debian:bookworm

RUN 	apt-get update && \
		apt-get install -y --no-install-recommends mariadb-server && \
		rm -rf /var/lib/apt/lists/* && \
		mkdir -p /run/mysqld && \
		chown mysql:mysql /run/mysqld

COPY 	conf/50-server.cnf 	/etc/mysql/mariadb.conf.d/50-server.cnf

COPY 	tools/init.sh 		/usr/local/bin/init.sh

RUN 	chmod +x /usr/local/bin/init.sh

EXPOSE 	3306
# USER 	mysql

ENTRYPOINT ["/usr/local/bin/init.sh"]

# Docker container
#       │
#       ├── root        ❌ don't run MariaDB as this
#       │
#       └── mysql       ✅
#            │
#            └── mariadbd

# Process				Linux user	Why
# init.sh				root		Creates directories, changes ownership, initializes the database
# Temporary mariadbd	mysql		Runs the database server during initialization
# Final mariadbd		mysql		Runs the actual database server


# Docker container
#        |
#        v
# init.sh (root)
#        |
#        +-- Initialize directories and database
#        |
#        +-- Temporary mariadbd (mysql)
#        |         |
#        |         +-- Create WordPress database and user
#        |         +-- Shut down
#        |
#        v
# exec mariadbd --user=mysql
#        |
#        v
# Final MariaDB server (mysql, PID 1)

# docker compose exec mariadb ps -eo pid,user,comm
# - PID 1, mysql, mariadbd: MariaDB is the container's main process and runs as the correct non-root user.
# - PID 22, root, ps: This is just the command you executed using docker compose exec. It runs as root because your Dockerfile no longer specifies USER mysql.