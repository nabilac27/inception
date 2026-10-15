# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nchairun <nchairun@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/11 18:50:34 by nchairun          #+#    #+#              #
#    Updated: 2026/10/15 23:56:00 by nchairun         ###   ########.fr        #
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
	if [ ! -s $(SECRETS_DIR)/db_root_password.txt ]; 								\
	then 																			\
		read -r -s -p "[MariaDB]   root password  : " password || exit 1; echo; 	\
		if [ -z "$$password" ]; then \
		echo "Exit, passwords can't be blank"; exit 1; \
		fi; \
		[ -n "$$password" ] || exit 1; 												\
		umask 077; 																	\
		printf "%s" "$$password" > $(SECRETS_DIR)/db_root_password.txt; 			\
	fi

# ------------------------ MARIADB USER ------------------------
	if [ ! -s $(SECRETS_DIR)/db_password.txt ]; 									\
	then 																			\
		read -r -s -p "[MariaDB]   user password  : " password || exit 1; echo; 	\
		if [ -z "$$password" ]; then \
		echo "Exit, passwords can't be blank"; exit 1; \
		fi; \
		[ -n "$$password" ] || exit 1; 												\
		umask 077;																	\
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
	$(COMPOSE) down --rmi all --volumes
# 	rm -rf "$(DATA_DIR)/mariadb" "$(DATA_DIR)/wordpress"
	rm -f $(SECRET_FILES)

re: down
	@$(MAKE) --no-print-directory up

.PHONY: all secrets volumes build up down clean fclean re eval-clean check-tls check-wordpress

# **************************************************************************** #
#	CHECKS AND LOGS                                                            #
# **************************************************************************** #
# WARNING : Deletes ALL Docker containers, images, volumes, networks
eval-clean:
	docker stop       $$(docker ps -qa); 	   \
	docker rm 		  $$(docker ps -qa); 	   \
	docker rmi -f 	  $$(docker images -qa);   \
	docker volume rm  $$(docker volume ls -q); \
	docker network rm $$(docker network ls -q) 2>/dev/null

# Check NGINX TLS configuration
check-tls:
	$(COMPOSE) exec -T nginx nginx -T 2>&1 | grep ssl_protocols
	$(COMPOSE) exec -T nginx nginx -T 2>&1 | grep -E 'ssl_certificate|ssl_certificate_key'

# Check WordPress installation and website
check-wordpress:
	$(COMPOSE) exec -T wordpress wp core is-installed --allow-root --path=/var/www/html
	$(COMPOSE) exec -T wordpress wp option get home --allow-root --path=/var/www/html
	$(COMPOSE) exec -T wordpress wp option get siteurl --allow-root --path=/var/www/html
	curl -k -I https://localhost:8443/

# Check detailed WordPress status
check-wordpress-detail:
	@echo "=== WordPress Version ==="
	$(COMPOSE) exec -T wordpress wp core version --allow-root --path=/var/www/html
	@echo "=== WordPress Users ==="
	$(COMPOSE) exec -T wordpress wp user list --allow-root --path=/var/www/html
	@echo "=== WordPress Plugins ==="
	$(COMPOSE) exec -T wordpress wp plugin list --allow-root --path=/var/www/html
	@echo "=== WordPress Themes ==="
	$(COMPOSE) exec -T wordpress wp theme list --allow-root --path=/var/www/html
	@echo "=== WordPress Database ==="
	$(COMPOSE) exec -T wordpress wp db check --allow-root --path=/var/www/html

# check-wordpress-detail:
# 	@echo "Checking WordPress installation..."
# 	@i=0; until docker exec wordpress wp core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; do \
# 		i=$$((i + 1)); \
# 		if [ $$i -ge 30 ]; then \
# 			echo "ERROR: WordPress is not ready. Check: make logs"; \
# 			exit 1; \
# 		fi; \
# 		sleep 2; \
# 	done
# 	@echo "Checking WordPress URLs..."
# 	@home=$$(docker exec wordpress wp option get home --allow-root --path=/var/www/html 2>/dev/null); \
# 	if [ "$$home" != "https://localhost:8443" ]; then \
# 		echo "Updating home URL..."; \
# 		docker exec wordpress wp option update home 'https://localhost:8443' --allow-root --path=/var/www/html; \
# 	else \
# 		echo "Home URL is already correct."; \
# 	fi
# 	@siteurl=$$(docker exec wordpress wp option get siteurl --allow-root --path=/var/www/html 2>/dev/null); \
# 	if [ "$$siteurl" != "https://localhost:8443" ]; then \
# 		echo "Updating site URL..."; \
# 		docker exec wordpress wp option update siteurl 'https://localhost:8443' --allow-root --path=/var/www/html; \
# 	else \
# 		echo "Site URL is already correct."; \
# 	fi
# 	@echo "Checking website..."
# 	@i=0; ok=0; \
# 	while [ $$i -lt 10 ]; do \
# 		code=$$(curl -k -sS -o /dev/null -w '%{http_code}' --max-time 5 https://localhost:8443/ 2>/dev/null || true); \
# 		case "$$code" in \
# 			2[0-9][0-9]|3[0-9][0-9]) ok=1; break ;; \
# 		esac; \
# 		i=$$((i + 1)); \
# 		sleep 2; \
# 	done; \
# 	if [ $$ok -eq 1 ]; then \
# 		echo "Website is responding. No restart needed."; \
# 	else \
# 		echo "Website is still unavailable. Restarting WordPress and NGINX once..."; \
# 		docker compose -f srcs/docker-compose.yml restart wordpress nginx; \
# 		sleep 5; \
# 		code=$$(curl -k -sS -o /dev/null -w '%{http_code}' --max-time 10 https://localhost:8443/ 2>/dev/null || true); \
# 		case "$$code" in \
# 			2[0-9][0-9]|3[0-9][0-9]) echo "Website recovered."; ;; \
# 			*) echo "ERROR: Website still unavailable (HTTP $$code)."; \
# 			   echo "Check logs with: make logs"; exit 1 ;; \
# 		esac; \
# 	fi


# TO DELETE MARIADB VOL IN HOST PC
# docker run --rm -v "$HOME/data:/data" alpine sh -c 'rm -rf /data/mariadb'


# TO SEE WORDPRESS DEFAULT THEME
# docker exec wordpress wp theme list --allow-root
# docker exec wordpress wp theme activate twentytwentyfive --allow-root

# TO CHANGE AND UPDATE WORDPRESS THEME
# tar -C srcs/requirements/wordpress/custom-theme -cf - . \
#     | docker exec -i wordpress tar -xf - \
#         -C /var/www/html/wp-content/themes/custom-theme \
#         --no-same-owner

# https://localhost:8443/
# https://localhost:8443/bonus-static-web/
# https://localhost:8443/bonus-adminer/


#replace all occurrences automatically
# grep -rlZ 'WP_AUTHOR' --exclude-dir=.git . | xargs -0 -r sed -i 's/WP_AUTHOR/WP_USER/g'
