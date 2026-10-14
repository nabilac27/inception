# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nchairun <nchairun@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/10/14 08:04:23 by nchairun          #+#    #+#              #
#    Updated: 2026/10/14 08:06:14 by nchairun         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# **************************************************************************** #
#	VARIABLES                                                                  #
# **************************************************************************** #
NAME         := inception
SHELL        := /bin/bash
.SHELLFLAGS  := -eu -o pipefail -c

.ONESHELL:
.DEFAULT_GOAL := all

COMPOSE      := docker compose -f srcs/docker-compose.yml
DATA_DIR     := $(HOME)/data
SECRETS_DIR  := secrets
SECRET_FILES := $(SECRETS_DIR)/db_root_password.txt \
                $(SECRETS_DIR)/db_password.txt \
                $(SECRETS_DIR)/credentials.txt

# **************************************************************************** #
#	RULES                                                                      #
# **************************************************************************** #
.PHONY: all secrets volumes build up down clean fclean re check logs

all: up

# ------------------------ SECRETS --------------------------------------------

secrets:
	mkdir -p "$(SECRETS_DIR)"
	chmod 700 "$(SECRETS_DIR)"
	umask 077

	if [[ ! -s "$(SECRETS_DIR)/db_root_password.txt" ]]; then
		read -r -s -p "[MariaDB]   root password  : " password
		printf '\n'
		if [[ -z "$$password" ]]; then
			echo "Exit, passwords can't be blank" >&2
			exit 1
		fi
		printf '%s' "$$password" > "$(SECRETS_DIR)/db_root_password.txt"
	fi

	if [[ ! -s "$(SECRETS_DIR)/db_password.txt" ]]; then
		read -r -s -p "[MariaDB]   user password  : " password
		printf '\n'
		if [[ -z "$$password" ]]; then
			echo "Exit, passwords can't be blank" >&2
			exit 1
		fi
		printf '%s' "$$password" > "$(SECRETS_DIR)/db_password.txt"
	fi

	if [[ ! -s "$(SECRETS_DIR)/credentials.txt" ]]; then
		read -r -s -p "[WordPress] admin password : " admin
		printf '\n'
		if [[ -z "$$admin" ]]; then
			echo "Exit, passwords can't be blank" >&2
			exit 1
		fi

		read -r -s -p "[WordPress] author password: " author
		printf '\n'
		if [[ -z "$$author" ]]; then
			echo "Exit, passwords can't be blank" >&2
			exit 1
		fi

		printf 'WP_ADMIN_PASSWORD=%q\nWP_AUTHOR_PASSWORD=%q\n' \
			"$$admin" "$$author" > "$(SECRETS_DIR)/credentials.txt"
	fi

# ------------------------ VOLUMES --------------------------------------------

volumes:
	mkdir -p "$(DATA_DIR)/mariadb" "$(DATA_DIR)/wordpress"

# ------------------------ DOCKER ---------------------------------------------

build: secrets
	$(COMPOSE) build

up: secrets volumes
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

# **************************************************************************** #
#	CLEANING                                                                   #
# **************************************************************************** #
# Stop containers and remove orphans. Persistent data is preserved.
clean:
	$(COMPOSE) down --remove-orphans

# WARNING: permanently deletes Docker volumes, persistent data, and saved secrets.
fclean:
	$(COMPOSE) down --rmi all --volumes
	docker run --rm -v "$(DATA_DIR):/data" alpine sh -c 'rm -rf /data/mariadb /data/wordpress'
	for file in $(SECRET_FILES); do
		if [[ -f "$$file" ]]; then : > "$$file"; fi
	done

# WARNING: clears saved secrets and asks for new passwords.
# Persistent data is preserved.
re: down
	for file in $(SECRET_FILES); do
		if [[ -f "$$file" ]]; then : > "$$file"; fi
	done
	$(MAKE) --no-print-directory up

# **************************************************************************** #
#	CHECKS AND LOGS                                                            #
# **************************************************************************** #
check:
	@echo "Checking WordPress installation..."
	@if ! docker exec wordpress wp core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; then \
		echo "ERROR: WordPress is not installed or the container is not ready."; \
		echo "Check logs with: make logs"; \
		exit 1; \
	fi
	@echo "WordPress is installed."
	@echo "Checking website at https://localhost:8443/ ..."
	@code=$$(curl -k -sS -o /dev/null -w '%{http_code}' --max-time 10 https://localhost:8443/ 2>/dev/null || true); \
	case "$$code" in \
		2[0-9][0-9]|3[0-9][0-9]) echo "Website responded with HTTP $$code."; ;; \
		*) echo "ERROR: Website returned HTTP $$code."; echo "Check logs with: make logs"; exit 1 ;; \
	esac

logs:
	$(COMPOSE) logs --tail=50