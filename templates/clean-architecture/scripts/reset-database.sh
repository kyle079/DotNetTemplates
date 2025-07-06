#!/bin/bash
#
# Resets the development database by removing all data and restarting fresh.
#
# This script stops the database container, removes all data, and starts a fresh instance.
# It will also run migrations if the Web project is available.
#
# Usage: ./scripts/reset-database.sh
# Usage: ./scripts/reset-database.sh --skip-migrations
#

set -e

# Parse command line arguments
SKIP_MIGRATIONS=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-migrations)
            SKIP_MIGRATIONS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-migrations]"
            exit 1
            ;;
    esac
done

echo -e "\033[36mResetting Development Database\033[0m"
echo -e "\033[36m==============================\033[0m"
echo ""
echo -e "\033[33mWarning: This will DELETE all data in the development database!\033[0m"
echo -n "Are you sure you want to continue? (y/N) "
read -r confirmation

if [ "$confirmation" != "y" ]; then
    echo -e "\n\033[33mOperation cancelled.\033[0m"
    exit 0
fi

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Stop and remove the database with volumes
echo -e "\n\033[33mStopping and removing database...\033[0m"
"$SCRIPT_DIR/stop-database.sh" -v

# Wait a moment for cleanup
sleep 2

# Start fresh database
echo -e "\n\033[33mStarting fresh database...\033[0m"
"$SCRIPT_DIR/start-database.sh"

# Run migrations if requested
if [ "$SKIP_MIGRATIONS" = false ]; then
    echo -e "\n\033[33mWaiting for database to be ready...\033[0m"
    
    #if (UseSqlServer)
    # Wait for SQL Server to be ready
    MAX_RETRIES=30
    RETRY_COUNT=0
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if docker exec cleanarchitecture-sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "Your_password123!" -Q "SELECT 1" > /dev/null 2>&1; then
            break
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo -n "."
        sleep 1
    done
    #endif
    
    #if (UsePostgreSQL)
    # Wait for PostgreSQL to be ready
    MAX_RETRIES=30
    RETRY_COUNT=0
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if docker exec cleanarchitecture-postgresql pg_isready -U postgres > /dev/null 2>&1; then
            break
        fi
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo -n "."
        sleep 1
    done
    #endif
    
    echo ""
    
    # Check if we're in the right directory structure
    WEB_PROJECT_PATH="$ROOT_DIR/src/Web"
    if [ -d "$WEB_PROJECT_PATH" ]; then
        echo -e "\n\033[33mRunning Entity Framework migrations...\033[0m"
        
        cd "$WEB_PROJECT_PATH"
        dotnet ef database update
        
        if [ $? -eq 0 ]; then
            echo -e "\n\033[32m[OK] Database reset and migrations applied successfully!\033[0m"
        else
            echo -e "\033[33mWarning: Failed to apply migrations. You may need to run them manually.\033[0m"
        fi
    else
        echo -e "\n\033[33mNote: Run Entity Framework migrations from your Web project to set up the database schema.\033[0m"
    fi
else
    echo -e "\n\033[32m[OK] Database reset successfully!\033[0m"
    echo -e "\n\033[33mNote: Migrations were skipped. Run them manually when ready.\033[0m"
fi