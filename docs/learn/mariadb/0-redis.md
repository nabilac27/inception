# Redis Cache - Inception Evaluation Cheat Sheet

## 1. What Is Redis?

Redis stands for Remote Dictionary Server.

Redis is an in-memory key-value data store commonly used for caching, session storage, and message processing.

In Inception, Redis is used as an **object cache for WordPress**.

| Component | Purpose |
|-----------|---------|
| Redis | Stores cached data in memory |
| WordPress | Generates website content |
| MariaDB | Stores permanent website data |
| Redis Object Cache plugin | Connects WordPress to Redis |

**Key concept:** Redis improves performance by caching frequently accessed data in memory.

## 2. Why Does WordPress Need Redis?

Without Redis:

```text
Browser
   |
   v
NGINX
   |
   v
WordPress
   |
   | Database query
   v
MariaDB
   |
   | Query result
   v
WordPress
   |
   v
Browser
```

With Redis:

```text
Browser
   |
   v
NGINX
   |
   v
WordPress
   |
   v
Redis Cache
   |
   +-- Cache HIT
   |      |
   |      v
   |   Return cached data
   |
   +-- Cache MISS
          |
          v
       MariaDB
          |
          v
       Return data
          |
          v
       Store in Redis
```

### Cache Hit vs Cache Miss

| Term | Meaning |
|------|---------|
| Cache hit | Requested data already exists in Redis |
| Cache miss | Data is missing and must be retrieved or calculated |
| Cache invalidation | Removing outdated cached data |
| Cache flush | Removing cached entries |

**Key concept:** Redis can reduce repeated database queries.

## WordPress With vs Without Redis Cache

### Without Redis

```text
Browser
   |
   v
NGINX
   |
   v
WordPress + PHP-FPM
   |
   | Repeated database queries
   v
MariaDB
```

WordPress may query MariaDB again for the same data on later requests.

### With Redis

```text
Browser
   |
   v
NGINX
   |
   v
WordPress + PHP-FPM
   |
   v
Redis Object Cache
   |
   +-- CACHE HIT  --> Return cached object
   |
   +-- CACHE MISS --> Query MariaDB
                           |
                           v
                     Cache result in Redis
```

| Without Redis | With Redis |
|---------------|------------|
| More repeated database queries | Reuses cached objects across requests |
| Potentially higher database load | Potentially lower database load |
| Fewer services to configure | Requires Redis and WordPress cache integration |
| MariaDB stores permanent data | MariaDB still stores permanent data |

**Example:** The first request for a post may fetch data from MariaDB and cache reusable objects. A later request may retrieve those objects from Redis without repeating the same database queries.

**Important:** Redis object caching does not automatically cache complete HTML pages or eliminate every MariaDB query.

**Evaluation answer:** Without Redis, WordPress may repeatedly query MariaDB. With Redis, WordPress can reuse frequently accessed objects from memory, reducing database work. MariaDB remains the permanent data store.

## 3. Redis vs MariaDB

| Redis | MariaDB |
|-------|---------|
| In-memory key-value store | Relational database |
| Primarily used for caching | Stores permanent website data |
| Very fast data access | Supports relational SQL queries |
| Data may be temporary | Data persists in database files |
| Default port `6379` | Default port `3306` |

**Important:** Redis does not replace MariaDB.

If Redis becomes unavailable, WordPress should still be able to use MariaDB, although caching may be unavailable.

## 4. Inception Architecture

```text
                 Browser
                    |
                    | HTTPS :443
                    v
                  NGINX
                    |
                    | FastCGI :9000
                    v
               WordPress
                /      \
               /        \
              v          v
        Redis :6379   MariaDB :3306
              |          |
              v          v
         Cache Data   Persistent Data
```

- NGINX handles HTTPS.
- WordPress runs through PHP-FPM.
- MariaDB stores permanent website data.
- Redis caches frequently accessed objects.
- Redis and WordPress communicate through the Docker network.

## 5. Redis Dockerfile

Example using Debian 12:

```dockerfile
FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends redis-server && \
    rm -rf /var/lib/apt/lists/*

CMD ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "yes"]
```

This is a simplified example. Redis protected mode and authentication must be configured consistently with the intended Docker network access.

**Key concept:** Redis must run in the foreground as the container's main process.

## 6. Docker Compose Configuration

```yaml
redis:
  image: redis:inception
  container_name: redis
  build:
    context: ./requirements/bonus/redis
  restart: always
  networks:
    - inception
```

| Configuration | Purpose |
|---------------|---------|
| `image` | Custom Docker image name |
| `container_name` | Container name |
| `build` | Location of Redis Dockerfile |
| `restart: always` | Automatic restart policy |
| `networks` | Internal communication with WordPress |

Redis does not need a publicly published port.

WordPress can connect using:

```text
redis:6379
```

## 7. Redis Configuration

Typical Redis settings:

```conf
bind 0.0.0.0
port 6379
daemonize no
maxmemory 128mb
maxmemory-policy allkeys-lru
```

| Directive | Purpose |
|-----------|---------|
| `bind 0.0.0.0` | Listen on container IPv4 interfaces |
| `port 6379` | Redis TCP port |
| `daemonize no` | Run Redis in foreground |
| `maxmemory` | Set memory limit |
| `maxmemory-policy` | Choose eviction behavior |

`allkeys-lru` approximately evicts least-recently-used keys when Redis reaches its configured memory limit.

**Security:** Keep Redis on a private Docker network and configure authentication or appropriate access restrictions. Do not publish port 6379 publicly.

## 8. WordPress Redis Integration

WordPress needs:

1. A running Redis server.
2. A PHP Redis client extension or compatible library.
3. A WordPress object-cache integration.
4. Redis connection configuration.

### PHP Redis Extension

On Debian:

```bash
apt-get install -y php-redis
```

Check the extension:

```bash
docker exec wordpress php -m | grep -i redis
```

### WordPress Configuration

Example in `wp-config.php`:

```php
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
```

The hostname `redis` is resolved through Docker's internal DNS.

### WordPress Plugin

Using WP-CLI:

```bash
docker exec wordpress wp plugin install redis-cache \
    --activate --allow-root

docker exec wordpress wp redis enable --allow-root
```

This assumes the Redis Object Cache plugin is installed correctly and Redis is reachable.

**Key concept:** Installing Redis alone does not enable WordPress caching. WordPress must be configured to use it.

## 9. Object Cache vs Page Cache

| Object Cache | Page Cache |
|--------------|------------|
| Caches application objects and query results | Caches generated page output |
| Used by WordPress internals | Used to serve complete pages faster |
| Redis is commonly used | NGINX or caching plugins can provide it |

Redis Object Cache stores reusable WordPress application data rather than automatically caching complete HTML pages.

## 10. Does Redis Need a Volume?

For WordPress object caching, Redis usually does not require persistent storage.

Why?

Because cached data can be regenerated from WordPress and MariaDB.

```text
Redis container removed
         |
         v
Cached data lost
         |
         v
Redis restarted
         |
         v
WordPress rebuilds cache
```

**Key concept:** MariaDB requires persistent storage; Redis caching data is normally disposable.

Redis can support persistence through RDB snapshots or AOF, but this is not necessary for a basic WordPress object-cache setup.

## 11. Useful Redis Commands

```bash
# Start Redis
docker compose -f srcs/docker-compose.yml up -d redis

# Check running containers
docker ps

# View Redis logs
docker logs redis

# Test Redis
docker exec redis redis-cli ping

# Redis information
docker exec redis redis-cli info

# Redis memory statistics
docker exec redis redis-cli info memory

# Redis keyspace statistics
docker exec redis redis-cli info keyspace

# Redis cache statistics
docker exec redis redis-cli info stats

# Count cached keys
docker exec redis redis-cli dbsize

# Check WordPress Redis integration
docker exec wordpress wp redis status --allow-root
```

Expected Redis response:

```text
PONG
```

If Redis authentication is enabled, the CLI commands must authenticate.

## 12. How to Verify Redis Actually Works

### Step 1: Check Redis

```bash
docker exec redis redis-cli ping
```

Expected:

```text
PONG
```

### Step 2: Check WordPress Integration

```bash
docker exec wordpress wp redis status --allow-root
```

Confirm the object cache is enabled and connected.

### Step 3: Check Cache Statistics

```bash
docker exec redis redis-cli info stats
```

Look for:

```text
keyspace_hits:...
keyspace_misses:...
```

### Step 4: Generate Website Requests

Visit your WordPress pages several times.

Then check statistics again:

```bash
docker exec redis redis-cli info stats
```

Cache hits should increase when WordPress retrieves reusable cached objects.

**Important:** `PONG` only proves Redis is running. It does not prove WordPress is using Redis.

## 13. Redis and PID 1

Redis should run as the main foreground process.

```text
Docker Container
       |
       v
PID 1: redis-server
```

If starting Redis from an entrypoint script:

```bash
exec redis-server /etc/redis/redis.conf
```

Why use `exec`?

- Replaces the startup shell.
- Makes Redis the main process.
- Allows Docker shutdown signals to reach Redis directly.
- Supports graceful container shutdown.

**Key concept:** Redis should not daemonize itself inside a standard single-service Docker container.

## 14. Redis Security

- Do not expose Redis port 6379 to the public internet.
- Use a private Docker network.
- Configure Redis access controls appropriately.
- Avoid storing sensitive information unnecessarily.
- Limit Redis memory usage.
- Do not hardcode Redis passwords in the Dockerfile.

## 15. Inception Evaluation Questions

**Q: What is Redis?**

Redis is an in-memory key-value data store commonly used for caching.

**Q: Why use Redis with WordPress?**

To cache frequently accessed application data and reduce repeated database queries.

**Q: Does Redis replace MariaDB?**

No. MariaDB stores permanent data, while Redis caches reusable information.

**Q: What is a cache hit?**

When requested data is already available in Redis.

**Q: What is a cache miss?**

When data is not cached and must be retrieved or calculated.

**Q: What port does Redis use?**

TCP port 6379 by default.

**Q: Why doesn't Redis need a volume?**

Because object-cache data can normally be regenerated.

**Q: Why use a WordPress Redis plugin?**

Because WordPress needs an object-cache integration to store and retrieve cached objects through Redis.

**Q: How do you verify Redis works?**

Use `redis-cli ping` to verify the server, then `wp redis status` and cache statistics to verify WordPress integration.

**Q: What does PONG mean?**

Redis is responding to the PING command.

**Q: Why keep Redis inside the Docker network?**

Because only WordPress needs to communicate with Redis, so exposing it publicly is unnecessary.

**Q: Why run Redis in the foreground?**

So Redis remains the container's main process and can handle Docker lifecycle signals.

## 16. Quick Summary

- Redis = Remote Dictionary Server
- Redis = In-memory key-value store
- Object cache = Reusable WordPress application data
- Cache hit = Data found in cache
- Cache miss = Data not found in cache
- Cache invalidation = Removing stale cached data
- `6379` = Default Redis TCP port
- `redis:6379` = Docker internal Redis address
- `php-redis` = PHP Redis extension
- Redis Object Cache = WordPress caching plugin
- `redis-cli ping` = Check Redis availability
- `PONG` = Redis responds
- `wp redis status` = Check WordPress Redis integration
- MariaDB = Permanent website data
- Redis = Temporary cached data
- PID 1 = Main Redis server process

**One-sentence summary:**

Redis runs in a separate Docker container as an in-memory object cache for WordPress, reducing repeated database work while MariaDB remains responsible for permanent website data.