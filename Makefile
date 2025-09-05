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
PROJECT_NAME := services
DOCKER_COMPOSE_FILE := ./docker.yaml

# Load environment variables from .env if it exists
ifneq (,$(wildcard $(ENV_FILE)))
    include $(ENV_FILE)
    export
endif

# Service Ports (defined after .env is loaded)
SSH_PORT := 22
SERVICE_PORTS := $(POSTGRES_PORT) $(REDIS_PORT) $(RABBITMQ_PORT) $(RABBITMQ_MANAGEMENT_PORT)

##@ Help
help: ## - Show help message
	@echo "$(CYAN)Docker Management - Available Commands$(NC)"
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(CYAN)<target>$(NC)\n"} \
	/^[a-zA-Z_-]+:.*##/ { printf "  $(CYAN)%-18s$(NC) %s\n", $$1, $$2 } \
	/^##@/ { printf "\n$(GREEN)%s$(NC)\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Setup/Commands
setup: create-dirs ## - Initial setup - create directories and copy env file
	@echo "$(GREEN)[INFO]$(NC) Setting up ${PROJECT_NAME} database environment..."
	@if [ ! -f "$(ENV_FILE)" ]; then \
		cp .env.example $(ENV_FILE); \
		echo "$(YELLOW)[WARN]$(NC) Environment file created from template"; \
		echo "$(YELLOW)[WARN]$(NC) Please edit $(ENV_FILE) and update the passwords!"; \
	else \
		echo "$(GREEN)[INFO]$(NC) Environment file already exists"; \
	fi
	@echo "$(GREEN)[INFO]$(NC) Setup completed!"

check-env: ## - Check if environment file exists
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) Environment file $(ENV_FILE) not found!"; \
		echo "$(YELLOW)[INFO]$(NC) Please run 'make setup' first or copy .env.example to .env"; \
		exit 1; \
	fi

create-dirs: ## - Create necessary directories
	@echo "$(GREEN)[INFO]$(NC) Creating directories..."
	@mkdir -p $(DATA_DIR)/redis
	@mkdir -p $(DATA_DIR)/postgres
	@mkdir -p $(DATA_DIR)/rabbitmq
	@echo "$(GREEN)[INFO]$(NC) Directories created successfully!"

##@ Docker/Commands
ps: ## - Show running containers
	@echo "$(GREEN)[INFO]$(NC) Running containers:"
	@docker ps --filter "name=$(PROJECT_NAME)"

stop: ## - Stop all services
	@echo "$(GREEN)[INFO]$(NC) Stopping services..."
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) down
	@echo "$(GREEN)[INFO]$(NC) Services stopped successfully!"

logs: ## - Show service logs (press Ctrl+C to exit)
	@echo "$(GREEN)[INFO]$(NC) Showing service logs (press Ctrl+C to exit)..."
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) logs -f


start: check-env create-dirs ## - Start PostgreSQL, Redis, RabbitMQ
	@echo "$(GREEN)[INFO]$(NC) Starting PostgreSQL, Redis, and RabbitMQ services..."
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) --env-file $(ENV_FILE) up -d
	@echo "$(GREEN)[INFO]$(NC) Services started successfully!"
	@echo "$(GREEN)[INFO]$(NC) PostgreSQL: localhost:5432"
	@echo "$(GREEN)[INFO]$(NC) Redis: localhost:6379"
	@echo "$(GREEN)[INFO]$(NC) RabbitMQ: localhost:5672 (AMQP)"
	@echo "$(GREEN)[INFO]$(NC) RabbitMQ Management: http://localhost:15672"
	@echo "$(YELLOW)[INFO]$(NC) Run 'make logs' to view service logs"

clean: ## - Stop services and remove volumes (⚠️ destroys data)
	@echo "$(RED)[WARNING]$(NC) This will stop services and remove all data!"
	@echo "$(RED)[WARNING]$(NC) Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	@echo "$(GREEN)[INFO]$(NC) Stopping services and removing volumes..."
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) down -v
	@sudo rm -rf $(DATA_DIR)/*
	@echo "$(GREEN)[INFO]$(NC) Cleanup completed!"

status: ## - Show service status
	@echo "$(GREEN)[INFO]$(NC) Service Status:"
	@docker compose -p $(PROJECT_NAME) -f $(DOCKER_COMPOSE_FILE) ps

restart: stop start ## - Restart all services
	@echo "$(GREEN)[INFO]$(NC) Services restarted successfully!"


##@ Shell/Commands
db-list: check-env ## - List all databases
	@echo "$(GREEN)[INFO]$(NC) Listing all databases..."
	@docker exec -e PGPASSWORD=$(POSTGRES_PASS) $(PROJECT_NAME)-postgres-1 psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -c "\l"

shell-pg: check-env ## - Connect to PostgreSQL shell
	@echo "$(GREEN)[INFO]$(NC) Connecting to PostgreSQL shell for database $(POSTGRES_DB)..."
	@docker exec -it -e PGPASSWORD=$(POSTGRES_PASS) $(PROJECT_NAME)-postgres-1 psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)

db-tables: check-env ## - List tables in database
	@echo "$(GREEN)[INFO]$(NC) Listing tables in $(POSTGRES_DB) database..."
	@docker exec -e PGPASSWORD=$(POSTGRES_PASS) $(PROJECT_NAME)-postgres-1 psql -U $(POSTGRES_USER) -d $(POSTGRES_DB) -c "\dt"

shell-redis: check-env ## - Connect to Redis shell
	@echo "$(GREEN)[INFO]$(NC) Connecting to Redis shell..."
	@docker exec -it -e REDISCLI_AUTH=$(REDIS_PASS) $(PROJECT_NAME)-redis-1 redis-cli

shell-rabbitmq: check-env ## - Connect to RabbitMQ management CLI
	@echo "$(GREEN)[INFO]$(NC) Connecting to RabbitMQ management CLI..."
	@docker exec -it $(PROJECT_NAME)-rabbitmq-1 rabbitmqctl status

##@ Monitoring/Commands
info: check-env ## - Show connection information
	@echo "$(GREEN)[INFO]$(NC) Connection Information:"
	@echo "PostgreSQL: postgresql://$(POSTGRES_USER):your_password@localhost:$(POSTGRES_PORT)/$(POSTGRES_DB)"
	@echo "Redis: redis://:your_password@localhost:$(REDIS_PORT)"
	@echo "RabbitMQ: amqp://$(RABBITMQ_USER):your_password@localhost:$(RABBITMQ_PORT)$(RABBITMQ_VHOST)"
	@echo "RabbitMQ Management: http://localhost:$(RABBITMQ_MANAGEMENT_PORT)"
	@echo ""
	@echo "$(GREEN)[INFO]$(NC) Environment variables:"
	@grep -E "^[A-Z]" $(ENV_FILE) | grep -v PASSWORD || true

stats: ## - Live resource monitoring (Ctrl+C to exit)
	@echo "$(GREEN)[INFO]$(NC) Live resource monitoring (press Ctrl+C to exit)..."
	@echo "$(YELLOW)Container Stats:$(NC)"
	@docker stats $(PROJECT_NAME)-postgres-1 $(PROJECT_NAME)-redis-1 $(PROJECT_NAME)-rabbitmq-1

health: ## - Check service health
	@echo "$(GREEN)[INFO]$(NC) Checking service health..."
	@docker exec $(PROJECT_NAME)-postgres-1 pg_isready -U $(POSTGRES_USER) -d $(POSTGRES_DB) > /dev/null 2>&1 && echo "$(GREEN)✓$(NC) PostgreSQL is healthy" || echo "$(RED)✗$(NC) PostgreSQL is unhealthy"
	@docker exec -e REDISCLI_AUTH=$(REDIS_PASS) $(PROJECT_NAME)-redis-1 redis-cli ping > /dev/null 2>&1 && echo "$(GREEN)✓$(NC) Redis is healthy" || echo "$(RED)✗$(NC) Redis is unhealthy"
	@docker exec $(PROJECT_NAME)-rabbitmq-1 rabbitmq-diagnostics ping > /dev/null 2>&1 && echo "$(GREEN)✓$(NC) RabbitMQ is healthy" || echo "$(RED)✗$(NC) RabbitMQ is unhealthy"

resources: ## - Show resource usage vs configured limits
	@echo "$(GREEN)[INFO]$(NC) Resource Usage vs Configured Limits:"
	@echo ""
	@echo "$(YELLOW)=== CURRENT USAGE ===$(NC)"
	@docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" $(PROJECT_NAME)-postgres-1 $(PROJECT_NAME)-redis-1 $(PROJECT_NAME)-rabbitmq-1

disk-usage: ## - Show disk usage and manage build cache
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
##@ Security/Commands
security: ## - Run comprehensive security audit
	@echo "$(GREEN)[INFO]$(NC) Running security check..."
	@echo "$(GREEN)[INFO]$(NC) Setting secure permissions on .env file..."
	@chmod 600 .env
	@echo "$(GREEN)✓$(NC) .env file permissions set to 600"
	@./bin/checker.sh

gen-pass: check-env ## - Generate and auto-replace passwords in .env file
	@echo "$(GREEN)[INFO]$(NC) Generating strong passwords and updating .env file..."
	@REDIS_NEW=$$(openssl rand -base64 32 | tr -d '=+/' | head -c 32); \
	POSTGRES_NEW=$$(openssl rand -base64 32 | tr -d '=+/' | head -c 32); \
	RABBITMQ_NEW=$$(openssl rand -base64 32 | tr -d '=+/' | head -c 32); \
	cp $(ENV_FILE) $(ENV_FILE).backup; \
	sed -i.tmp "s/^REDIS_PASS=.*/REDIS_PASS=$$REDIS_NEW/" $(ENV_FILE); \
	sed -i.tmp "s/^POSTGRES_PASS=.*/POSTGRES_PASS=$$POSTGRES_NEW/" $(ENV_FILE); \
	sed -i.tmp "s/^RABBITMQ_PASS=.*/RABBITMQ_PASS=$$RABBITMQ_NEW/" $(ENV_FILE); \
	rm -f $(ENV_FILE).tmp; \
	echo "$(GREEN)✓$(NC) Passwords updated in $(ENV_FILE)"; \
	echo "$(YELLOW)[INFO]$(NC) Backup saved as $(ENV_FILE).backup"; \
	echo "$(GREEN)REDIS_PASS$(NC): $(CYAN)$$REDIS_NEW$(NC)"; \
	echo "$(GREEN)POSTGRES_PASS$(NC): $(CYAN)$$POSTGRES_NEW$(NC)"; \
	echo "$(GREEN)RABBITMQ_PASS$(NC): $(CYAN)$$RABBITMQ_NEW$(NC)"

audit-logs: ## - Show recent security-relevant log entries
	@echo "$(GREEN)[INFO]$(NC) Showing recent security logs..."
	@echo "$(YELLOW)PostgreSQL Connection Logs:$(NC)"
	@docker logs $(PROJECT_NAME)-postgres-1 2>&1 | grep -E "(connection|authentication|FATAL|ERROR)" | tail -10 || echo "No recent connection logs"
	@echo ""
	@echo "$(YELLOW)Redis Security Events:$(NC)"
	@docker logs $(PROJECT_NAME)-redis-1 2>&1 | grep -E "(DENIED|AUTH|ERROR)" | tail -10 || echo "No recent security events"
	@echo ""
	@echo "$(YELLOW)RabbitMQ Authentication:$(NC)"
	@docker logs $(PROJECT_NAME)-rabbitmq-1 2>&1 | grep -E "(authentication|login|failed)" | tail -10 || echo "No recent auth events"

##@ Ufw/Commands
ufw-check: ## - Check if UFW is installed
	@if ! command -v ufw >/dev/null 2>&1; then \
		echo "$(RED)[ERROR]$(NC) UFW is not installed!"; \
		echo "$(YELLOW)[INFO]$(NC) CentOS/RHEL: sudo yum install ufw"; \
		echo "$(YELLOW)[INFO]$(NC) Ubuntu/Debian: sudo apt install ufw"; \
		exit 1; \
	fi

ufw-status: ufw-check ## - Show UFW status and database ports
	@echo "$(GREEN)[INFO]$(NC) UFW Status:"
	@sudo ufw status verbose
	@echo ""
	@echo "$(GREEN)[INFO]$(NC) Database Ports Configuration:"
	@echo "  Redis: $(REDIS_PORT)"
	@echo "  RabbitMQ: $(RABBITMQ_PORT)"
	@echo "  RabbitMQ Management: $(RABBITMQ_MANAGEMENT_PORT)"
	@echo "  PostgreSQL: $(POSTGRES_PORT)"

ufw-enable: ufw-check ## - Enable UFW with secure defaults
	@echo "$(GREEN)[INFO]$(NC) Enabling UFW with secure defaults..."
	@sudo ufw --force default deny incoming
	@sudo ufw --force default allow outgoing
	@sudo ufw --force enable
	@sudo ufw allow $(SSH_PORT)
	@echo "$(GREEN)✓$(NC) UFW enabled with default deny policy"
	@echo "$(YELLOW)[INFO]$(NC) SSH access is allowed to prevent lockout"

ufw-disable: ufw-check ## - Disable UFW
	@echo "$(GREEN)[INFO]$(NC) Disabling UFW..."
	@sudo ufw --force disable
	@echo "$(GREEN)✓$(NC) UFW disabled"

ufw-reset: ufw-check ## - Reset all UFW rules (⚠️ removes all rules)
	@echo "$(RED)[WARNING]$(NC) This will remove all UFW rules!"
	@echo "$(RED)[WARNING]$(NC) Press Ctrl+C to cancel, or Enter to continue..."
	@read dummy
	@echo "$(GREEN)[INFO]$(NC) Resetting UFW rules..."
	@sudo ufw --force reset
	@echo "$(GREEN)✓$(NC) UFW rules reset"

ufw-backup: ufw-check ## - Backup current UFW rules
	@mkdir -p ./stores/ufw
	@BACKUP_FILE="./stores/ufw/ufw-backup-$$(date +%Y%m%d-%H%M%S).txt"; \
	echo "$(GREEN)[INFO]$(NC) Backing up UFW rules to $$BACKUP_FILE..."; \
	sudo ufw status numbered > $$BACKUP_FILE; \
	echo "$(GREEN)✓$(NC) UFW rules backed up to $$BACKUP_FILE"; \
	echo "$(YELLOW)[INFO]$(NC) Use 'make ufw-list-backups' to see all backups"

ufw-restore: ufw-check ## - Restore UFW rules from backup
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) Backup file required!"; \
		echo "$(YELLOW)[INFO]$(NC) Usage: make ufw-restore FILE=ufw-backup-20250819-123456.txt"; \
		echo "$(YELLOW)[INFO]$(NC) Use 'make ufw-list-backups' to see available backups"; \
		exit 1; \
	fi
	@if [ ! -f "./stores/ufw/$(FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) Backup file './stores/ufw/$(FILE)' not found!"; \
		echo "$(YELLOW)[INFO]$(NC) Use 'make ufw-list-backups' to see available backups"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) Backup file contents:"
	@cat "./stores/ufw/$(FILE)"
	@echo ""
	@echo "$(YELLOW)[INFO]$(NC) To restore, manually add rules using the backup as reference"
	@echo "$(YELLOW)[INFO]$(NC) Example: sudo ufw allow from 192.168.1.100 to any port 5432"

ufw-allow: ufw-check ## - Allow <IP> to specific <PORT> (must be a project port)
	@if [ -z "$(PORT)" ] || [ -z "$(IP)" ]; then \
		echo "$(RED)[ERROR]$(NC) Port and IP required!"; \
		echo "$(YELLOW)[INFO]$(NC) Usage: make ufw-allow PORT=5432 IP=203.0.113.45"; \
		exit 1; \
	fi
	@if ! echo "$(SERVICE_PORTS)" | grep -wq "$(PORT)"; then \
		echo "$(RED)[ERROR]$(NC) Port $(PORT) is not in project service ports: $(SERVICE_PORTS)"; \
		exit 1; \
	fi
	@echo "$(GREEN)[INFO]$(NC) Allowing IP $(IP) to access port $(PORT)..."
	@sudo ufw allow from $(IP) to any port $(PORT) comment "$(PROJECT_NAME) port $(PORT) from $(IP)"
	@echo "$(GREEN)✓$(NC) IP $(IP) can now access port $(PORT)"

ufw-deny: ufw-check ## - Deny <IP> from specific <PORT> (must be a project port)
	@if [ -z "$(PORT)" ] || [ -z "$(IP)" ]; then \
		echo "$(RED)[ERROR]$(NC) Port and IP required!"; \
		echo "$(YELLOW)[INFO]$(NC) Usage: make ufw-deny PORT=5432 IP=203.0.113.45"; \
		exit 1; \
	fi
	@if ! echo "$(SERVICE_PORTS)" | grep -wq "$(PORT)"; then \
		echo "$(RED)[ERROR]$(NC) Port $(PORT) is not in project service ports: $(SERVICE_PORTS)"; \
		exit 1; \
	fi
	@echo "$(GREEN)[INFO]$(NC) Denying IP $(IP) from port $(PORT)..."
	@sudo ufw delete allow from $(IP) to any port $(PORT) 2>/dev/null || true
	@echo "$(GREEN)✓$(NC) IP $(IP) is now blocked from port $(PORT)"

ufw-deny-ip: ufw-check ## - Deny <IP> from all service ports
	@if [ -z "$(IP)" ]; then \
		echo "$(RED)[ERROR]$(NC) IP address required!"; \
		echo "$(YELLOW)[INFO]$(NC) Usage: make ufw-deny-ip IP=203.0.113.45"; \
		exit 1; \
	fi
	@for port in $(SERVICE_PORTS); do \
		echo "$(GREEN)[INFO]$(NC) Denying IP $(IP) from port $$port..."; \
		sudo ufw delete allow from $(IP) to any port $$port 2>/dev/null || true; \
	done
	@echo "$(GREEN)✓$(NC) IP $(IP) is now blocked from all service ports"

ufw-allow-ip: ufw-check ## - Allow <IP> to all service ports
	@if [ -z "$(IP)" ]; then \
		echo "$(RED)[ERROR]$(NC) IP address required!"; \
		echo "$(YELLOW)[INFO]$(NC) Usage: make ufw-allow-ip IP=203.0.113.45"; \
		exit 1; \
	fi
	@for port in $(SERVICE_PORTS); do \
		echo "$(GREEN)[INFO]$(NC) Allowing IP $(IP) to access port $$port..."; \
		sudo ufw allow from $(IP) to any port $$port comment "Service port $$port from $(IP)"; \
	done
	@echo "$(GREEN)✓$(NC) IP $(IP) can now access all service ports"

ufw-test-ip: ufw-check
	@if [ -z "$(IP)" ]; then \
		echo "$(RED)[ERROR]$(NC) IP address required!"; \
		echo "$(YELLOW)[INFO]$(NC) Usage: make ufw-test-ip IP=203.0.113.45"; \
		exit 1; \
	fi
	@echo "$(GREEN)[INFO]$(NC) Testing connection access for IP: $(IP)"
	@for port in $(SERVICE_PORTS); do \
		echo ""; \
		echo "$(YELLOW)=== Testing Port $$port ===$(NC)"; \
		if sudo ufw status | grep -E "^($$port|$$port/tcp).*ALLOW" | grep -q "$(IP)"; then \
			echo "$(GREEN)✓$(NC) UFW allows $(IP) on port $$port"; \
		else \
			echo "$(RED)✗$(NC) UFW blocks $(IP) on port $$port"; \
		fi; \
		nc -zv -w2 127.0.0.1 $$port >/dev/null 2>&1 && \
			echo "$(GREEN)✓$(NC) Port $$port is reachable locally" || \
			echo "$(RED)✗$(NC) Port $$port is not reachable locally"; \
	done
	@echo ""; \
	echo "$(BLUE)[INFO]$(NC) Connection test completed for IP: $(IP)"

ufw-list-backups: ufw-check ## - List all UFW backup files
	@echo "$(GREEN)[INFO]$(NC) Available UFW backup files:"
	@if [ -d "./stores/ufw" ] && [ "$$(ls -A ./stores/ufw 2>/dev/null)" ]; then \
		ls -la ./stores/ufw/; \
	else \
		echo "$(YELLOW)[INFO]$(NC) No backup files found. Use 'make ufw-backup' to create one."; \
	fi

ufw-clean-backups: ufw-check ## - Clean old UFW backup files (keeps last 5)
	@echo "$(GREEN)[INFO]$(NC) Cleaning old UFW backup files (keeping last 5)..."
	@if [ -d "./stores/ufw" ]; then \
		cd ./stores/ufw && ls -t ufw-backup-*.txt 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true; \
		echo "$(GREEN)✓$(NC) Old backup files cleaned (kept last 5)"; \
		echo "$(YELLOW)[INFO]$(NC) Use 'make ufw-list-backups' to see remaining backups"; \
	else \
		echo "$(YELLOW)[INFO]$(NC) No backup directory found"; \
	fi

ufw-allow-anywhere: ufw-check ## - Allow all database ports from anywhere
	@for port in $(SERVICE_PORTS); do \
		echo "$(GREEN)[INFO]$(NC) Allowing port $$port from anywhere..."; \
		sudo ufw allow $$port/tcp comment "$(PROJECT_NAME) Service - Anywhere"; \
	done
	@echo "$(GREEN)✓$(NC) All service ports are now open to worldwide access"

ufw-deny-anywhere: ufw-check ## - Deny all database ports from anywhere
	@for port in $(SERVICE_PORTS); do \
		echo "$(GREEN)[INFO]$(NC) Blocking port $$port from anywhere..."; \
		sudo ufw delete allow $$port/tcp 2>/dev/null || true; \
	done
	@echo "$(GREEN)✓$(NC) All service ports are now blocked from worldwide access"
