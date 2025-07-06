#!/bin/bash
#
# Starts the development database using Docker Compose.
#
# This script starts the appropriate database container based on the project configuration.
# It will pull the required Docker images if they don't exist locally.
#
# Usage: ./scripts/start-database.sh
#

set -e

echo -e "\033[36mStarting Development Database\033[0m"
echo -e "\033[36m=============================\033[0m"

# Check if Docker is running
if ! docker version > /dev/null 2>&1; then
    echo -e "\033[31mError: Docker is not running. Please start Docker and try again.\033[0m"
    exit 1
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"

# Generate docker-compose.yml if it doesn't exist
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "\033[33mGenerating docker-compose.yml...\033[0m"
    "$SCRIPT_DIR/generate-docker-compose.sh"
    
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        echo -e "\033[31mError: Failed to generate docker-compose.yml\033[0m"
        exit 1
    fi
fi

# Get credentials from user secrets
WEB_PROJECT_PATH="$ROOT_DIR/src/Web"
declare -A ENV_VARS

if [ -d "$WEB_PROJECT_PATH" ]; then
    cd "$WEB_PROJECT_PATH"
    
    # Get user secrets
    SECRETS_OUTPUT=$(dotnet user-secrets list 2>&1)
    if [ $? -eq 0 ]; then
        # Extract Docker passwords
        DB_PASSWORD=$(echo "$SECRETS_OUTPUT" | grep "Docker:DbPassword" | cut -d'=' -f2 | tr -d ' ')
        if [ ! -z "$DB_PASSWORD" ]; then
            ENV_VARS["SA_PASSWORD"]="$DB_PASSWORD"
            ENV_VARS["POSTGRES_PASSWORD"]="$DB_PASSWORD"
        fi
        
        REDIS_PASSWORD=$(echo "$SECRETS_OUTPUT" | grep "Docker:RedisPassword" | cut -d'=' -f2 | tr -d ' ')
        if [ ! -z "$REDIS_PASSWORD" ]; then
            ENV_VARS["REDIS_PASSWORD"]="$REDIS_PASSWORD"
        fi
        
        RABBITMQ_PASSWORD=$(echo "$SECRETS_OUTPUT" | grep "Docker:RabbitMQPassword" | cut -d'=' -f2 | tr -d ' ')
        if [ ! -z "$RABBITMQ_PASSWORD" ]; then
            ENV_VARS["RABBITMQ_DEFAULT_PASS"]="$RABBITMQ_PASSWORD"
        fi
    fi
    
    cd - > /dev/null
fi

# Start the database
echo -e "\n\033[33mStarting database container...\033[0m"

cd "$ROOT_DIR"

# Export environment variables for docker-compose
for key in "${!ENV_VARS[@]}"; do
    export "$key"="${ENV_VARS[$key]}"
done

docker-compose up -d

if [ $? -eq 0 ]; then
    echo -e "\n\033[32m[OK] Database started successfully!\033[0m"
    
    # Show connection information based on available services
    echo -e "\n\033[36mConnection Information:\033[0m"
    
    # Check which services are available
    DOCKER_DIR="$ROOT_DIR/docker"
    
    if [ -f "$DOCKER_DIR/docker-compose.sqlserver.yml" ]; then
        echo -e "\n\033[33mSQL Server:\033[0m"
        echo "  Server: localhost,1433"
        echo "  Database: Create your own database"
        echo "  Username: sa"
    fi
    
    if [ -f "$DOCKER_DIR/docker-compose.postgresql.yml" ]; then
        echo -e "\n\033[33mPostgreSQL:\033[0m"
        echo "  Server: localhost"
        echo "  Port: 5432"
        echo "  Database: CleanArchitectureDb"
        echo "  Username: postgres"
    fi
    
    if [ -f "$DOCKER_DIR/docker-compose.redis.yml" ]; then
        echo -e "\n\033[33mRedis Cache:\033[0m"
        echo "  Server: localhost"
        echo "  Port: 6379"
    fi
    
    if [ -f "$DOCKER_DIR/docker-compose.rabbitmq.yml" ]; then
        echo -e "\n\033[33mRabbitMQ:\033[0m"
        echo "  Server: localhost"
        echo "  Ports: 5672 (AMQP), 15672 (Management)"
        echo "  Management UI: http://localhost:15672"
        echo "  Username: admin"
    fi
    
    echo -e "\n\033[33mTo stop the database, run:\033[0m"
    echo -e "  \033[37m./scripts/stop-database.sh\033[0m"
    
    echo -e "\n\033[33mTo view credentials, run:\033[0m"
    echo -e "  \033[37m./scripts/show-credentials.sh\033[0m"
    
    echo -e "\n\033[90mNote: Credentials are stored in .NET User Secrets\033[0m"
    echo -e "\033[90mRun 'dotnet build' in src/Web to auto-generate them\033[0m"
    
    echo -e "\n\033[33mTo view logs, run:\033[0m"
    echo -e "  \033[37mdocker-compose logs -f\033[0m"
else
    echo -e "\033[31mError: Failed to start database container\033[0m"
    exit 1
fi