#!/bin/bash
#
# Displays the Docker service credentials from .NET User Secrets.
#
# This script shows the credentials for all configured Docker services
# that are stored in .NET User Secrets.
#
# Usage: ./scripts/show-credentials.sh
#

set -e

echo -e "\033[36mDocker Service Credentials\033[0m"
echo -e "\033[36m==========================\033[0m"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
WEB_PROJECT_PATH="$ROOT_DIR/src/Web"

# Check if the Web project exists
if [ ! -d "$WEB_PROJECT_PATH" ]; then
    echo -e "\033[31mError: Web project not found at: $WEB_PROJECT_PATH\033[0m"
    exit 1
fi

# Change to Web project directory
cd "$WEB_PROJECT_PATH"

# Get user secrets
SECRETS_OUTPUT=$(dotnet user-secrets list 2>&1)

if [ $? -ne 0 ]; then
    echo -e "\n\033[33mNo user secrets found. Run the project build first to initialize them.\033[0m"
    echo -e "\033[90mThe credentials will be generated automatically on first build.\033[0m"
    exit 0
fi

# Parse and display secrets
DOCKER_SECRETS=$(echo "$SECRETS_OUTPUT" | grep -E "Docker:|ConnectionStrings:|RabbitMQ:")

if [ -z "$DOCKER_SECRETS" ]; then
    echo -e "\n\033[33mNo Docker credentials found in user secrets.\033[0m"
    echo -e "\033[90mBuild the Web project to automatically generate them.\033[0m"
else
    echo -e "\n\033[33mDocker Credentials:\033[0m"
    
    # Display database credentials
    DB_PASSWORD=$(echo "$SECRETS_OUTPUT" | grep "Docker:DbPassword" | cut -d'=' -f2 | tr -d ' ')
    if [ ! -z "$DB_PASSWORD" ]; then
        echo -e "\n\033[36mDatabase:\033[0m"
        echo -e "  \033[37mUsername: sa (SQL Server) / postgres (PostgreSQL)\033[0m"
        echo -e "  \033[37mPassword: $DB_PASSWORD\033[0m"
    fi
    
    # Display Redis credentials
    REDIS_PASSWORD=$(echo "$SECRETS_OUTPUT" | grep "Docker:RedisPassword" | cut -d'=' -f2 | tr -d ' ')
    if [ ! -z "$REDIS_PASSWORD" ]; then
        echo -e "\n\033[36mRedis:\033[0m"
        echo -e "  \033[37mPassword: $REDIS_PASSWORD\033[0m"
    fi
    
    # Display RabbitMQ credentials
    RABBITMQ_PASSWORD=$(echo "$SECRETS_OUTPUT" | grep "Docker:RabbitMQPassword" | cut -d'=' -f2 | tr -d ' ')
    if [ ! -z "$RABBITMQ_PASSWORD" ]; then
        echo -e "\n\033[36mRabbitMQ:\033[0m"
        echo -e "  \033[37mUsername: admin\033[0m"
        echo -e "  \033[37mPassword: $RABBITMQ_PASSWORD\033[0m"
        echo -e "  \033[37mManagement UI: http://localhost:15672\033[0m"
    fi
    
    echo -e "\n\033[32m[!] These credentials are stored securely in .NET User Secrets\033[0m"
    echo -e "\033[33m[!] To view all secrets, run:\033[0m"
    echo -e "    \033[37mcd src/Web\033[0m"
    echo -e "    \033[37mdotnet user-secrets list\033[0m"
fi