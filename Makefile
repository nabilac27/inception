# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nchairun <nchairun@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/11 18:50:34 by nchairun          #+#    #+#              #
#    Updated: 2026/10/14 05:42:48 by nchairun         ###   ########.fr        #
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

# ------------------------ WORDPRESS CREDENTIALS ------------------------
	if [ ! -s $(SECRETS_DIR)/credentials.txt ]; 									\
	then 																			\
		read -r -s -p "[WordPress] admin password : " admin || exit 1; echo; 		\
		[ -n "$$admin" ] || exit 1; 												\
		read -r -s -p "[WordPress] author password: " author || exit 1; echo; 		\
		[ -n "$$author" ] || exit 1; 												\
		umask 077; 																	\
		printf "WP_ADMIN_PASSWORD=%q\nWP_AUTHOR_PASSWORD=%q\n" 						\
		"$$admin" "$$author" > $(SECRETS_DIR)/credentials.txt; 						\
	fi

# ------------------------ MANAGE DOCKER CONTAINERS ------------------------
# volumes : create directories for persistent data
# build   : build Docker images
# up      : build and start Docker containers
# down    : stop and remove Docker containers
# -------------------------------------------------------------------------
volumes:
	mkdir -p	$(DATA_DIR)/mariadb		$(DATA_DIR)/wordpress

build: secrets
	$(COMPOSE)	build

up: secrets volumes
	$(COMPOSE)	up -d --build --force-recreate

down:
	$(COMPOSE)	down

# **************************************************************************** #
#	CLEANING                                   								   #
# **************************************************************************** #
# -------------------------------------------------------------------------
# clean  : stop containers and remove orphan containers
# fclean : remove containers, images, volumes, persistent data, and empty secrets
# re     : reset everything, ask for new passwords, and reinstall (permanently delete existing WordPress, existing MariaDB data)
# .PHONY : declare targets that are not actual files
# -------------------------------------------------------------------------
clean:
	$(COMPOSE)	down --remove-orphans

# fclean:
# 	$(COMPOSE)	down --rmi all --volumes
# 	rm -rf 		$(DATA_DIR)/mariadb 	$(DATA_DIR)/wordpress
# 	for file in $(SECRET_FILES);	\
# 	do 								\
# 		if [ -f "$$file" ]; 		\
# 		then 						\
# 			: > "$$file"; 			\
# 		fi; 						\
# 	done

fclean:
	$(COMPOSE) down --rmi all --volumes
	docker run --rm -v "$(DATA_DIR):/data" alpine sh -c 'rm -rf /data/mariadb /data/wordpress'
	for file in $(SECRET_FILES); \
	do \
		if [ -f "$$file" ]; then : > "$$file"; fi; \
	done

re: down
	for file in $(SECRET_FILES); \
	do \
		if [ -f "$$file" ]; \
		then \
			: > "$$file"; \
		fi; \
	done
	@$(MAKE) --no-print-directory up

.PHONY: all secrets volumes build up down clean fclean re eval-clean

# ------------------------ CHECK FOR EVAL  ------------------------------------------
# Safely remove all Docker resources for evaluation testing.
# WARNING: This deletes ALL Docker resources on this host.
eval-clean:
	@containers="$$(docker ps -aq)"; \
	if [ -n "$$containers" ]; then \
		docker stop $$containers && docker rm $$containers || exit 1; \
	else \
		echo "No containers to stop or remove."; \
	fi
	@images="$$(docker images -aq)"; \
	if [ -n "$$images" ]; then \
		docker rmi -f $$images || exit 1; \
	else \
		echo "No images to remove."; \
	fi
	@volumes="$$(docker volume ls -q)"; \
	if [ -n "$$volumes" ]; then \
		docker volume rm $$volumes || exit 1; \
	else \
		echo "No volumes to remove."; \
	fi
	@networks="$$(docker network ls -q --filter type=custom)"; \
	if [ -n "$$networks" ]; then \
		docker network rm $$networks || exit 1; \
	else \
		echo "No custom networks to remove."; \
	fi

# ------------------------ CHECK WEBSITE ------------------------------------------
check:
	@echo "Checking WordPress installation..."
	@i=0; until docker exec wordpress wp core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; do \
		i=$$((i + 1)); \
		if [ $$i -ge 30 ]; then \
			echo "ERROR: WordPress is not ready. Check: make logs"; \
			exit 1; \
		fi; \
		sleep 2; \
	done
	@echo "Checking WordPress URLs..."
	@home=$$(docker exec wordpress wp option get home --allow-root --path=/var/www/html 2>/dev/null); \
	if [ "$$home" != "https://localhost:8443" ]; then \
		echo "Updating home URL..."; \
		docker exec wordpress wp option update home 'https://localhost:8443' --allow-root --path=/var/www/html; \
	else \
		echo "Home URL is already correct."; \
	fi
	@siteurl=$$(docker exec wordpress wp option get siteurl --allow-root --path=/var/www/html 2>/dev/null); \
	if [ "$$siteurl" != "https://localhost:8443" ]; then \
		echo "Updating site URL..."; \
		docker exec wordpress wp option update siteurl 'https://localhost:8443' --allow-root --path=/var/www/html; \
	else \
		echo "Site URL is already correct."; \
	fi
	@echo "Checking website..."
	@i=0; ok=0; \
	while [ $$i -lt 10 ]; do \
		code=$$(curl -k -sS -o /dev/null -w '%{http_code}' --max-time 5 https://localhost:8443/ 2>/dev/null || true); \
		case "$$code" in \
			2[0-9][0-9]|3[0-9][0-9]) ok=1; break ;; \
		esac; \
		i=$$((i + 1)); \
		sleep 2; \
	done; \
	if [ $$ok -eq 1 ]; then \
		echo "Website is responding. No restart needed."; \
	else \
		echo "Website is still unavailable. Restarting WordPress and NGINX once..."; \
		docker compose -f srcs/docker-compose.yml restart wordpress nginx; \
		sleep 5; \
		code=$$(curl -k -sS -o /dev/null -w '%{http_code}' --max-time 10 https://localhost:8443/ 2>/dev/null || true); \
		case "$$code" in \
			2[0-9][0-9]|3[0-9][0-9]) echo "Website recovered."; ;; \
			*) echo "ERROR: Website still unavailable (HTTP $$code)."; \
			   echo "Check logs with: make logs"; exit 1 ;; \
		esac; \
	fi


# 	@echo "Checking WordPress website..."
# 	@if ! curl -k -s -f -o /dev/null https://localhost:8443/; then \
# 		echo "Website failed. Restarting WordPress and NGINX..."; \
# 		docker compose -f srcs/docker-compose.yml restart wordpress nginx; \
# 	else \
# 		echo "Website is working."; \
# 	fi