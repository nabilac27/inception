# User Documentation

## 1. Services Overview

- Inception is a Docker-based environment that hosts a WordPress website and its supporting services.

    ```text
    | Service        | Description                                               |
    |----------------|-----------------------------------------------------------|
    | NGINX          | Web server providing HTTPS access using TLS 1.2/1.3       |
    | WordPress      | Website and content management system using PHP-FPM       |
    | MariaDB        | Database storing WordPress data                           |
    | Redis          | Object caching for WordPress                              |
    | Adminer        | Web interface for managing the MariaDB database           |
    | Static Website | Additional HTML/CSS website served by NGINX               |
    ```
- All services run in Docker containers and communicate through a private Docker network.

## 2. Starting and Stopping the Project

### Start

- From the project root:
- This builds the Docker images and starts the containers.
  
    ```shell
    make up
    ```


### Stop

- This stops and removes the containers while preserving persistent data.
  
    ```shell
    make down
    ```



### Restart

- Rebuild and restart the project
  
    ```bash
    make up
    make down
    ```

**Note:** Avoid `make fclean` unless you intend to remove project data and reset the environment.

## 3. Accessing the Website

- The local development environment uses the following URLs:

    ```text
    | Page             | URL                                         |
    |------------------|---------------------------------------------|
    | WordPress Home   | https://localhost:8443/                     |
    | Posts            | https://localhost:8443/posts/               |
    | Bonus Services   | https://localhost:8443/bonus/               |
    | WordPress Login  | https://localhost:8443/wp-login.php         |
    | WordPress Admin  | https://localhost:8443/wp-admin/            |
    | Adminer          | https://localhost:8443/bonus-adminer/       |
    | Static Website   | https://localhost:8443/bonus-static-web/    |
    ```


- The configured project domain is `nchairun.42.fr`. URLs may differ when running the project in the evaluation environment.

- A browser may display a certificate warning because the local HTTPS certificate is self-signed.

## 4. Credentials Management

Credentials are stored separately from the Docker images.

### Environment configuration

- This file contains non-secret configuration such as database names, usernames, and the WordPress domain.
  
    ```text
    srcs/.env
    ```


### Passwords and secrets

- Passwords are stored locally in:

    ```text
    secrets/
    ```

- The project uses the following secret files:

    ```text
    | File                   | Purpose                                           |
    |------------------------|---------------------------------------------------|
    | `db_root_password.txt` | MariaDB root password                             |
    | `db_password.txt`      | WordPress database user password                  |
    | `credentials`          | WordPress administrator and regular user passwords |
    ```

- Depending on the project configuration, the secrets directory may be located under `srcs/secrets/`.

- Secrets are mounted inside the appropriate containers under `/run/secrets/`.

- To change credentials, update the corresponding secret files and restart or recreate the affected services. 
- Some passwords may also need to be updated in the database or WordPress itself.

**Security:** Never commit passwords, credentials, or secret files to Git.

## 5. Checking Service Status

### List running containers

- To check the status of all Docker containers:

    ```bash
    docker compose -f srcs/docker-compose.yml ps
    ```

    Expected services:

    - `nginx`
    - `wordpress`
    - `mariadb`
    - `redis`
    - `adminer`


### Check Container Logs

- To view logs from all containers:

    ```bash
    docker compose -f srcs/docker-compose.yml logs
    ```

- To inspect a specific service:

    ```bash
    docker logs nginx
    docker logs wordpress
    docker logs mariadb
    docker logs redis
    docker logs adminer
    ```

### Verify MariaDB

- Check whether the MariaDB server is running:

    ```bash
    docker exec mariadb mariadb-admin ping
    ```

    Expected output:

    ```text
    mysqld is alive
    ```

### Verify WordPress Database

- Check the integrity of the WordPress database:

    ```bash
    docker exec wordpress wp db check --allow-root
    ```

    All WordPress database tables should report `OK`.

### Verify Redis

- Check whether Redis is responding:

    ```bash
    docker exec redis redis-cli ping
    ```

    Expected output:

    ```text
    PONG
    ```

### Verify HTTPS

- Check whether NGINX is responding over HTTPS:

    ```bash
    curl -kI https://localhost:8443/
    ```

    A successful HTTP response indicates that NGINX is accessible over HTTPS.

### Verify Administration Panels

**WordPress Administration**

- Open the following URL:

    ```text
    https://localhost:8443/wp-admin/
    ```

    Log in using the WordPress administrator credentials.

**Adminer Database Administration**

- Open the following URL:

    ```text
    https://localhost:8443/bonus-adminer/
    ```

    Log in using the MariaDB database name, username, and corresponding password.

## 6. Persistent Data

- WordPress files and MariaDB database files are stored in persistent Docker volumes.
- Stopping the project with `make down` preserves these volumes.
- Removing volumes or running a full cleanup may permanently delete website and database data. 
- Back up important data before performing destructive cleanup.