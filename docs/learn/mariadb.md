## MariaDB

MariaDB is a relational database management system (RDBMS) used by WordPress to store website content, user accounts, comments, and configuration settings.

### 1. Server vs. Client

| Component | Responsibility |
|:----------|:---------------|
| `mariadbd` | Database server that processes queries and manages data |
| `mariadb` | Command-line client used to connect to the server and execute SQL queries |

### 2. Architecture

```text
WordPress ──┐
            ├──> MariaDB Server (mariadbd) ──> Database Volume
Adminer ────┘
```

- **WordPress:** Reads and writes website data.
- **Adminer:** Provides a web interface for database management.
- **MariaDB:** Stores and retrieves data.
- **Docker volume:** Persists database files beyond the container's lifecycle.

### 3. Database Configuration

| Setting | Value |
|:--------|:------|
| Database | `wordpress` |
| Application user | `wp_user` |
| Service name | `mariadb` |
| Default MySQL/MariaDB port | `3306` |
| Data directory | `/var/lib/mysql` |
| Persistent volume | `mariadb_data` |

Credentials are supplied through environment variables and Docker secrets rather than hardcoded passwords.

### 4. Useful Commands

<details>
<summary><strong>Database Access</strong></summary>

```bash
# Connect using the application user
docker exec -it mariadb mariadb -u wp_user -p wordpress

# Show databases
SHOW DATABASES;

# Select the WordPress database
USE wordpress;

# List tables
SHOW TABLES;

# Inspect WordPress posts
SELECT ID, post_title FROM wp_posts;

# Exit the client
EXIT;
```

</details>

<details>
<summary><strong>Docker Management</strong></summary>

```bash
# Check running containers
docker ps

# View MariaDB logs
docker logs mariadb

# Check database tables using WP-CLI
docker exec wordpress wp db check --allow-root

# Inspect MariaDB container processes
docker exec mariadb ps
```

</details>

### 5. Persistence and Security

- **Persistence:** The `mariadb_data` volume stores database files outside the container's writable layer.
- **Networking:** WordPress and Adminer connect to the `mariadb` service through the Docker network.
- **Credentials:** Docker secrets provide sensitive passwords to the relevant services.
- **Least privilege:** WordPress should use `wp_user` rather than the database root account.
- **Port exposure:** Port `3306` does not need to be published to the host when services communicate through the internal Docker network.

### 6. Concepts Learned

- Relational databases and SQL.
- Database servers versus command-line clients.
- Database users, permissions, and authentication.
- Docker networking and service discovery.
- Persistent volumes and data durability.
- Environment variables and Docker secrets.
- Database integration with WordPress and Adminer.
### 7. Database Initialization Flow

During the first startup, the initialization script starts MariaDB temporarily to configure the database before launching the final server.

```text
mariadbd --skip-networking &
        |
        v
Temporary server 🔧
        |
        v
mariadb client sends SQL commands
        |
        v
Database, wordpress user, and permissions created
        |
        v
Temporary server stops
        |
        v
exec mariadbd
        |
        v
Final server, PID 1 🚀
```

#### Why Start MariaDB Twice?

**First start: Temporary initialization server**

```bash
mariadbd --skip-networking &
```

- Starts MariaDB in the background.
- `--skip-networking` disables TCP/IP connections during initialization.
- The initialization script connects through the local Unix socket using the `mariadb` client.
- SQL commands create the WordPress database, application user, and required permissions.
- The temporary server is stopped after initialization finishes.

**Second start: Final database server**

```bash
exec mariadbd
```

- Starts MariaDB as the container's main process.
- `exec` replaces the initialization shell process rather than leaving it as a parent process.
- MariaDB becomes PID 1 inside the container.
- The server stays in the foreground and keeps the container running.
- Running the main process directly helps Docker deliver signals correctly during shutdown.

#### Mental Model

| Stage | Purpose |
|:------|:--------|
| Temporary server | Initialize and configure the database |
| MariaDB client | Execute SQL commands against the temporary server |
| Shutdown | Stop the temporary server cleanly |
| `exec mariadbd` | Launch the final server as PID 1 |
| Final server | Handle WordPress and Adminer database connections |

**Key takeaway:** The first server prepares the database; the second server runs it for the lifetime of the container. The initialization script must wait for the temporary server to become ready before executing SQL, then stop it cleanly before launching the final server.