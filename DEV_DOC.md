# Developer Documentation

## 1. Environment Setup

**Prerequisites:** Debian/Linux VM, Docker Engine, Docker Compose, Make, Git, and permission to run Docker.

- Clone the repository:

    ```bash
    git clone <repository-url>
    cd inception
    ```

- Configure `srcs/.env`:

    ```dotenv
    MARIADB_DATABASE=wordpress
    MARIADB_USER=wp_user

    DOMAIN_NAME=nchairun.42.fr
    WP_TITLE=INCEPTION

    WP_ADMIN_USER=nchairun
    WP_ADMIN_EMAIL=nchairun@example.com

    WP_USER=user
    WP_USER_EMAIL=user@example.com
    ```

- The main project files are:

    ```bash
    | Path                      | Purpose                                           |
    | ------------------------- | ------------------------------------------------- |
    | `Makefile`                | Builds, starts, stops, and cleans the stack       |
    | `srcs/docker-compose.yml` | Defines services, networks, volumes, and secrets  |
    | `srcs/.env`               | Stores non-sensitive configuration                |
    | `srcs/requirements/`      | Contains Dockerfiles, configurations, and scripts |
    | `secrets/`                | Stores local passwords and credentials            |
    ```

- **Secrets:** 
  
    Secrets are mounted inside the relevant containers at `/run/secrets/`. Never commit them to Git.

  The Makefile prompts for missing passwords and generates:

  - `secrets/db_root_password.txt` for the MariaDB root password.
  - `secrets/db_password.txt` for the WordPress database user password.
  - `secrets/credentials.txt` for WordPress administrator and author passwords.


## 2. Build and Launch

- Run from the repository root:

    ```bash
    make          # Prepare directories, generate missing secrets, build and start
    make down     # Stop and remove containers while preserving data
    make re       # Rebuild and restart the stack
    ```

- Alternatively, use Docker Compose directly after preparing the secrets and data directories:

    ```bash
    # Build images
    docker compose -f srcs/docker-compose.yml build

    # Start containers
    docker compose -f srcs/docker-compose.yml up -d

    # Stop containers
    docker compose -f srcs/docker-compose.yml down
    ```

- The website is available at `https://nchairun.42.fr` when the domain resolves to the VM and TCP port `443` is accessible.

## 3. Container and Volume Management

- The stack contains NGINX, WordPress, MariaDB, Redis, Adminer, and GoAccess. The static website is served by NGINX.
  
    ```bash
    # List container status
    docker compose -f srcs/docker-compose.yml ps

    # View container logs
    docker compose -f srcs/docker-compose.yml logs -f

    # Restart WordPress
    docker compose -f srcs/docker-compose.yml restart wordpress

    # Rebuild WordPress
    docker compose -f srcs/docker-compose.yml up -d --build wordpress

    # Open a WordPress container shell
    docker exec -it wordpress bash

    # List Docker volumes
    docker volume ls

    # Inspect WordPress mounts
    docker inspect wordpress --format '{{json .Mounts}}'

    # List Docker networks
    docker network ls
    ```


- **Warning:** `make fclean` and volume-removal commands may delete persistent project data. Back up important data before running them.

## 4. Data Storage and Persistence

- MariaDB and WordPress use named Docker volumes backed by host directories.

    ```bash
    | Service   | Host Directory     | Container Directory |
    |-----------|--------------------|---------------------|
    | MariaDB   | `~/data/mariadb`   | `/var/lib/mysql`    |
    | WordPress | `~/data/wordpress` | `/var/www/html`     |
    ```

- NGINX logs and GoAccess reports use additional Docker-managed named volumes.

- The host directories are created by the Makefile. Persistent volumes retain data when containers are stopped, removed, or rebuilt.

- To verify persistence:

    1. Run `make up` and create a WordPress post.
    2. Run `make down`.
    3. Run `make up` again.
    4. Verify that the post still exists.

- `make down` preserves persistent data. Full cleanup may remove it.