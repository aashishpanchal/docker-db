# Database Services Setup

Global database services using Docker/Podman Compose. Includes PostgreSQL, Redis, MongoDB, MySQL, and Adminer.

## Services

- **PostgreSQL** - `localhost:5432` (user: root, password: postgres)
- **MySQL** - `localhost:3306` (root password: pass)
- **Redis** - `localhost:6379`
- **MongoDB** - `localhost:27017` (user: root, password: pass)
- **Adminer** - `http://localhost:8080` (Database GUI)

## Quick Start

```bash
make help              # Show all commands
make start             # Start all services
make start-postgres    # Start PostgreSQL only
make start-redis       # Start Redis only
make start-mongo       # Start MongoDB only
make start-mysql       # Start MySQL only
make health            # Check service health
make logs              # View logs
make stop              # Stop all services
```

## Requirements

- Docker or Podman
- docker-compose or podman-compose

Install on macOS:
```bash
brew install podman podman-compose
podman machine init
podman machine start
```

## Data Persistence

Data is stored in `./data/` directory:
- `./data/postgres` - PostgreSQL data
- `./data/mysql` - MySQL data
- `./data/redis` - Redis data
- `./data/mongo` - MongoDB data
