# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nchairun <nchairun@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/11 18:50:34 by nchairun          #+#    #+#              #
#    Updated: 2026/10/17 05:55:32 by nchairun         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# **************************************************************************** #
#	VARIABLES                                   							   #
# **************************************************************************** #

NAME         = inception
SHELL        = /bin/bash
COMPOSE      = docker compose -f srcs/docker-compose.yml
DATA_DIR     = $(HOME)/data

SECRETS_DIR  = secrets
SECRET_FILES = $(SECRETS_DIR)/db_root_password.txt \
               $(SECRETS_DIR)/db_password.txt      \
               $(SECRETS_DIR)/credentials.txt

# **************************************************************************** #
#	RULES                                     								   #
# **************************************************************************** #

.SILENT:

all: up

secrets:
	mkdir -p	$(SECRETS_DIR)
	chmod 700	$(SECRETS_DIR)

# ------------------------ MARIADB ROOT ------------------------
	if [ ! -s $(SECRETS_DIR)/db_root_password.txt ]; then 							\
		read -r -s -p "[MariaDB]   root password  : " password || exit 1; echo; 	\
		[ -n "$$password" ] || { echo "Password cannot be blank"; exit 1; }; 		\
		umask 077; 																	\
		printf "%s" "$$password" > $(SECRETS_DIR)/db_root_password.txt; 			\
	fi

# ------------------------ MARIADB USER ------------------------
	if [ ! -s $(SECRETS_DIR)/db_password.txt ]; then 								\
		read -r -s -p "[MariaDB]   user password  : " password || exit 1; echo; 	\
		[ -n "$$password" ] || { echo "Password cannot be blank"; exit 1; }; 		\
		umask 077; 																	\
		printf "%s" "$$password" > $(SECRETS_DIR)/db_password.txt; 					\
	fi
# ------------------------ WORDPRESS CREDENTIALS ---------------
	if [ ! -s $(SECRETS_DIR)/credentials.txt ]; 									\
	then 																			\
		read -r -s -p "[WordPress] admin password : " admin || exit 1; echo; 		\
		[ -n "$$admin" ] || exit 1; 												\
		read -r -s -p "[WordPress] author password: " author || exit 1; echo; 		\
		[ -n "$$author" ] || exit 1; 												\
		umask 077; 																	\
		printf "WP_ADMIN_PASSWORD=%q\nWP_USER_PASSWORD=%q\n" 						\
		"$$admin" "$$author" > $(SECRETS_DIR)/credentials.txt; 						\
	fi

# ------------------------ MANAGE DOCKER CONTAINERS ------------------------
# volumes : create directories for persistent data
# build   : creates Docker images
# up      : creates and starts Docker containers
# down    : stop and remove Docker containers
# -------------------------------------------------------------------------
volumes:
	mkdir -p	$(DATA_DIR)/mariadb		$(DATA_DIR)/wordpress

build:
	$(COMPOSE)	build

up: secrets volumes
	$(COMPOSE)	up -d --build

down:
	$(COMPOSE)	down

# **************************************************************************** #
#	CLEANING                                   								   #
# **************************************************************************** #
# -------------------------------------------------------------------------
# clean  : stop containers and remove orphan containers
# fclean : PERMANENTLY remove volumes, containers, persistent data, secrets
# re     : completely reset and rebuild the infrastructure, persistent data stay
# .PHONY : declare targets that are not actual files
# -------------------------------------------------------------------------
clean:
	$(COMPOSE)	down --remove-orphans

fclean:
	$(COMPOSE) down --rmi all --volumes --remove-orphans
	if [ -d /goinfre ]; then 									\
		echo "42 PC: skipping persistent data deletion"; 		\
	else 														\
		echo "VM: deleting persistent data"; 					\
		sudo rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress; 	\
	fi
	rm -f $(SECRET_FILES)

re: down
	@$(MAKE) --no-print-directory up

# **************************************************************************** #
#	CHECKS AND LOGS                                                            #
# **************************************************************************** #
# WARNING : Deletes ALL Docker containers, images, volumes, networks
eval-clean:
	docker stop       $$(docker ps -qa); 	   				\
	docker rm 		  $$(docker ps -qa); 	   				\
	docker rmi -f 	  $$(docker images -qa);   				\
	docker volume rm  $$(docker volume ls -q); 				\
	docker network rm $$(docker network ls -q) 2>/dev/null

# Check NGINX TLS configuration
check-tls:
	$(COMPOSE) exec -T nginx nginx -T 2>&1 | grep ssl_protocols
	$(COMPOSE) exec -T nginx nginx -T 2>&1 | grep -E 'ssl_certificate|ssl_certificate_key'

# Check WordPress installation and website
check-wordpress:
	$(COMPOSE) exec -T wordpress wp core 	is-installed 	--allow-root --path=/var/www/html
	$(COMPOSE) exec -T wordpress wp option	get home 		--allow-root --path=/var/www/html
	$(COMPOSE) exec -T wordpress wp option	get siteurl 	--allow-root --path=/var/www/html
	curl -k -I https://localhost:443/

.PHONY: all secrets volumes build up down clean fclean re eval-clean check-tls check-wordpress

# **************************************************************************** #
#	CHECKS AND LOGS                                                            #
# **************************************************************************** #

# WARNING: Deletes ALL Docker containers, images, volumes, networks
eval-clean:
	docker stop       $$(docker ps -qa); \
	docker rm         $$(docker ps -qa); \
	docker rmi -f     $$(docker images -qa); \
	docker volume rm  $$(docker volume ls -q); \
	docker network rm $$(docker network ls -q) 2>/dev/null

# ------------------------ ALL SERVICES ------------------------

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs --tail=30

check: check-mariadb check-wordpress check-nginx \
       check-adminer check-redis check-static
	echo "All checks completed!"

# ------------------------ MARIADB -----------------------------

check-mariadb:
	echo "=== MariaDB ==="
	$(COMPOSE) exec -T mariadb mariadb-admin ping

# ------------------------ WORDPRESS ---------------------------

check-wordpress:
	echo "=== WordPress ==="
	$(COMPOSE) exec -T wordpress wp core is-installed \
		--allow-root --path=/var/www/html
	$(COMPOSE) exec -T wordpress wp option get home \
		--allow-root --path=/var/www/html
	$(COMPOSE) exec -T wordpress wp option get siteurl \
		--allow-root --path=/var/www/html

# ------------------------ NGINX -------------------------------

check-nginx: check-tls
	echo "=== NGINX ==="
	$(COMPOSE) exec -T nginx nginx -t
	curl -kfsS -o /dev/null -w "HTTPS: %{http_code}\n" \
		https://localhost:443/

check-tls:
	echo "=== TLS ==="
	$(COMPOSE) exec -T nginx nginx -T 2>&1 | grep ssl_protocols
	$(COMPOSE) exec -T nginx nginx -T 2>&1 | grep -E \
		'ssl_certificate|ssl_certificate_key'

# ------------------------ ADMINER -----------------------------

check-adminer:
	echo "=== Adminer ==="
	$(COMPOSE) exec -T adminer php -v
	curl -kfsS -o /dev/null -w "Adminer: %{http_code}\n" \
		https://localhost:443/adminer/

# ------------------------ REDIS -------------------------------

check-redis:
	echo "=== Redis ==="
	$(COMPOSE) exec -T redis redis-cli ping
	$(COMPOSE) exec -T wordpress wp redis status \
		--allow-root --path=/var/www/html

# ------------------------ STATIC WEBSITE ----------------------

check-static:
	echo "=== Static Website ==="
	curl -kfsS -o /dev/null -w "Static: %{http_code}\n" \
		https://localhost:443/static/

