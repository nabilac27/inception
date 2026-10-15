# Developer Documentation

## 1. Environment Setup

### Prerequisites

- Before setting up the project, ensure the following tools are installed:

  - **Docker Engine**
  - **Docker Compose**
  - **Make**
  - **Git**


### Clone the Repository

- Clone the project and navigate to its root directory:

    ```bash
    git clone <repository-url>
    cd inception
    ```

### Configuration Files

- The project uses the following configuration files:

    ```bash
    | File                 | Purpose                                                          |
    |----------------------|------------------------------------------------------------------|
    | `Makefile`           | Builds, starts, stops, and cleans the project                    |
    | `srcs/docker-compose.yml` | Defines Docker services, networks, and volumes              |
    | `srcs/.env`          | Stores environment variables and service configuration           |
    | `srcs/requirements/` | Contains Dockerfiles, configuration files, initialization scripts|
    | `secrets/`           | Stores sensitive credentials outside Docker images               |
    ```

- Create or update `srcs/.env` with the required environment variables:

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

### Secrets Configuration

- Create the secrets directory if it does not already exist:

    ```bash
    mkdir -p secrets
    chmod 700 secrets
    ```

- The project requires the following secret files:

    ```bash
    | File                           | Purpose                                            |
    |--------------------------------|----------------------------------------------------|
    | `secrets/db_root_password.txt` | MariaDB root password                              |
    | `secrets/db_password.txt`      | MariaDB WordPress user password                    |
    | `secrets/credentials`          | WordPress administrator and regular user passwords |
    ```

- The `credentials` file contains shell variables used by the WordPress initialization script:

    ```bash
    WP_ADMIN_PASSWORD='your_admin_password'
    WP_USER_PASSWORD='your_user_password'
    ```

    Replace the example passwords with secure values.

- If the Makefile provides a `secrets` target, run `make secrets` to generate the files instead of creating them manually.

**Security:** Keep secret files out of Git. Docker mounts the required secrets inside containers under `/run/secrets/`.

## 2. Building and Launching the Project

### Build Docker Images

- From the project root:

    ```bash
    make build
    ```

    This builds the Docker images using the Dockerfiles in `srcs/requirements/`.

### Start the Project

- This prepares the required directories, builds the images, and starts the services.

    ```bash
    make up
    ```

### Stop the Project

- This removes the containers and network while preserving named volumes.
  
    ```bash
    make down
    ```


### Restart the Project

- Rebuild and restart the project
  

    ```bash
    make down
    make up
    ```

**Note:** Avoid using `make re` for a normal restart if it depends on `fclean`, because that may delete persistent data.

## 3. Managing Containers and Volumes

### Container Management

- The following commands can be used to manage and troubleshoot Docker containers.
  
    ```shell
    | Action                 | Command                                                              |
    |------------------------|----------------------------------------------------------------------|
    | List containers        | `docker compose -f srcs/docker-compose.yml ps`                       |
    | View logs              | `docker compose -f srcs/docker-compose.yml logs`                     |
    | Follow logs            | `docker compose -f srcs/docker-compose.yml logs -f`                  |
    | Restart a service      | `docker compose -f srcs/docker-compose.yml restart wordpress`        |
    | Rebuild a service      | `docker compose -f srcs/docker-compose.yml up -d --build wordpress`  |
    | Open a container shell | `docker exec -it wordpress bash`                                     |
    | Stop the stack         | `make down`                                                          |
    ```

    Replace `wordpress` with `nginx`, `mariadb`, `redis`, or `adminer` to manage another service.

### Volume Management

- List Docker volumes:

    ```bash
    docker volume ls
    ```

- Inspect a specific volume:

    ```bash
    docker volume inspect <volume-name>
    ```

- List the volumes used by a running container:

    ```bash
    docker inspect wordpress --format '{{json .Mounts}}'
    ```

- Remove containers while preserving volumes:

    ```bash
    make down
    ```

**Warning:** Commands such as `docker compose down --volumes` and `make fclean` may delete persistent project data.

### Network Management

- List Docker networks:

    ```bash
    docker network ls
    ```

- Inspect the project's network:

    ```bash
    docker network inspect <network-name>
    ```

    The services communicate through the private Docker network defined in `srcs/docker-compose.yml`.

## 4. Data Storage and Persistence

### Persistent Data

- The project uses Docker volumes to preserve WordPress and MariaDB data.

    ```shell
    | Service   | Container Path   | Stored Data                                   |
    |-----------|------------------|-----------------------------------------------|
    | MariaDB   | `/var/lib/mysql` | Databases and tables                          |
    | WordPress | `/var/www/html`  | WordPress files, themes, plugins, and uploads |
    ```

### Host Storage

- The project is configured to prepare the following host directories:

    ```text
    ~/data/mariadb/
    ~/data/wordpress/
    ```

- The actual persistent storage location depends on the volume definitions in `srcs/docker-compose.yml`.

- For Docker-managed named volumes, Docker determines the physical storage location. 
  
  Inspect a volume to identify its mount point:

    ```bash
    docker volume inspect <volume-name>
    ```

### Persistence Behavior

- `make down` stops and removes containers without deleting named volumes.
- `make up` recreates containers and reuses existing volumes.
- Rebuilding Docker images does not normally delete persistent volume data.
- `make fclean` may remove volumes and permanently delete stored data.

### Verify Data Persistence

1. Start the project with `make up`.
2. Create a WordPress post or upload a file.
3. Stop the project with `make down`.
4. Restart it with `make up`.
5. Verify that the post or uploaded file still exists.

    If the data remains available, persistence is working correctly.

## 5. Project Structure

```shell
    inception/
    ├── Makefile
    ├── USER_DOC.md
    ├── DEV_DOC.md
    ├── secrets/
    │   ├── db_root_password.txt
    │   ├── db_password.txt
    │   └── credentials
    └── srcs/
        ├── .env
        ├── docker-compose.yml
        └── requirements/
            ├── mariadb/
            ├── nginx/
            ├── wordpress/
            └── bonus/
                ├── redis/
                └── adminer/
```

Each service directory contains its Dockerfile and any required configuration or initialization scripts.


#### Persistent Data Storage

```shell
/
└── home/
    └── nchairun/
        ├── Desktop/
        │   └── inception/
        │       ├── Makefile
        │       ├── USER_DOC.md
        │       ├── DEV_DOC.md
        │       ├── secrets/
        │       │   ├── db_root_password.txt
        │       │   ├── db_password.txt
        │       │   └── credentials
        │       └── srcs/
        │           ├── .env
        │           ├── docker-compose.yml
        │           └── requirements/
        │               ├── mariadb/
        │               │   ├── Dockerfile
        │               │   ├── conf/
        │               │   └── tools/
        │               ├── nginx/
        │               │   ├── Dockerfile
        │               │   ├── conf/
        │               │   └── tools/
        │               ├── wordpress/
        │               │   ├── Dockerfile
        │               │   ├── conf/
        │               │   ├── tools/
        │               │   └── custom-theme/
        │               └── bonus/
        │                   ├── redis/
        │                   │   └── Dockerfile
        │                   └── adminer/
        │                       └── Dockerfile
        │
        └── data/
            ├── mariadb/        # Persistent MariaDB database files
            └── wordpress/      # Persistent WordPress files
```