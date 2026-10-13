# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nchairun <nchairun@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/11 18:50:34 by nchairun          #+#    #+#              #
#    Updated: 2026/10/14 00:21:48 by nchairun         ###   ########.fr        #
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
		[ -n "$$password" ] || exit 1; 												\
		umask 077; 																	\
		printf "%s" "$$password" > $(SECRETS_DIR)/db_root_password.txt; 			\
	fi

# ------------------------ MARIADB USER ------------------------
	if [ ! -s $(SECRETS_DIR)/db_password.txt ]; 									\
	then 																			\
		read -r -s -p "[MariaDB]   user password  : " password || exit 1; echo; 	\
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
	$(MAKE) up

.PHONY: all secrets volumes build up down clean fclean re