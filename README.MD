# Database Services Setup

This repository contains configuration files for running multiple database services using Docker Compose. The services included are PostgreSQL, Redis, MongoDB, and MySQL. These services are intended to be used as shared databases for various projects, allowing for easy management and consistency.

## Services Overview

- [PostgreSQL](#postgresql)
- [Redis](#redis)
- [MongoDB](#mongodb)
- [MySQL](#mysql)

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
- **Volumes:** `./pg-data:/var/lib/postgresql/data`
- **Environment Variables:**
  - `POSTGRES_USER`: root
  - `POSTGRES_PASSWORD`: HZOq2ELBcVhMsVfXbR60BSdgBqOHcvCU

### Redis

- **Image:** `redis:latest`
- **Ports:** `6379:6379`
- **Volumes:** `./redis-data:/data`

### MongoDB

- **Image:** `mongo`
- **Ports:** `27017:27017`
- **Volumes:** `./mongo_data/:/data/db/`
- **Environment Variables:**
  - `MONGO_INITDB_ROOT_USERNAME`: root
  - `MONGO_INITDB_ROOT_PASSWORD`: HZOq2ELBcVhMsVfXbR60BSdgBqOHcvCU

### MySQL

- **Image:** `mysql`
- **Ports:** `3306:3306`
- **Volumes:** `./mysql_data:/var/lib/mysql`
- **Environment Variables:**
  - `MYSQL_ROOT_PASSWORD`: root
  - `MYSQL_USER`: root
  - `MYSQL_PASSWORD`: HZOq2ELBcVhMsVfXbR60BSdgBqOHcvCU

## Running a Specific Service

To start a specific service, use the following command:

```bash
docker-compose up <service-name>
```

Replace `<service-name>` with the name of the service you want to start (e.g., `postgres`, `redis`, `mongo`, `mysql`).

#### Example

To run only the PostgreSQL service:

```bash
docker-compose up postgres
```

## Running Multiple Services

To run multiple services, list them separated by a space:

```bash
docker-compose up postgres mongo
```

## Stopping a Service

To stop a specific service, use the following command:

```bash
docker-compose stop <service-name>
```

#### Example

To stop the PostgreSQL service:

```bash
docker-compose stop postgres
```

## Running in Detached Mode

To start a service in detached mode (running in the background), use the `-d` flag:

```bash
docker-compose up -d <service-name>
```

#### Example

To start PostgreSQL in detached mode:

```bash
docker-compose up -d postgres
```

## Data Persistence

Each service has a designated volume for data persistence. These volumes are mounted from the host system to ensure that data is retained even if the container is restarted or removed.

- PostgreSQL data is stored in `./data/pg-data`.
- Redis data is stored in `./data/redis-data`.
- MongoDB data is stored in `./data/mongo_data`.
- MySQL data is stored in `./data/mysql_data`.

## Environment Variables

For security purposes, sensitive information like passwords is managed through environment variables. You can modify these values in the `docker-compose.yml` file as needed.
