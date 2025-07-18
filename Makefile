# Docker Management Makefile
# Usage: make [target]

.DEFAULT_GOAL := help

# Output Colors
RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[1;33m
BLUE   := \033[0;34m
CYAN   := \033[0;36m
NC     := \033[0m

# Configuration
ENV_FILE := .env
DATA_DIR := ./data
DOCKER_COMPOSE_FILE := docker.yaml

# Load environment variables from .env if it exists
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

##@ Help
help: ## - Show help message
	@echo "$(CYAN)Docker Management - Available Commands$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(YELLOW)<target>$(NC)\n"} \
	/^[a-zA-Z_-]+:.*##/ { printf "  $(YELLOW)%-14s$(NC) %s\n", $$1, $$2 } \
	/^##@/ { printf "\n$(BLUE)%s$(NC)\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Setup
check-env: ## - Check if environment file exists
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) Environment file $(ENV_FILE) not found!"; \
		echo "$(YELLOW)[INFO]$(NC) Please run 'make setup' first or copy .env.example to .env"; \
		exit 1; \
	fi

create-dirs: ## - Create necessary directories
	@echo "$(GREEN)[INFO]$(NC) Creating directories..."
	@mkdir -p $(DATA_DIR)/postgres
	@mkdir -p $(DATA_DIR)/valkey
	@mkdir -p $(DATA_DIR)/rabbitmq
	@echo "$(GREEN)[INFO]$(NC) Running setup.sh script..."
	@bash ./setup.sh
	@echo "$(GREEN)[INFO]$(NC) setup.sh completed successfully!"
	@echo "$(GREEN)[INFO]$(NC) Directories created successfully!"

setup: create-dirs ## - Initial setup - create directories and copy env file
	@echo "$(GREEN)[INFO]$(NC) Setting up Zinix database environment..."
	@if [ ! -f "$(ENV_FILE)" ]; then \
		cp .env.example $(ENV_FILE); \
		echo "$(YELLOW)[WARN]$(NC) Environment file created from template"; \
		echo "$(YELLOW)[WARN]$(NC) Please edit $(ENV_FILE) and update the passwords!"; \
	else \
		echo "$(GREEN)[INFO]$(NC) Environment file already exists"; \
	fi
	@echo "$(GREEN)[INFO]$(NC) Setup completed!"

##@ Docker Services
start: check-env create-dirs ## - Start PostgreSQL, Valkey, and RabbitMQ services
	@echo "$(GREEN)[INFO]$(NC) Starting PostgreSQL, Valkey, and RabbitMQ services..."
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d
	@echo "$(GREEN)[INFO]$(NC) Services started successfully!"
	@echo "$(GREEN)[INFO]$(NC) PostgreSQL: localhost:5432"
	@echo "$(GREEN)[INFO]$(NC) Valkey: localhost:6379"
	@echo "$(GREEN)[INFO]$(NC) RabbitMQ: localhost:5672 (AMQP)"
	@echo "$(GREEN)[INFO]$(NC) RabbitMQ Management: http://localhost:15672"
	@echo "$(YELLOW)[INFO]$(NC) Run 'make logs' to view service logs"

stop: ## - Stop all services
	@echo "$(GREEN)[INFO]$(NC) Stopping services..."
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(GREEN)[INFO]$(NC) Services stopped successfully!"

restart: stop start ## - Restart all services
	@echo "$(GREEN)[INFO]$(NC) Services restarted successfully!"

logs: ## - Show service logs (press Ctrl+C to exit)
	@echo "$(GREEN)[INFO]$(NC) Showing service logs (press Ctrl+C to exit)..."
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) logs -f

status: ## - Show service status
	@echo "$(GREEN)[INFO]$(NC) Service Status:"
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) ps

ps: ## - Show running containers
	@echo "$(GREEN)[INFO]$(NC) Running containers:"
	@docker ps --filter "name=$(PROJECT_NAME)"

clean: ## - Stop services and remove volumes (⚠️ destroys data)
	@echo "$(RED)[WARNING]$(NC) This will stop services and remove all data!"
	@echo "$(RED)[WARNING]$(NC) Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	@echo "$(GREEN)[INFO]$(NC) Stopping services and removing volumes..."
	@docker-compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) down -v
	@sudo rm -rf $(DATA_DIR)/*
	@echo "$(GREEN)[INFO]$(NC) Cleanup completed!"

##@ Shell/Commands
shell-pg: check-env ## - Connect to PostgreSQL shell
	@echo "$(GREEN)[INFO]$(NC) Connecting to PostgreSQL shell for database $(POSTGRES_DB)..."
	@docker exec -it -e PGPASSWORD=$(POSTGRES_PASSWORD) $(PROJECT_NAME)-postgres-1 psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

db-list: check-env ## - List all databases
	@echo "$(GREEN)[INFO]$(NC) Listing all databases..."
	@docker exec -e PGPASSWORD=$(POSTGRES_PASSWORD) $(PROJECT_NAME)-postgres-1 psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -c "\l"

db-tables: check-env ## - List tables in database
	@echo "$(GREEN)[INFO]$(NC) Listing tables in $(POSTGRES_DB) database..."
	@docker exec -e PGPASSWORD=$(POSTGRES_PASSWORD) $(PROJECT_NAME)-postgres-1 psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -c "\dt"

shell-valkey: check-env ## - Connect to Valkey shell
	@echo "$(GREEN)[INFO]$(NC) Connecting to Valkey shell..."
	@docker exec -it -e VALKEY_PASSWORD=$(VALKEY_PASSWORD) $(PROJECT_NAME)-valkey-1 valkey-cli -a $(VALKEY_PASSWORD)

shell-rabbitmq: check-env ## - Connect to RabbitMQ management CLI
	@echo "$(GREEN)[INFO]$(NC) Connecting to RabbitMQ management CLI..."
	@docker exec -it $(PROJECT_NAME)-rabbitmq-1 rabbitmqctl status

##@ Monitoring
rabbitmq-info: check-env ## - Show RabbitMQ status and queues
	@echo "$(GREEN)[INFO]$(NC) RabbitMQ Status and Information:"
	@echo ""
	@echo "$(YELLOW)=== RabbitMQ Status ===$(NC)"
	@docker exec $(PROJECT_NAME)-rabbitmq-1 rabbitmqctl status || echo "$(RED)✗$(NC) RabbitMQ is not running"
	@echo ""
	@echo "$(YELLOW)=== RabbitMQ Queues ===$(NC)"
	@docker exec $(PROJECT_NAME)-rabbitmq-1 rabbitmqctl list_queues || echo "$(RED)✗$(NC) Could not list queues"
	@echo ""
	@echo "$(YELLOW)=== RabbitMQ Users ===$(NC)"
	@docker exec $(PROJECT_NAME)-rabbitmq-1 rabbitmqctl list_users || echo "$(RED)✗$(NC) Could not list users"

health: ## - Check service health
	@echo "$(GREEN)[INFO]$(NC) Checking service health..."
	@docker exec $(PROJECT_NAME)-postgres-1 pg_isready -U $(POSTGRES_USER) -d $(POSTGRES_DB) && echo "$(GREEN)✓$(NC) PostgreSQL is healthy" || echo "$(RED)✗$(NC) PostgreSQL is unhealthy"
	@docker exec -e VALKEY_PASSWORD=$(VALKEY_PASSWORD) $(PROJECT_NAME)-valkey-1 valkey-cli -a $(VALKEY_PASSWORD) ping && echo "$(GREEN)✓$(NC) Valkey is healthy" || echo "$(RED)✗$(NC) Valkey is unhealthy"
	@docker exec $(PROJECT_NAME)-rabbitmq-1 rabbitmq-diagnostics ping && echo "$(GREEN)✓$(NC) RabbitMQ is healthy" || echo "$(RED)✗$(NC) RabbitMQ is unhealthy"

resources: ## - Show resource usage vs configured limits
	@echo "$(GREEN)[INFO]$(NC) Resource Usage vs Configured Limits:"
	@echo ""
	@echo "$(YELLOW)=== CONFIGURED LIMITS ===$(NC)"
	@echo "PostgreSQL:"
	@echo "  CPU Limit: 0.5 cores"
	@echo "  Memory Limit: 4GB"
	@echo "  CPU Reservation: 0.25 cores"
	@echo "  Memory Reservation: 512MB"
	@echo ""
	@echo "Valkey:"
	@echo "  CPU Limit: 0.5 core"
	@echo "  Memory Limit: 1GB"
	@echo "  CPU Reservation: 0.25 cores"
	@echo "  Memory Reservation: 128MB"
	@echo ""
	@echo "RabbitMQ:"
	@echo "  CPU Limit: 0.5 core"
	@echo "  Memory Limit: 2GB"
	@echo "  CPU Reservation: 0.25 cores"
	@echo "  Memory Reservation: 256MB"
	@echo ""
	@echo "$(YELLOW)=== CURRENT USAGE ===$(NC)"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" $(PROJECT_NAME)-postgres-1 $(PROJECT_NAME)-valkey-1 $(PROJECT_NAME)-rabbitmq-1

stats: ## - Live resource monitoring (Ctrl+C to exit)
	@echo "$(GREEN)[INFO]$(NC) Live resource monitoring (press Ctrl+C to exit)..."
	@echo "$(YELLOW)Container Stats:$(NC)"
	@docker stats $(PROJECT_NAME)-postgres-1 $(PROJECT_NAME)-valkey-1 $(PROJECT_NAME)-rabbitmq-1

disk-usage: ## - Show disk usage
	@echo "$(GREEN)[INFO]$(NC) Docker disk usage:"
	@docker system df
	@echo ""
	@echo "$(GREEN)[INFO]$(NC) Data directory usage:"
	@du -sh $(DATA_DIR)/* 2>/dev/null || echo "No data directories found"

docker-size: ## - Show Docker total space usage
	@echo "$(GREEN)[INFO]$(NC) Docker Total Space Usage:"
	@echo ""
	@echo "$(YELLOW)=== Docker System Overview ===$(NC)"
	@docker system df
	@echo ""
	@echo "$(YELLOW)=== Detailed Breakdown ===$(NC)"
	@docker system df -v
	@echo ""
	@echo "$(YELLOW)=== Total Docker Root Directory Size ===$(NC)"
	@if [ -d "/var/lib/docker" ]; then \
		sudo du -sh /var/lib/docker 2>/dev/null || echo "$(RED)✗$(NC) Cannot access /var/lib/docker (permission denied)"; \
	elif [ -d "$$HOME/.docker" ]; then \
		du -sh $$HOME/.docker 2>/dev/null || echo "$(RED)✗$(NC) Cannot access Docker directory"; \
	else \
		echo "$(YELLOW)[INFO]$(NC) Docker directory not found in standard locations"; \
	fi
	@echo ""
	@echo "$(YELLOW)=== Project Data Directory Size ===$(NC)"
	@du -sh $(DATA_DIR) 2>/dev/null || echo "$(RED)✗$(NC) Data directory not found"

info: check-env ## - Show connection information
	@echo "$(GREEN)[INFO]$(NC) Connection Information:"
	@echo "PostgreSQL: postgresql://$(POSTGRES_USER):your_password@localhost:$(POSTGRES_PORT)/$(POSTGRES_DB)"
	@echo "Valkey: valkey://:your_password@localhost:$(VALKEY_PORT)"
	@echo "RabbitMQ: amqp://$(RABBITMQ_USER):your_password@localhost:$(RABBITMQ_PORT)$(RABBITMQ_VHOST)"
	@echo "RabbitMQ Management: http://localhost:$(RABBITMQ_MANAGEMENT_PORT)"
	@echo ""
	@echo "$(GREEN)[INFO]$(NC) Environment variables:"
	@grep -E "^[A-Z]" $(ENV_FILE) | grep -v PASSWORD || true
