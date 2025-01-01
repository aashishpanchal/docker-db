# Redis Docker Setup

Easily set up Redis locally using Docker with this repository.

## Quick Start

1. Navigate to the directory `redis` with `docker-compose.yml`.
2. Run Redis in Docker:

   ```bash
   docker-compose up -d
   ```

   - This downloads the Redis image, starts a container named `redis`, and exposes port `6379`.

3. Check Redis is running:

   ```bash
   docker ps
   ```

---

## Configuration

- **Port**: Redis is accessible on `localhost:6379`.
- **Connection String**: Use this URI format to connect to Redis:

  ```
  redis://localhost:6379
  ```

- **Data Persistence**: Local directory `./data/redis` is mapped to `/data` inside the container.
- **Network**: Uses a Docker network `redis-db` for isolation.

---

## Connect to Redis

### Redis CLI

```bash
docker exec -it redis redis-cli
```

### Other Clients

- **Host**: `localhost`
- **Port**: `6379`
- **Connection String**: `redis://localhost:6379`

---

## Stop Redis

```bash
docker-compose down
```

Data remains in `./data/redis`.

---

## Troubleshooting

- **Container not starting**: Check logs with:

  ```bash
  docker logs redis
  ```

- **Port conflict**: Change the `ports` section in `docker-compose.yml` and restart.

---

## Resources

- [Redis Docs](https://redis.io/documentation)
- [Docker Redis](https://hub.docker.com/_/redis)
