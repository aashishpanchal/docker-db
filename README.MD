# Database Services Setup

This repository contains configuration files for running multiple database services using Docker Compose. The services included are PostgreSQL, Redis, MongoDB, MySQL, Adminer, PgAdmin, and RedisInsight. These services are intended to be used as shared databases for various projects, allowing for easy management and consistency.

## Services Overview

- [PostgreSQL](#postgresql)
- [Redis](#redis)
- [MongoDB](#mongodb)
- [MySQL](#mysql)
- [Adminer](#adminer)

## Usage

- [Running a Specific Service](#running-a-specific-service)
- [Running Multiple Services](#running-multiple-services)
- [Stopping a Service](#stopping-a-service)
- [Running in Detached Mode](#running-in-detached-mode)

## Others

- [Data Persistence](#data-persistence)
- [Environment Variables](#environment-variables)

---

### PostgreSQL

- **Image:** `postgres`
- **Ports:** `5432:5432`
- **Volumes:** `./data/postgres:/var/lib/postgresql/data`
- **Environment Variables:**
  - `POSTGRES_USER`: root
  - `POSTGRES_PASSWORD`: postgres

### Redis

- **Image:** `redis`
- **Ports:** `6379:6379`
- **Volumes:** `./data/redis:/data`

### MongoDB

- **Image:** `mongo`
- **Ports:** `27017:27017`
- **Volumes:** `./data/mongo:/data/db`
- **Environment Variables:**
  - `MONGO_INITDB_ROOT_USERNAME`: root
  - `MONGO_INITDB_ROOT_PASSWORD`: pass

### MySQL

- **Image:** `mysql`
- **Ports:** `3306:3306`
- **Volumes:** `./data/mysql:/var/lib/mysql`
- **Environment Variables:**
  - `MYSQL_ROOT_PASSWORD`: pass

### Adminer

- **Image:** `adminer`
- **Ports:** `8080:8080`
- **Environment Variables:**
  - `ADMINER_DEFAULT_SERVER`: mysql
  - `ADMINER_DESIGN`: pma-dark
  - `ADMINER_USER`: admin
  - `ADMINER_PASSWORD`: root

## Running a Specific Service

To start a specific service, use the following command:

```bash
docker compose up <service-name>
```

Replace `<service-name>` with the name of the service you want to start (e.g., `postgres`, `redis`, `mongo`, `mysql`, `adminer`).

#### Example

To run only the PostgreSQL service:

```bash
docker compose up postgres
```

## Running Multiple Services

To run multiple services, list them separated by a space:

```bash
docker compose up postgres mongo
```

## Stopping a Service

To stop a specific service, use the following command:

```bash
docker compose stop <service-name>
```

#### Example

To stop the PostgreSQL service:

```bash
docker compose stop postgres
```

## Running in Detached Mode

To start a service in detached mode (running in the background), use the `-d` flag:

```bash
docker compose up -d <service-name>
```

#### Example

To start PostgreSQL in detached mode:

```bash
docker compose up -d postgres
```

## Data Persistence

Each service has a designated volume for data persistence. These volumes are mounted from the host system to ensure that data is retained even if the container is restarted or removed.

- PostgreSQL data is stored in `./data/postgres`.
- Redis data is stored in `./data/redis`.
- MongoDB data is stored in `./data/mongo`.
- MySQL data is stored in `./data/mysql`.
- PgAdmin data is stored in `./data/pgadmin`.

## Environment Variables

For security purposes, sensitive information like passwords is managed through environment variables. You can modify these values in the `docker-compose.yml` file as needed.

### Key Updates:

- Added Adminer, PgAdmin, and RedisInsight sections.
- Updated the data persistence paths to match your Docker Compose file.
- Included environment variables for all services.

Feel free to modify any part of the README further if needed!
