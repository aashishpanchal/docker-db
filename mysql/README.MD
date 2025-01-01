# MySQL Docker Setup

Easily set up MySQL locally using Docker with this repository.

## Quick Start

1. Navigate to the directory `mysql` with `docker-compose.yml`.
2. Run MySQL in Docker:

   ```bash
   docker-compose up -d
   ```

   - This downloads the MySQL image, starts a container named `mysql`, and exposes port `3306`.

3. Check MySQL is running:

   ```bash
   docker ps
   ```

---

## Configuration

- **Port**: MySQL is accessible on `localhost:3306`.
- **Credentials**:
  - Username: `root`
  - Password: `pass`
- **Connection String**: Use this URI format to connect to MySQL:

  ```
  mysql://root:pass@localhost:3306
  ```

- **Data Persistence**: Local directory `./db_data` is mapped to `/var/lib/mysql` inside the container.
- **Network**: Uses a Docker network `mysql-db` for isolation.

---

## Connect to MySQL

### MySQL CLI

Access the MySQL shell with:

```bash
docker exec -it mysql mysql -u root -p
```

When prompted, enter the password: `pass`.

### Other Clients

Connect using any MySQL client with:

- **Host**: `localhost`
- **Port**: `3306`
- **Connection String**: `mysql://root:pass@localhost:3306`

---

## Stop MySQL

Stop the container with:

```bash
docker-compose down
```

Data remains in `./db_data`.

---

## Troubleshooting

- **Container not starting**: Check logs with:

  ```bash
  docker logs mysql
  ```

- **Port conflict**: Make sure no other MySQL container is running on `3306`, or change the `ports` section in `docker-compose.yml` and restart.

---

## Resources

- [MySQL Docs](https://dev.mysql.com/doc/)
- [Docker MySQL](https://hub.docker.com/_/mysql)
