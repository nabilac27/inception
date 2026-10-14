# Adminer

Adminer is a lightweight, web-based database management tool. In the
Inception project, it provides a graphical interface for inspecting and
managing the MariaDB database used by WordPress.

## 1. Features

-   Manage databases through a browser.
-   Connect to MariaDB using database credentials.
-   Browse databases, tables, and records.
-   Execute SQL queries.
-   Inspect and modify database structures and data.
-   Run in its own Docker container, separate from MariaDB and
    WordPress.

## 2. Architecture

``` text
Browser
   |
   v
NGINX (HTTPS)
   |
   v
Adminer container
   |
   v
MariaDB container
   |
   v
WordPress database
```

Adminer connects to MariaDB over the Docker network. It manages the
existing database and does not need a separate database of its own.

## 3. Docker Compose Configuration

Example service definition:

``` yaml
adminer:
  image: adminer:inception
  container_name: adminer
  restart: always
  build:
    context: ./requirements/adminer
  networks:
    - inception
  depends_on:
    - mariadb
```

-   `build.context` points to the directory containing the Adminer
    Dockerfile.
-   `networks` connects Adminer to the internal `inception` network.
-   `depends_on` establishes startup ordering, but does not by itself
    guarantee that MariaDB is ready to accept connections.
-   No host port is published in this example. Browser access depends on
    how NGINX is configured to route requests to Adminer.

## 4. Database Login

  Field      Value
  ---------- ---------------------------------------
  System     MySQL
  Server     `mariadb`
  Username   `wp_user`
  Password   The password configured for `wp_user`
  Database   `wordpress`

Use the database application's username and password, not the MariaDB
root password, when connecting as `wp_user`.

The server field is `mariadb` because Docker's internal DNS resolves the
service/container name on the shared network.

## 5. Useful Commands

``` bash
# Start Adminer and its dependencies
docker compose -f srcs/docker-compose.yml up -d adminer

# List running containers
docker ps

# View Adminer logs
docker logs adminer

# Stop Adminer
docker compose -f srcs/docker-compose.yml stop adminer
```

## 6. Concepts Learned

-   **Adminer:** Browser-based database administration.
-   **MariaDB:** Relational database management.
-   **SQL:** Querying and modifying database records.
-   **Docker Compose:** Defining and running multiple services.
-   **Docker networking:** Connecting containers using service names.
-   **Docker secrets:** Supplying sensitive credentials to services.
-   **Service separation:** Running a database management interface
    independently from the database server.

## 7. Security Considerations

-   Do not publish the MariaDB port to the host unless necessary.
-   Use strong database passwords and avoid routine use of the root
    account.
-   Restrict Adminer access to the intended network and web route.
-   Remember that Adminer can change or delete database content.
-   Do not commit passwords or other secrets to Git.

## 8. Inception Notes

Adminer is an additional service, not a replacement for MariaDB. MariaDB
stores the data; Adminer provides a graphical interface to inspect and
manage it. WordPress connects directly to MariaDB for normal website
operations.

If Adminer is running but cannot be opened in a browser, check the NGINX
routing configuration and confirm that the Adminer container shares the
`inception` network with MariaDB.
