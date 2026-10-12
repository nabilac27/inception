*This project has been created as part of the 42 curriculum by nchairun.*

<!-- <p align="center">
  <img src="https://www.docker.com/app/uploads/2022/03/Moby-logo.png" width="85" alt="Docker"/>
</p> -->

<h1 align="center">
  Inception
</h1>


## About

Inception is a 42 **system administration project focused on Docker and containerization**.

The goal is to set up a **WordPress** website inside a **virtual machine** using **Docker Compose**.

The infrastructure includes **NGINX**, **WordPress + PHP-FPM**, and **MariaDB**, connected through a **Docker network** with **persistent volumes** for data storage.


<!-- The project includes:

- **NGINX**: Handles HTTPS connections using TLS 1.2 or 1.3.

- **WordPress** + PHP-FPM: Runs the website.

- **MariaDB**: Stores the website's data.

- **Docker network**: Connects the containers.

- **Docker volumes**: Keep data persistent.

Each service runs in its own Docker container, and **Docker Compose** manages the entire setup. -->

## Domain

```bash
  nabilac.42.fr
```


## Project Description
<!--
    A Project description section must also explain the use of Docker and the sources
    included in the project. 
    It must indicate the main design choices, as well as a
    comparison between:
    ◦ Virtual Machines vs Docker
    ◦ Secrets vs Environment Variables
    ◦ Docker Network vs Host Network
    ◦ Docker Volumes vs Bind Mounts
-->
The project uses **Docker** to run each service in its own isolated container. 

Each image is built using a custom **Dockerfile**, and **Docker Compose** manages the containers, networking, volumes, and configuration.

### Infrastructure
- **NGINX**: Handles HTTPS connections using TLS 1.2 or 1.3.

- **WordPress + PHP-FPM**: Runs the website and processes PHP requests.

- **MariaDB**: Stores the website's data.

- **Docker network**: Allows containers to communicate privately.

- **Docker volumes**: Preserve data when containers are recreated.

### Docker Usage

- **Docker** 
  
  is used to run NGINX, WordPress + PHP-FPM, and MariaDB in separate containers. Each container has its own dependencies and configuration.

- **Docker Compose**
  
  manages the containers, networking, volumes, and environment variables, allowing the entire infrastructure to be started with a single command.

### Design Choices
- **Separate containers**
  
  Each service runs independently for better isolation and maintenance.
  
- **Custom Docker images**
- 
  Built from Debian 12 to control dependencies and configurations.

- **NGINX as the entry point**
  
  Only HTTPS port 443 is exposed to the host.

- **Private Docker network**
  
  Services communicate internally without exposing database ports.

- **Persistent storage**
  
  Volumes preserve WordPress and MariaDB data when containers are recreated.

- **Docker secrets**
  
- Passwords are kept separate from general configuration.
  

### Technical Comparisons

- **Virtual Machines (VM) vs Docker**

  VMs run a separate operating system and kernel, while Docker containers share the host's kernel and are more lightweight.
  
  **Virtual Machines**
  - Each VM runs its own guest operating system and kernel.
  - More resource-intensive.
  - Stronger isolation through hardware virtualization.
  
  **Docker Containers**
  - Containers share the host's kernel.
  - Each container packages its application and dependencies.
  - Generally lighter and faster to start
  

  ```shell
            VIRTUAL MACHINES                  DOCKER CONTAINERS

    +-----------------------------+    +-----------------------------+
    |    App A    |    App B      |    |    App A    |    App B      |
    +-------------+---------------+    +-------------+---------------+
    | Libraries   | Libraries     |    | Libraries   | Libraries     |
    +-------------+---------------+    +-------------+---------------+
    | Guest OS    | Guest OS      |    | Container   | Container     |
    +-------------+---------------+    +-------------+---------------+
    |         Hypervisor          |    |        Docker Engine        |
    +-----------------------------+    +-----------------------------+
    |           Host OS           |    |           Host OS           |
    +-----------------------------+    +-----------------------------+
    |           Hardware          |    |           Hardware          |
    +-----------------------------+    +-----------------------------+
  ```

  ```shell
              PHYSICAL COMPUTER
                    |
                    v
             +-------------+
             | Virtual VM  |
             | Debian Linux|
             +-------------+
                    |
                    v
             +-------------+
             |   Docker    |
             +-------------+
                    |
          +---------+---------+
          |         |         |
          v         v         v
       +-------+ +-------+ +-------+
       | NGINX | |WordPress|MariaDB|
       +-------+ +-------+ +-------+

  ```

- **Secrets vs Environment Variables**

  Secrets store sensitive information, while environment variables provide general configuration.

- **Docker Network vs Host Network**

  Docker networks provide isolated networking, while host networking shares the host's network directly.

- **Docker Volumes vs Bind Mounts**

  Volumes are managed by Docker, while bind mounts use specific directories on the host.


### Project Files

```shell
  inception/
  ├── Makefile
  ├── secrets/
  │   ├── db_password.txt
  │   └── ...
  └── srcs/
      ├── docker-compose.yml
      ├── .env
      └── requirements/
          ├── nginx/
          │   ├── Dockerfile
          │   └── conf/
          ├── wordpress/
          │   ├── Dockerfile
          │   ├── conf/
          │   └── tools/
          └── mariadb/
              ├── Dockerfile
              ├── conf/
              │   └── 50-server.cnf
              └── tools/
                  └── init.sh
```

### Files and Directories

- **Makefile**: Automates building, starting, stopping, and cleaning the infrastructure.
- **docker-compose.yml**: Defines and manages the infrastructure.
- **.env**: Stores environment variables.
- **Dockerfile**: Defines how each Docker image is built.
- **conf/**: Contains service configuration files.
- **tools/**: Contains initialization scripts.
- **secrets/**: Contains sensitive credentials.

---

## Instructions

### Prerequisites
- A Linux virtual machine (Debian 12).
- Docker and Docker Compose.
- Make.
- Administrator privileges (sudo).

### Compilation
- Build the Docker images and start the containers using the Makefile:
  
  ```shell
  make
  ```
- Alternatively, use Docker Compose directly:

  ```shell
  docker compose -f srcs/docker-compose.yml up -d --build
  ```

- Once the containers are running, access the WordPress website at:

  ```shell
  https://nchairun.42.fr
  ```

### Installation

1. Install Docker, Docker Compose, and Make on a Linux virtual machine.
2. Configure the environment variables in srcs/.env.
3. Create the required password files in secrets/.
4. Create the directories required for persistent data.


### Execution
<!--

-->


### Submission Requirements
<!--

-->

- Include the Makefile, srcs/docker-compose.yml, Dockerfiles, configuration files, and initialization scripts.
- Include a README.md explaining the project, setup instructions, and design choices.
- Do not commit passwords, secret values, or other sensitive credentials.
- Ensure the infrastructure can be built and started using the Makefile.

---

## Resources
### Documentation
### Docker
- Docker Documentation: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- Dockerfile Reference: https://docs.docker.com/reference/dockerfile/
- Docker Compose File Reference: https://docs.docker.com/reference/compose-file/
- Docker Networking: https://docs.docker.com/network/
- Docker Volumes: https://docs.docker.com/storage/volumes/
- Docker Secrets: https://docs.docker.com/engine/swarm/secrets/

### NGINX
- NGINX Documentation: https://nginx.org/en/docs/
- NGINX Beginner's Guide: https://nginx.org/en/docs/beginners_guide.html

### WordPress
- WordPress Documentation: https://wordpress.org/documentation/
- WP-CLI Documentation: https://developer.wordpress.org/cli/commands/

### PHP
- PHP Manual: https://www.php.net/docs.php
- PHP-FPM Configuration: https://www.php.net/manual/en/install.fpm.php

### MariaDB
- MariaDB Documentation: https://mariadb.com/kb/en/documentation/

### Security
- OpenSSL Documentation: https://docs.openssl.org/
- Mozilla SSL Configuration Generator: https://ssl-config.mozilla.org/

### Linux
- Debian Documentation: https://www.debian.org/doc/

### Articles and Tutorials
<!--

-->

### AI Usage

AI tools were used as learning aids during the development of this project.

- **Understanding concepts**: Clarifying Docker, containerization, networking, and service configuration.
- **Debugging**: Explaining errors and suggesting possible solutions.

- **Documentation**: Improving the grammar, clarity, and structure of the README.

All configurations, scripts, and commands were reviewed, tested, and understood before being used.

---

## Concepts Learned

### Docker

<details>
<summary><strong>Docker Images, Containers, and Docker Compose</strong></summary>

---

  The basic workflow is:

  ```text
  Dockerfile → Build → Image → Run → Container
  ```

In this project, each service has its own Dockerfile, and Docker Compose manages the entire infrastructure.


<details>
<summary><strong>Dockerfile, Image, and Container</strong></summary>

- **Dockerfile:** A file containing instructions for building a Docker image.
- **Docker Image:** A read-only template containing an application, its dependencies, and configuration.
- **Docker Container:** An isolated instance created from an image.

```text
Dockerfile
    |
    | docker build
    v
  Image
    |
    | docker run
    v
 Container
```

One image can be used to create multiple containers.

</details>

---

<details>
<summary><strong>Docker Compose</strong></summary>

Docker Compose is a tool for defining and managing multiple containers using a YAML configuration file (`docker-compose.yml`).

It manages:

- Building Docker images.
- Creating and starting containers.
- Connecting services through networks.
- Attaching persistent volumes.
- Configuring environment variables and secrets.

In Inception, Docker Compose manages **NGINX**, **WordPress**, and **MariaDB** as one infrastructure.

</details>

---

<details>
<summary><strong>Docker Networking</strong></summary>

Docker networks allow containers to communicate without exposing every service to the host.

- Containers communicate using service names through Docker's internal DNS.
- Services communicate through a private Docker bridge network.
- Only NGINX publishes port **443** to the host.

```text
Browser
   |
   | HTTPS :443
   v
 NGINX
   |
   | FastCGI :9000
   v
WordPress + PHP-FPM
   |
   | TCP :3306
   v
 MariaDB
```

The diagram shows the main request flow when PHP-FPM uses TCP port 9000.

</details>

---

<details>
<summary><strong>Docker Volumes</strong></summary>

Docker volumes provide persistent storage independently of the container lifecycle.

Without persistent storage, data written inside a container can be lost when the container is removed.

In Inception:

- **WordPress volume:** Stores website files.
- **MariaDB volume:** Stores database files.

Removing and recreating containers does not remove their named volumes by default.

**Warning:** `docker compose down -v` also removes Compose-managed named volumes and may delete persistent data.

</details>

---

<details>
<summary><strong>Linux Kernel, Namespaces, and Cgroups</strong></summary>

Docker containers share the host's Linux kernel.

Docker uses Linux kernel features to provide isolation and resource management:

- **Namespaces:** Isolate processes, networking, mounts, and other resources.
- **Cgroups:** Organize, track, and limit resource usage.

Unlike virtual machines, Docker containers do not need a separate kernel for each application.

</details>

---

<details>
<summary><strong>PID 1 and Container Lifecycle</strong></summary>

**PID (Process ID)** identifies a running process.

**PID 1** is the main process inside a typical Docker container.

For example, the MariaDB initialization script ends with:

```bash
exec mariadbd --user=mysql
```

The `exec` command replaces the shell process with `mariadbd`, allowing it to become PID 1.

This ensures that:

- Docker sends stop signals directly to the main service.
- The service can shut down cleanly.
- No artificial infinite loop is required to keep the container running.

A container normally stops when its main process exits.

</details>

---

<details>
<summary><strong>Common Docker Commands</strong></summary>

| Command | Description |
|---|---|
| `docker ps` | List running containers. |
| `docker ps -a` | List all containers. |
| `docker images` | List local images. |
| `docker build -t name .` | Build a Docker image. |
| `docker run name` | Create and start a container. |
| `docker exec -it container sh` | Open a shell inside a container. |
| `docker logs container` | Display container logs. |
| `docker compose up -d --build` | Build and start services. |
| `docker compose ps` | Show service status. |
| `docker compose logs` | Display service logs. |
| `docker compose down` | Stop and remove Compose containers and networks. |

</details>
</details>

---

### Database

<details>
<summary><strong>MariaDB and Databases</strong></summary>

---

WordPress uses MariaDB to store posts, pages, users, settings, and other website data.

In this project, MariaDB runs in its own container and communicates with WordPress through the private Docker network using TCP port **3306**.

<details>
<summary><strong>Database, DBMS, and MariaDB</strong></summary>

- **Database:** An organized collection of data.
- **DBMS (Database Management System):** Software used to create, manage, and access databases.
- **RDBMS (Relational Database Management System):** A DBMS that organizes data into related tables.
- **MariaDB:** An open-source relational database management system.
- **SQL (Structured Query Language):** A language used to communicate with relational databases.

In Inception, MariaDB stores WordPress posts, users, comments, settings, and other website data.

```text
WordPress
    |
    | SQL queries over TCP :3306
    v
MariaDB
    |
    v
/var/lib/mysql
    |
    v
Docker Volume
```

</details>

---

<details>
<summary><strong>Databases, Tables, and Relationships</strong></summary>

A relational database organizes data into **tables**, which contain rows and columns.

Example:

**users**

| id | username |
|---|---|
| 1 | alice |
| 2 | bob |

**posts**

| id | author_id | title |
|---|---|---|
| 1 | 1 | Hello World |
| 2 | 2 | My First Blog |

Here, `posts.author_id` refers to `users.id`, illustrating a relationship between tables.

WordPress automatically creates tables such as:

- `wp_users`: Website users.
- `wp_posts`: Posts and pages.
- `wp_comments`: Comments.
- `wp_options`: Website settings.

The `wp_` prefix can be configured.

</details>

---

<details>
<summary><strong>MariaDB vs MySQL</strong></summary>

Both MariaDB and MySQL are relational database management systems.

- **MySQL:** An established open-source relational database system.
- **MariaDB:** A fork of MySQL created in 2009.
- Both support SQL and share many commands and conventions.

In Inception, only **MariaDB** is required.

The internal `mysql` database inside MariaDB stores system information and privileges. It does not mean a separate MySQL server is running.

</details>

---

<details>
<summary><strong>MariaDB Server vs Client</strong></summary>

- **`mariadbd`:** The MariaDB server process that manages databases and handles queries.
- **`mariadb`:** The command-line client used to connect to the server and execute SQL commands.

```text
MariaDB Client
      |
      | SQL queries
      v
MariaDB Server (mariadbd)
      |
      v
Database Files
```

MariaDB supports two common connection methods:

- **TCP port 3306:** Network communication between containers.
- **Unix socket:** Local communication between processes in the same container, commonly through `/run/mysqld/mysqld.sock`.

WordPress connects to MariaDB using TCP through the Docker network.

</details>

---

<details>
<summary><strong>SQL Commands</strong></summary>

SQL is the language used to create, read, modify, and manage relational data.

| Command | Purpose |
|---|---|
| `CREATE` | Create databases, tables, or users. |
| `SHOW` | Display databases, tables, or other information. |
| `SELECT` | Retrieve data. |
| `INSERT` | Add records. |
| `UPDATE` | Modify records. |
| `DELETE` | Remove records. |
| `GRANT` | Assign database permissions. |
| `DROP` | Delete databases or tables. |
| `FLUSH PRIVILEGES` | Reload privilege information when needed. |

Examples:

```sql
SHOW DATABASES;

CREATE DATABASE IF NOT EXISTS wordpress;

CREATE USER 'wpuser'@'%' IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';

USE wordpress;

SHOW TABLES;
```

- `'wpuser'@'%'`: The database account `wpuser`, with `%` representing a wildcard for allowed client hosts.
- `wordpress.*`: All tables in the `wordpress` database.

**Warning:** Destructive SQL commands can permanently delete data. The password shown above is only a placeholder.

</details>

---

<details>
<summary><strong>Linux Users vs MariaDB Users vs WordPress Users</strong></summary>

These are three independent account systems.

| User Type | Example | Purpose |
|---|---|---|
| Linux user | `mysql` | Runs the MariaDB server process. |
| MariaDB user | `wpuser` | Allows WordPress to access its database. |
| WordPress user | `siteowner` | Logs into the WordPress website. |

A MariaDB database account is not the same as a WordPress website account.

The `wpuser` account should have permissions only for the WordPress database, not every database on the server.

</details>

---

<details>
<summary><strong>MariaDB Configuration and Networking</strong></summary>

MariaDB reads configuration files such as:

`/etc/mysql/mariadb.conf.d/50-server.cnf`

Example:

```ini
[mysqld]
bind-address = 0.0.0.0
port = 3306
```

- **`[mysqld]`:** Configuration section for the database server.
- **`bind-address = 0.0.0.0`:** Listens on all available IPv4 network interfaces inside the container.
- **`port = 3306`:** Specifies the TCP listening port.

```text
WordPress Container
        |
        | TCP :3306
        v
MariaDB Container
        |
        v
      mariadbd
```

Because WordPress runs in a separate container, MariaDB must accept connections through its Docker network interface.

Port **3306** is not published to the host, so MariaDB remains accessible through the private Docker network.

</details>

---

<details>
<summary><strong>MariaDB Initialization and Persistent Storage</strong></summary>

MariaDB stores database files in:

`/var/lib/mysql`

This directory is mounted to a named Docker volume:

```yaml
volumes:
  - mariadb_data:/var/lib/mysql
```

When the container starts for the first time:

1. The entrypoint checks whether the database has already been initialized.
2. `mariadb-install-db` initializes the database system files if necessary.
3. The initialization script creates the WordPress database and its database user.
4. MariaDB starts as the main container process.

On subsequent starts, the existing database files are reused.

The Docker volume preserves data when the MariaDB container is removed and recreated.

**Warning:** `docker compose down -v` can delete the database volume and its contents.

</details>

---

<details>
<summary><strong>MariaDB Commands</strong></summary>

Open a MariaDB client as the database root user, using the Linux root identity inside the container:

```bash
docker compose exec -u root mariadb mariadb -u root
```

Useful SQL commands:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT DATABASE();
SELECT VERSION();
SELECT User, Host FROM mysql.user;
EXIT;
```

Useful Docker commands:

| Command | Description |
|---|---|
| `docker compose logs mariadb` | Display MariaDB logs. |
| `docker compose exec mariadb whoami` | Show the Linux user inside the container. |
| `docker compose exec -u root mariadb sh` | Open a root shell inside the container. |
| `docker compose exec mariadb mariadb-admin ping` | Check whether MariaDB responds. |

</details>

</details>

---

### WordPress

<details>
<summary><strong>WordPress and PHP-FPM</strong></summary>

- **WordPress:** An open-source Content Management System (CMS) used to create and manage websites.
- **CMS:** Software that allows users to manage website content without manually writing every page.
- **PHP:** The server-side programming language used by WordPress.
- **PHP-FPM (FastCGI Process Manager):** Manages PHP worker processes that execute PHP scripts.
- **FastCGI:** A protocol used by web servers to communicate with application processes such as PHP-FPM.

In this project, WordPress runs with PHP-FPM in a dedicated container.

When NGINX receives a request for a PHP page, it forwards the request to PHP-FPM using FastCGI. WordPress processes the request, communicates with MariaDB when necessary, and returns the generated response through NGINX.

</details>

---
<!-- 
### NGINX

<details>
<summary><strong>NGINX, HTTPS, and TLS</strong></summary>

- **NGINX:** A web server that handles incoming HTTP and HTTPS requests.
- **HTTP (Hypertext Transfer Protocol):** A protocol used for communication between web browsers and servers.
- **HTTPS:** HTTP communication protected using TLS encryption.
- **TLS (Transport Layer Security):** A protocol that encrypts network communication and helps authenticate servers.
- **SSL/TLS Certificate:** A digital certificate used to establish the server's identity during a TLS connection.
- **Reverse Proxy:** A server that receives client requests and forwards them to another service.

In this project, NGINX is the only publicly accessible service, listening on port **443** and using TLS 1.2 or 1.3.

NGINX serves static files and forwards PHP requests to the WordPress PHP-FPM container.

</details>

---

### TCP and Servers

<details>
<summary><strong>TCP, Ports, and Client-Server Communication</strong></summary>

- **Server:** A program or machine that provides services or resources to clients.
- **Client:** A program that requests services or resources from a server.
- **IP Address:** Identifies a device or network interface on a network.
- **Port:** Identifies a specific network service on a device.
- **TCP (Transmission Control Protocol):** A connection-oriented protocol that provides reliable, ordered delivery of data.
- **Socket:** A communication endpoint used by processes to exchange data.
- **Unix Socket:** Allows processes on the same machine to communicate without using an IP network.
- **DNS (Domain Name System):** Resolves hostnames into IP addresses.

In this project, the services communicate using TCP:

| Communication | Port | Protocol |
|---|---|---|
| Browser → NGINX | 443 | HTTPS over TCP |
| NGINX → PHP-FPM | 9000 | FastCGI over TCP |
| WordPress → MariaDB | 3306 | MariaDB protocol over TCP |

Docker's internal DNS allows containers to communicate using service names such as `wordpress` and `mariadb` instead of hardcoded IP addresses.

Only NGINX's port **443** is published to the host. WordPress and MariaDB remain accessible only through the private Docker network.

</details>
---

<details>
<summary><strong>Docker?</strong></summary>

* Docker is a platform for building, packaging, and running applications inside lightweight, isolated environments called **containers**. 

* Unlike traditional virtual machines, containers share the host operating system's kernel while keeping applications and their dependencies isolated from one another. This makes containers fast to start, portable across different systems, and efficient in resource usage.

* This project uses **Docker Compose** to orchestrate multiple containers that work together as a complete web infrastructure.

</details>

---

<details>
<summary><strong>Project Architecture</strong></summary>

The infrastructure consists of three independent services:

- **NGINX** acts as the only public entry point, serving HTTPS traffic using TLS 1.2/1.3.
- **WordPress + PHP-FPM** runs the web application and processes PHP requests.
- **MariaDB** stores the WordPress database.

The containers communicate through a private Docker bridge network, while persistent data is stored using Docker named volumes.

</details>

---

<details>
<summary><strong>Virtual Machines vs Docker Containers</strong></summary>

| Virtual Machine | Docker Container |
|-----------------|------------------|
| Virtualizes an entire operating system. | Virtualizes only the application and its dependencies. |
| Includes a complete guest OS. | Shares the host kernel. |
| Requires more CPU, memory, and storage. | Lightweight and resource-efficient. |
| Boots in minutes. | Starts in seconds or less. |
| Strong hardware-level isolation. | Process-level isolation. |

Docker containers are preferred in this project because they are lightweight, portable, and ideal for deploying independent services such as NGINX, WordPress, and MariaDB.

</details>

---

<details>
<summary><strong>Docker Secrets vs Environment Variables</strong></summary>

* Environment variables are commonly used to configure applications by providing values such as usernames, ports, or database names.

* Sensitive information like passwords should never be committed to a Git repository or exposed directly through environment variables.

* Docker Secrets provide a more secure approach by storing confidential data as protected files that are mounted into containers only when required.

| Environment Variables | Docker Secrets |
|-----------------------|----------------|
| Suitable for non-sensitive configuration. | Intended for confidential information. |
| Easily visible through container inspection. | Exposed only as protected files inside containers. |
| Convenient for general configuration. | Better suited for passwords and credentials. |

This project stores configuration values in a `.env` file while keeping passwords and sensitive credentials in Docker Secrets.

</details>

---

<details>
<summary><strong>Docker Bridge Network vs Host Network</strong></summary>

Docker provides multiple networking modes.

* A **Bridge Network** creates an isolated virtual network where containers communicate using their service names. Only explicitly published ports are accessible from outside the Docker network.

* A **Host Network** removes network isolation entirely by allowing containers to share the host's networking stack.

| Bridge Network | Host Network |
|----------------|--------------|
| Isolated from the host network. | Shares the host network directly. |
| Containers communicate through Docker DNS. | No network isolation. |
| Only selected ports are exposed. | All services share the host interfaces. |
| Recommended for multi-container applications. | Less secure and forbidden for this project. |

This project uses a custom bridge network so that only NGINX is publicly accessible while WordPress and MariaDB remain private.

</details>

---

<details>
<summary><strong>Docker Volumes vs Bind Mounts</strong></summary>

* Containers are ephemeral, meaning their data disappears when the container is removed unless persistent storage is configured.

* Docker Volumes are managed by Docker and are the recommended solution for persistent application data.

* Bind Mounts directly map an existing host directory into a container.

| Docker Volumes | Bind Mounts |
|----------------|-------------|
| Managed by Docker. | Managed directly by the host filesystem. |
| Portable and independent of host structure. | Depends on a specific host directory. |
| Recommended for persistent application data. | Primarily useful during development. |
| Easier to back up and migrate. | Tightly coupled to the host machine. |

The WordPress files and MariaDB database are stored using **named Docker volumes**, ensuring that data persists even when containers are recreated.

</details> -->
