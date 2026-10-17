# User Documentation

## 1. Services Overview

- Inception runs a WordPress website and supporting services using Docker Compose.

    ```bash
    | Service        | Description                                        |
    |----------------|----------------------------------------------------|
    | NGINX          | HTTPS web server using TLS 1.2/1.3                 |
    | WordPress      | Website and content management system with PHP-FPM |
    | MariaDB        | Stores WordPress database data                     |
    | Redis          | WordPress object caching                           |
    | Adminer        | Web-based MariaDB administration                   |
    | Static Website | Additional website served by NGINX                 |
    ```
- All containers communicate through a private Docker network. Only NGINX exposes port `443`.

## 2. Starting and Stopping

- Run the following commands from the repository root:

    ```bash
    make up      # Build and start all services
    make down    # Stop services and preserve persistent data
    make re      # Restart and rebuild the project
    ```

- The first startup prompts for missing passwords and creates the required data directories.

- **Warning:** `make fclean` removes project data and credentials. Back up important data before using it.

## 3. Accessing the Services

- Ensure `nchairun.42.fr` resolves to your VM's IP address.

    ```bash
    | Service        | URL                                         |
    |----------------|---------------------------------------------|
    | WordPress      | https://nchairun.42.fr/                     |
    | WordPress Login| https://nchairun.42.fr/wp-login.php         |
    | WordPress Admin| https://nchairun.42.fr/wp-admin/            |
    | Adminer        | https://nchairun.42.fr/bonus-adminer/       |
    | Static Website | https://nchairun.42.fr/bonus-static-web/    |
    ```

- A browser warning may appear because the HTTPS certificate is self-signed.

## 4. Credentials Management

- Non-sensitive configuration is stored in `srcs/.env`. Passwords are stored in the root `secrets/` directory and mounted into containers through `/run/secrets/`.

    ```bash
    | File                   | Purpose                                      |
    |------------------------|----------------------------------------------|
    | `db_root_password.txt` | MariaDB root password                        |
    | `db_password.txt`      | WordPress database user password             |
    | `credentials.txt`      | WordPress administrator and author passwords |
    ```
- The Makefile creates missing secret files during initial setup.

- To change passwords, update the corresponding secret files and recreate the affected containers. Existing database or WordPress passwords may also need to be synchronized.

- **Security:** Never commit passwords or secret files to Git.

## 5. Checking Service Status

- Run these commands from the repository root:

    ```bash
    # List all services and their status
    docker compose -f srcs/docker-compose.yml ps

    # View container logs
    docker compose -f srcs/docker-compose.yml logs

    # Check MariaDB
    docker exec mariadb mariadb-admin ping

    # Check WordPress database
    docker exec wordpress wp db check --allow-root

    # Check Redis
    docker exec redis redis-cli ping

    # Check WordPress Redis cache
    docker exec wordpress wp redis status --allow-root

    # Verify NGINX configuration
    docker exec nginx nginx -t

    # Verify HTTPS connectivity
    curl -kI https://nchairun.42.fr
    ```

- MariaDB should respond with `mysqld is alive`, Redis with `PONG`, and HTTPS with a valid HTTP response.

- You can also check WordPress and Adminer by opening their administration URLs and logging in.

## 6. Persistent Data

- WordPress and MariaDB use persistent Docker volumes backed by directories under `~/data/`.

    - `~/data/wordpress` stores WordPress files.
    - `~/data/mariadb` stores database files.

- `make down` preserves this data. Full cleanup commands may permanently delete it.