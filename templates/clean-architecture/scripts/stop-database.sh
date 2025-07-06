#!/bin/bash
#
# Stops the development database Docker container.
#
# This script stops and removes the database container started by start-database.sh.
# Data is preserved in Docker volumes.
#
# Usage: ./scripts/stop-database.sh
# Usage: ./scripts/stop-database.sh -v   # Also removes volumes (WARNING: deletes all data!)
#

set -e

# Parse command line arguments
REMOVE_VOLUMES=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--remove-volumes)
            REMOVE_VOLUMES=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [-v|--remove-volumes]"
            exit 1
            ;;
    esac
done

echo -e "\033[36mStopping Development Database\033[0m"
echo -e "\033[36m=============================\033[0m"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_COMPOSE_FILE="$ROOT_DIR/docker-compose.yml"

# Check if docker-compose exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "\033[31mError: docker-compose.yml not found at: $DOCKER_COMPOSE_FILE\033[0m"
    exit 1
fi

# Stop the database
echo -e "\n\033[33mStopping database container...\033[0m"

cd "$ROOT_DIR"

if [ "$REMOVE_VOLUMES" = true ]; then
    echo -e "\033[33mWarning: This will remove all database data! Are you sure? (y/N)\033[0m"
    read -r confirmation
    if [ "$confirmation" != "y" ]; then
        echo -e "\033[33mOperation cancelled.\033[0m"
        exit 0
    fi
    
    docker-compose down -v
else
    docker-compose down
fi

if [ $? -eq 0 ]; then
    echo -e "\n\033[32m[OK] Database stopped successfully!\033[0m"
    
    if [ "$REMOVE_VOLUMES" = false ]; then
        echo -e "\n\033[90mNote: Database data is preserved in Docker volumes.\033[0m"
        echo -e "\033[33mTo remove data as well, run:\033[0m"
        echo -e "  \033[37m./scripts/stop-database.sh -v\033[0m"
    fi
else
    echo -e "\033[31mError: Failed to stop database container\033[0m"
    exit 1
fi