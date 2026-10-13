# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nchairun <nchairun@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/06/11 18:50:34 by nchairun          #+#    #+#              #
#    Updated: 2026/10/13 02:13:20 by nchairun         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# **************************************************************************** #
#                                  VARIABLES                                   #
# **************************************************************************** #
NAME		 = inception
COMPOSE		 = docker compose -f srcs/docker-compose.yml

SECRETS_DIR  = secrets
SECRET_FILES = $(SECRETS_DIR)/db_password.txt \
               $(SECRETS_DIR)/wp_admin_password.txt \
               $(SECRETS_DIR)/wp_user_password.txt

# **************************************************************************** #
#                                    RULES                                     #
# **************************************************************************** #
.SILENT:

all: up

setup-secrets: FORCE
	@for file in $(SECRET_FILES); do \
		if [ -f "$$file" ] && [ ! -s "$$file" ]; then \
			rm -f "$$file"; \
		fi; \
	done
	@$(MAKE) --no-print-directory $(SECRET_FILES)


$(SECRETS_DIR):
	mkdir -p $(SECRETS_DIR)
	chmod 700 $(SECRETS_DIR)

$(SECRETS_DIR)/db_password.txt: | $(SECRETS_DIR)
	bash -c 'umask 077; password=""; \
		while [ -z "$$password" ]; do \
			read -r -s -p "MariaDB user password: " password || exit 1; \
			echo; \
		done; \
		printf "%s" "$$password" > "$@"'

$(SECRETS_DIR)/wp_admin_password.txt: | $(SECRETS_DIR)
	bash -c 'umask 077; password=""; \
		while [ -z "$$password" ]; do \
			read -r -s -p "WordPress admin password: " password || exit 1; \
			echo; \
		done; \
		printf "%s" "$$password" > "$@"'

$(SECRETS_DIR)/wp_user_password.txt: | $(SECRETS_DIR)
	bash -c 'umask 077; password=""; \
		while [ -z "$$password" ]; do \
			read -r -s -p "WordPress second user password: " password || exit 1; \
			echo; \
		done; \
		printf "%s" "$$password" > "$@"'

build: setup-secrets
	$(COMPOSE) build

up: setup-secrets
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

# **************************************************************************** #
#                                   CLEANING                                   #
# **************************************************************************** #
clean:
	$(COMPOSE) down --remove-orphans

fclean:
	$(COMPOSE) down --rmi all --volumes

re: fclean up

FORCE:

.PHONY: all setup-secrets build up down clean fclean re