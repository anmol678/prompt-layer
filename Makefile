
# Project variables
PROJECT_NAME = prompt-log
DOCKER_COMPOSE_FILE = docker-compose.yml

# Docker Compose commands
UP = docker-compose -f $(DOCKER_COMPOSE_FILE) up
UP_DETACHED = docker-compose -f $(DOCKER_COMPOSE_FILE) up -d
DOWN = docker-compose -f $(DOCKER_COMPOSE_FILE) down
BUILD = docker-compose -f $(DOCKER_COMPOSE_FILE) build
BUILD_NO_CACHE = docker-compose -f $(DOCKER_COMPOSE_FILE) build --no-cache
CLEAN = docker system prune -f

# Docker-compose workflows

# Default task
.PHONY: default
default: up

# Build images with cache
.PHONY: build
build:
	$(BUILD)

# Build images without cache
.PHONY: no-cache
no-cache:
	$(BUILD_NO_CACHE)

# Spin up the development environment
.PHONY: up
up:
	$(UP)

# Spin up the development environment in detached mode
.PHONY: up-detached
up-detached:
	$(UP_DETACHED)

# Stop all containers
.PHONY: down
down:
	$(DOWN)

# Cleanup stale images
.PHONY: clean
clean:
	$(CLEAN)

# Show logs for all services
.PHONY: logs
logs:
	docker-compose -f $(DOCKER_COMPOSE_FILE) logs --follow

# Restart a service
.PHONY: restart
restart:
	$(DOWN)
	$(UP)

# Dev workflows

# Function to start service in a new terminal window
define run_in_new_window
    osascript \
        -e "tell application \"Terminal\"" \
        -e "do script \"cd $(1) && $(2)\"" \
        -e "end tell"
endef

# Start the API server
.PHONY: run-api-dev
run-api-dev:
	$(call run_in_new_window,$(shell pwd)/prompt-log-api,make run-dev)

# Start the frontend server
.PHONY: run-app-dev
run-app-dev:
	$(call run_in_new_window,$(shell pwd)/prompt-log-app,npm run dev)

# Start both API and frontend server
.PHONY: run-dev
run-dev: run-api-dev run-app-dev
