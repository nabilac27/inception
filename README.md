*This project has been created as part of the 42 curriculum by nchairun.*

<p align="center">
  <img src="https://www.docker.com/app/uploads/2022/03/Moby-logo.png" width="85" alt="Docker"/>
</p>

<h1 align="center">
  Inception
</h1>

## Description

Inception is a 42 system administration project that deploys a WordPress website inside a Linux virtual machine using Docker Compose. Each service runs in its own container, built from a custom Debian-based Dockerfile.

- **Architecture** 
  
  
  Browser → NGINX (HTTPS, port 443) → WordPress (PHP-FPM, port 9000) → MariaDB (port 3306). 
  
  All containers communicate over a private Docker bridge network; only NGINX publishes a host port. 
  
  Named volumes persist WordPress files and MariaDB data under `~/data/`.

- **Services** 
  
  NGINX (TLS 1.2/1.3), WordPress/PHP-FPM, MariaDB, Adminer (database administration). NGINX also serves a static bonus website.

- **Sources**
  
  srcs/docker-compose.yml defines the infrastructure
  
  srcs/.env stores configuration
  
  srcs/requirements/ contains the Dockerfiles, service configurations, initialization scripts, and website files.

### Design Choices

- **Isolation**: Separate containers for each service.

- **Security**: NGINX exposes only HTTPS port 443 with TLS 1.2/1.3.

- **Networking**: A custom bridge network connects the services.

- **Persistence**: Named volumes backed by host directories store WordPress and MariaDB data.

- **Credentials**: Docker secrets store passwords separately from environment variables.

### Technical Comparisons 

```shell
| Technology                    | Comparison                                      |
|-------------------------------|-------------------------------------------------|
| VMs vs Docker                 | VMs have separate kernels; containers share     |
|                               | the host kernel and use fewer resources.        |
|-------------------------------|-------------------------------------------------|
| Secrets vs Environment Vars   | Secrets store passwords; environment variables  |
|                               | store general configuration.                    |
|-------------------------------|-------------------------------------------------|
| Docker vs Host Network        | Bridge networks isolate containers; host        |
|                               | networking shares the host network.             |
|-------------------------------|-------------------------------------------------|
| Volumes vs Bind Mounts        | Volumes are Docker-managed; bind mounts map     |
|                               | host directories.                               |
```
### Project files

- `Makefile`: setup, build, start, stop, and cleanup commands.
- `srcs/docker-compose.yml`: services, network, volumes, and secrets.
- `srcs/.env`: non-sensitive configuration (create locally; do not commit).
- `srcs/requirements/`: Dockerfiles, configurations, initialization scripts, and bonus services.
- `secrets/`: locally generated password files (never commit).

## Instructions

**Requirements:** Linux VM, Docker Engine, Docker Compose, Make, and permission to run Docker.

1. Clone the repository and configure `srcs/.env` with your database, domain, WordPress settings. 

3. Configure the domain and network:
   - Inside the VM, run `hostname -I` to find its IP address. Example of \<VP_IP\> :

      ```bash
      192.168.1.100
      ```

   - On the machine running your browser, open `/etc/hosts` with `sudo nano /etc/hosts`, add:

     ```bash
     <VM_IP> nchairun.42.fr
     ```



4. From the repository root, run:
   ```bash
   make
   ```
   The Makefile creates persistent data directories, prompts for missing passwords, builds the images, and starts the containers.

5. Visit **https://nchairun.42.fr**. 
   
   A browser warning is expected because the TLS certificate is self-signed.

- **Verification:**

   ```bash
      # Check the status of all Docker containers
      docker compose -f srcs/docker-compose.yml ps

      # Verify HTTPS connectivity
      curl -kI https://nchairun.42.fr
   ```
- **Useful commands**:

   ```bash
      make                 # Build and start
      make down            # Stop containers
      make re              # Restart and rebuild, keeping data
      make check-wordpress # Check WordPress and HTTPS
      make check-tls       # Check NGINX TLS configuration
   ```

   **Caution:** `make fclean` removes Docker resources, locally generated secrets.

## Resources

- [Docker and Docker Compose documentation](https://docs.docker.com/)
- [Docker networking](https://docs.docker.com/engine/network/) and [volumes](https://docs.docker.com/engine/storage/volumes/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress documentation](https://wordpress.org/documentation/) and [WP-CLI commands](https://developer.wordpress.org/cli/commands/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [Adminer documentation](https://www.adminer.org/en/)
- [Debian documentation](https://www.debian.org/doc/)

### AI Usage

AI was used as a learning and development aid to:

- Clarify Docker, networking, TLS, and service configuration concepts.
- Troubleshoot Docker build, configuration, and runtime errors.
- Review Dockerfiles and initialization scripts for potential issues.
- Improve the clarity, grammar, and structure of this README.

All suggested solutions were reviewed, adapted, and tested during development.