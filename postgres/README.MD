# PostgreSQL Docker Setup

Easily set up PostgreSQL locally using Docker with this repository.

## Quick Start

1. Navigate to the directory `postgres` with `docker-compose.yml`.
2. Run PostgreSQL in Docker:

   ```bash
   docker-compose up -d
   ```

   - This downloads the PostgreSQL image, starts a container named `postgres`, and exposes port `5432`.

3. Check PostgreSQL is running:

   ```bash
   docker ps
   ```

---

## Configuration

- **Port**: PostgreSQL is accessible on `localhost:5432`.
- **Credentials**:
  - Username: `root`
  - Password: `pass`
- **Connection String**: Use this URI format to connect to PostgreSQL:

  ```
  postgres://root:pass@localhost:5432
  ```

- **Data Persistence**: Local directory `./db_data` is mapped to `/var/lib/postgresql/data` inside the container.
- **Network**: Uses a Docker network `postgres-db` for isolation.

---

## Connect to PostgreSQL

### PostgreSQL CLI

Access the PostgreSQL shell with:

```bash
docker exec -it postgres psql -U root
```

### Other Clients

Connect using any PostgreSQL client with:

- **Host**: `localhost`
- **Port**: `5432`
- **Connection String**: `postgres://root:pass@localhost:5432`

---

## Stop PostgreSQL

Stop the container with:

```bash
docker-compose down
```

Data remains in `./db_data`.

---

## Troubleshooting

- **Container not starting**: Check logs with:

  ```bash
  docker logs postgres
  ```

- **Port conflict**: Make sure no other PostgreSQL container is running on `5432`, or change the `ports` section in `docker-compose.yml` and restart.

---

## Resources

- [PostgreSQL Docs](https://www.postgresql.org/docs/)
- [Docker PostgreSQL](https://hub.docker.com/_/postgres)
