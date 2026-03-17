# Docker Database
# Usage: make [target]

.DEFAULT_GOAL := help

# Output Colors
RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[1;33m
CYAN   := \033[0;36m
NC     := \033[0m

# Configuration
ENV_FILE := .env
DATA_DIR := ./data
PROJECT_NAME := database
DOCKER_COMPOSE_FILE := ./docker-compose.yml

# Load environment variables from .env if it exists
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

##@ Helps
help: ## Show help message/commands
	@echo "$(GREEN)Makfile: Available commands for this project:$(NC)"
	@awk 'BEGIN {FS = ":.*##"} \
	/^[a-zA-Z_-]+:.*##/ { \
		printf "$(YELLOW)* $(GREEN)%-20s$(NC) %s\n", $$1 "$(NC):", $$2 \
	}' $(MAKEFILE_LIST) | sort

##@ Commands
setup: create-dirs ## Initial setup - create directories and copy env file
	@echo "$(GREEN)[INFO]$(NC) Setting up database environment..."
	@if [ ! -f "$(ENV_FILE)" ]; then \
		cp .env.example $(ENV_FILE); \
		echo "$(YELLOW)[WARN]$(NC) Environment file created from template"; \
		echo "$(YELLOW)[WARN]$(NC) Please edit $(ENV_FILE) and update the passwords!"; \
	else \
		echo "$(GREEN)[INFO]$(NC) Environment file already exists"; \
	fi
	@echo "$(GREEN)[INFO]$(NC) Setup completed!"

check-env: ## Check if environment file exists
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) Environment file $(ENV_FILE) not found!"; \
		echo "$(YELLOW)[INFO]$(NC) Please run 'make setup' first or copy .env.example to .env"; \
		exit 1; \
	fi

create-dirs: ## Create necessary directories
	@echo "$(GREEN)[INFO]$(NC) Creating directories..."
	@mkdir -p $(DATA_DIR)/redis $(DATA_DIR)/postgres $(DATA_DIR)/rabbitmq $(DATA_DIR)/mysql $(DATA_DIR)/mongo
	@echo "$(GREEN)[INFO]$(NC) Directories created successfully!"

up-postgres: check-env create-dirs ## Start PostgreSQL
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d postgres

up-mysql: check-env create-dirs ## Start MySQL
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d mysql

up-redis: check-env create-dirs ## Start Redis
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d redis

up-mongo: check-env create-dirs ## Start MongoDB
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d mongo

up-rabbitmq: check-env create-dirs ## Start RabbitMQ
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d rabbitmq

up-adminer: check-env create-dirs ## Start Adminer
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d adminer

down-postgres: ## Stop PostgreSQL
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) stop postgres

down-mysql: ## Stop MySQL
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) stop mysql

down-redis: ## Stop Redis
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) stop redis

down-mongo: ## Stop MongoDB
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) stop mongo

down-rabbitmq: ## Stop RabbitMQ
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) stop rabbitmq

down-adminer: ## Stop Adminer
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) stop adminer

start: check-env create-dirs ## Start all services
	@echo "$(GREEN)[INFO]$(NC) Starting all services..."
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d
	@echo "$(GREEN)[INFO]$(NC) Services started successfully!"

stop: ## Stop all services
	@echo "$(GREEN)[INFO]$(NC) Stopping services..."
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(GREEN)[INFO]$(NC) Services stopped successfully!"

restart: stop start ## Restart all services
ps: ## Show running containers
	@docker ps --filter "name=$(PROJECT_NAME)"

logs: ## Show service logs (Ctrl+C to exit)
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) logs -f

status: ## Show service status
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) ps

clean: ## Stop services and remove volumes (⚠️ destroys data)
	@echo "$(RED)[WARNING]$(NC) This will stop services and remove all data!"
	@echo "$(RED)[WARNING]$(NC) Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) down -v
	@rm -rf $(DATA_DIR)/*
	@echo "$(GREEN)[INFO]$(NC) Cleanup completed!"
