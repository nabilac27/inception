# Docker Compose Environment Variables: `.env` and `env_file`

Reference video: https://www.youtube.com/watch?v=Xpk82bWEBbw

## 1. The Big Picture

``` text
Environment variables
        |
        ├── .env       <- file containing configuration values
        ├── env_file   <- Compose passes variables into a container
        └── $VARIABLE  <- a shell script reads a variable
```

`.env` defines configuration. Docker Compose can pass those values into
a container, and `init.sh` can use them to create and configure the
database.

## 2. How the Values Reach MariaDB

Example `srcs/.env`:

``` dotenv
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
```

``` text
srcs/.env
    |
    | MYSQL_DATABASE=wordpress
    | MYSQL_USER=wpuser
    v
docker-compose.yml
    |
    | env_file:
    |   - .env
    v
MariaDB container
    |
    v
init.sh reads the variables
    |
    v
Create database "wordpress" and user "wpuser"
```

In `docker-compose.yml`:

``` yaml
services:
  mariadb:
    env_file:
      - .env
```

The `env_file` setting tells Docker Compose to load the specified file
and pass its variables into the service container.

Inside `init.sh`, a shell script can read the values:

``` sh
$MYSQL_DATABASE
$MYSQL_USER
```

Instead of hardcoding `CREATE DATABASE wordpress;`, the script can use
the configured database name. If the value changes to `my_blog`, the
script can use that value without changing the script itself.

## 3. Why Use an `.env` File?

An `.env` file keeps configuration separate from application code.
Instead of repeating values in `Dockerfile`, `init.sh`, and
`docker-compose.yml`, configuration values can be maintained in one
place.

``` dotenv
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
```

This also supports the Inception subject's requirement to use
environment variables and an `.env` file.

**Remember:** - `.env` stores configuration values. - `env_file` passes
variables into a container. - A program or script inside the container
can read those variables. - Passwords and other sensitive values should
be handled securely, for example with Docker secrets, and must not be
committed to Git.

## 4. Inspect Environment Variables in a Container

``` bash
docker exec mariadb env
```

Command breakdown:

``` text
docker exec <container> <command>
            |           |
            |           └── Command to run inside the container
            └────────────── Running container's name
```

-   `docker exec` runs a command inside an already-running container.
-   `mariadb` is the container name.
-   `env` prints the environment variables available to that process.

  Variable           Meaning
  ------------------ ---------------------------------------------------
  `PATH`             Directories Linux searches when locating commands
  `HOSTNAME`         The container's hostname
  `HOME`             The current user's configured home directory
  `MYSQL_DATABASE`   Database name, if passed into the container
  `MYSQL_USER`       Database username, if passed into the container

### `PATH`

`PATH` tells Linux where to search for executable commands. When a
script runs `mariadbd`, Linux searches the directories listed in `PATH`.

### `HOSTNAME`

`HOSTNAME` is the container's hostname. Docker commonly sets it based on
the container's identity unless configured otherwise.

### `MYSQL_DATABASE` and `MYSQL_USER`

If Compose uses `env_file: .env`, the container can receive these
variables. The initialization script can then read `$MYSQL_DATABASE` and
`$MYSQL_USER`.

### `HOME`

`HOME` indicates the current user's configured home directory. Service
accounts inside containers may use `/nonexistent` rather than a normal
interactive user's home directory.

## 5. `.env`, `env_file`, and Shell Variables

  -----------------------------------------------------------------------
  Term                                Purpose
  ----------------------------------- -----------------------------------
  `.env`                              A file Docker Compose can use for
                                      variable interpolation in the
                                      Compose file

  `env_file:`                         A Compose service setting that
                                      passes variables from a file into
                                      the container

  `$VARIABLE`                         Shell syntax for reading an
                                      environment variable in a script

  `environment:`                      A Compose service setting for
                                      explicitly defining or overriding
                                      container environment variables

  Docker secrets                      A mechanism for providing sensitive
                                      values without putting them
                                      directly in ordinary
                                      environment-variable configuration
  -----------------------------------------------------------------------

## 6. Current Progress Checklist

-   [x] `.env` defines configuration variables.
-   [x] Docker Compose has an `env_file` entry.
-   [x] The MariaDB container can receive environment variables.
-   [ ] Verify that `init.sh` reads the intended variables.
-   [ ] Verify that the initialization script creates the database and
    application user using those values.
-   [ ] Verify that sensitive credentials are provided through Docker
    secrets and are not committed to Git.

## Important Project Note

Use the variable names that your actual project expects. For example, if
your `docker-compose.yml` and `init.sh` use `MARIADB_DATABASE` and
`MARIADB_USER`, keep those names consistent instead of switching to
`MYSQL_DATABASE` and `MYSQL_USER` from a generic example.

The essential flow is:

``` text
.env
  |
  v
docker-compose.yml
  |
  v
MariaDB container receives variables
  |
  v
init.sh reads the variables
  |
  v
Database and application user are created
```
