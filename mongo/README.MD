# MongoDB Docker Setup

Easily set up MongoDB locally using Docker with this repository.

## Quick Start

1. Navigate to the directory `mongo` with `docker-compose.yml`.
2. Run MongoDB in Docker:

   ```bash
   docker-compose up -d
   ```

   - This downloads the MongoDB image, starts a container named `mongo`, and exposes port `27017`.

3. Check MongoDB is running:

   ```bash
   docker ps
   ```

---

## Configuration

- **Port**: MongoDB is accessible on `localhost:27017`.
- **Credentials**:
  - Username: `root`
  - Password: `pass`
- **Connection String**: Use this URI format to connect to MongoDB:

  ```
  mongodb://root:pass@localhost:27017
  ```

- **Data Persistence**: Local directory `./db_data` is mapped to `/data/db` inside the container.
- **Network**: Uses a Docker network `mongo-db` for isolation.

---

## Connect to MongoDB

### Mongo Shell

Access the Mongo shell with:

```bash
docker exec -it mongo mongosh -u root -p pass
```

### Other Clients

Connect using any MongoDB client with:

- **Host**: `localhost`
- **Port**: `27017`
- **Connection String**: `mongodb://root:pass@localhost:27017`

---

## Stop MongoDB

Stop the container with:

```bash
docker-compose down
```

Data remains in `./db_data`.

---

## Troubleshooting

- **Container not starting**: Check logs with:

  ```bash
  docker logs mongo
  ```

- **Port conflict**: Make sure no other MongoDB container is running on `27017`, or change the `ports` section in `docker-compose.yml` and restart.

---

## Resources

- [MongoDB Docs](https://www.mongodb.com/docs/)
- [Docker MongoDB](https://hub.docker.com/_/mongo)
