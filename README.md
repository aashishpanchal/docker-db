# Docker Development Environment

A comprehensive Docker-based development environment with PostgreSQL, Valkey (Redis alternative), and RabbitMQ services. This project provides a complete setup for local development with optimized configurations and resource management.

## Features

- **PostgreSQL 17** with ULID extension for unique identifiers
- **Valkey** (Redis alternative) for caching and key-value storage
- **RabbitMQ** for message queuing
- Resource-optimized configurations for 8GB RAM/2 Core CPU systems
- Comprehensive Makefile for easy management
- Health checks and monitoring tools
- Persistent data storage

## Prerequisites

- Docker and Docker Compose (Docker Desktop on macOS)
- Make utility
- Bash shell

> **Note for macOS users**: This project uses `docker compose` (with a space) instead of `docker-compose` (with a hyphen) in the Makefile, which is the preferred syntax for newer Docker Desktop versions on macOS.

## Quick Start

1. Clone this repository
2. Run the setup command:
   ```
   make setup
   ```
3. Edit the `.env` file with your preferred settings
4. Start the services:
   ```
   make start
   ```

## Environment Configuration

Copy the `.env.example` file to `.env` and customize the following variables:

- `PROJECT_NAME`: Your project name
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database username
- `POSTGRES_PASSWORD`: Database password
- `POSTGRES_PORT`: PostgreSQL port (default: 5432)
- `VALKEY_PORT`: Valkey port (default: 6379)
- `VALKEY_PASSWORD`: Valkey password
- `RABBITMQ_USER`: RabbitMQ username
- `RABBITMQ_PASSWORD`: RabbitMQ password
- `RABBITMQ_PORT`: RabbitMQ AMQP port (default: 5672)
- `RABBITMQ_MANAGEMENT_PORT`: RabbitMQ management UI port (default: 15672)
- `DATA_PATH`: Path for persistent data storage

## Available Commands

### Setup and Management

- `make setup` - Initial setup (create directories and env file)
- `make start` - Start all services
- `make stop` - Stop all services
- `make restart` - Restart all services
- `make logs` - View service logs
- `make status` - Check service status
- `make clean` - Stop services and remove volumes (⚠️ destroys data)

### Database Access

- `make shell-pg` - Connect to PostgreSQL shell
- `make db-list` - List all databases
- `make db-tables` - List tables in database

### Cache and Message Queue

- `make shell-valkey` - Connect to Valkey shell
- `make shell-rabbitmq` - Connect to RabbitMQ management CLI
- `make rabbitmq-info` - Show RabbitMQ status and queues

### Monitoring

- `make health` - Check service health
- `make resources` - Show resource usage vs configured limits
- `make stats` - Live resource monitoring
- `make disk-usage` - Show disk usage and manage build cache
- `make docker-size` - Show Docker total space usage
- `make info` - Show connection information

## Service Details

### PostgreSQL

- Version: 17
- Extensions: pgx_ulid
- Default timezone: Asia/Kolkata
- Authentication: scram-sha-256
- Resource limits: 1 CPU, 4GB RAM

### Valkey (Redis Alternative)

- Version: 8
- Persistence: Enabled (appendonly)
- Resource limits: 0.5 CPU, 2GB RAM

### RabbitMQ

- Version: 4 with Management UI
- Resource limits: 0.5 CPU, 2GB RAM

## Directory Structure

- `/bin` - Helper scripts
- `/conf` - Configuration files for services
- `/pgsql` - PostgreSQL Dockerfile and initialization scripts
- `/data` - Persistent data storage (created on setup)

## Troubleshooting

### Container Not Found Errors

If you encounter errors like `Error response from daemon: No such container: [project-name]-[service-name]-1` when trying to run commands like `make shell-pg`, it might be due to a mismatch between how containers are started and accessed:

1. Check if your containers are running with `docker ps`
2. Verify that the container names match what's expected in the Makefile
3. On macOS, ensure you're using `docker compose` (with a space) rather than `docker-compose` (with a hyphen)

### Connection Issues

If you can't connect to services:

1. Verify that the services are running with `make status`
2. Check the logs with `make logs` to see if there are any startup errors
3. Ensure that the ports specified in your `.env` file are not being used by other applications

### Data Persistence Issues

If your data isn't persisting between restarts:

1. Check that the volumes are properly mounted with `docker volume ls`
2. Verify that the `DATA_PATH` in your `.env` file points to a valid directory
3. Ensure you have proper permissions for the data directories

## Security Features

- SCRAM-SHA-256 authentication for PostgreSQL
- Password protection for all services
- Container resource limits
- No-new-privileges security option

## License

This project is licensed under the MIT License.

Copyright (c) 2024 Aashish Panchal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
