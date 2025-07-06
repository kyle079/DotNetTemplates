#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Starts the development database using Docker Compose.

.DESCRIPTION
    This script starts the appropriate database container based on the project configuration.
    It will pull the required Docker images if they don't exist locally.

.EXAMPLE
    ./scripts/start-database.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host "Starting Development Database" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Check if Docker is running
try {
    docker version | Out-Null
}
catch {
    Write-Error "Docker is not running. Please start Docker Desktop and try again."
    exit 1
}

# Generate docker-compose.yml if it doesn't exist
$dockerComposeFile = Join-Path $PSScriptRoot "../docker-compose.yml"
if (-not (Test-Path $dockerComposeFile)) {
    Write-Host "Generating docker-compose.yml..." -ForegroundColor Yellow
    & "$PSScriptRoot/generate-docker-compose.ps1"
    
    if (-not (Test-Path $dockerComposeFile)) {
        Write-Error "Failed to generate docker-compose.yml"
        exit 1
    }
}

# Get credentials from user secrets
$webProjectPath = Join-Path (Split-Path $PSScriptRoot -Parent) "src/Web"
$envVars = @{}

if (Test-Path $webProjectPath) {
    Push-Location $webProjectPath
    try {
        # Get user secrets
        $secrets = & dotnet user-secrets list 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            # Extract Docker passwords
            $dbPasswordLine = $secrets | Where-Object { $_ -match "Docker:DbPassword" }
            if ($dbPasswordLine) {
                $envVars["SA_PASSWORD"] = ($dbPasswordLine -split "=")[1].Trim()
                $envVars["POSTGRES_PASSWORD"] = ($dbPasswordLine -split "=")[1].Trim()
            }
            
            $redisPasswordLine = $secrets | Where-Object { $_ -match "Docker:RedisPassword" }
            if ($redisPasswordLine) {
                $envVars["REDIS_PASSWORD"] = ($redisPasswordLine -split "=")[1].Trim()
            }
            
            $rabbitPasswordLine = $secrets | Where-Object { $_ -match "Docker:RabbitMQPassword" }
            if ($rabbitPasswordLine) {
                $envVars["RABBITMQ_DEFAULT_PASS"] = ($rabbitPasswordLine -split "=")[1].Trim()
            }
        }
    }
    finally {
        Pop-Location
    }
}

# Start the database
Write-Host "`nStarting database container..." -ForegroundColor Yellow

Push-Location (Split-Path $dockerComposeFile -Parent)
try {
    # Set environment variables for docker-compose
    foreach ($key in $envVars.Keys) {
        [Environment]::SetEnvironmentVariable($key, $envVars[$key], [EnvironmentVariableTarget]::Process)
    }
    
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[OK] Database started successfully!" -ForegroundColor Green
        
        # Show connection information based on available services
        Write-Host "`nConnection Information:" -ForegroundColor Cyan
        
        # Check which services are available
        $dockerDir = Join-Path (Split-Path $PSScriptRoot -Parent) "docker"
        
        if (Test-Path "$dockerDir/docker-compose.sqlserver.yml") {
            Write-Host "`nSQL Server:" -ForegroundColor Yellow
            Write-Host "  Server: localhost,1433"
            Write-Host "  Database: Create your own database"
            Write-Host "  Username: sa"
        }
        
        if (Test-Path "$dockerDir/docker-compose.postgresql.yml") {
            Write-Host "`nPostgreSQL:" -ForegroundColor Yellow
            Write-Host "  Server: localhost"
            Write-Host "  Port: 5432"
            Write-Host "  Database: CleanArchitectureDb"
            Write-Host "  Username: postgres"
        }
        
        if (Test-Path "$dockerDir/docker-compose.redis.yml") {
            Write-Host "`nRedis Cache:" -ForegroundColor Yellow
            Write-Host "  Server: localhost"
            Write-Host "  Port: 6379"
        }
        
        if (Test-Path "$dockerDir/docker-compose.rabbitmq.yml") {
            Write-Host "`nRabbitMQ:" -ForegroundColor Yellow
            Write-Host "  Server: localhost"
            Write-Host "  Ports: 5672 (AMQP), 15672 (Management)"
            Write-Host "  Management UI: http://localhost:15672"
            Write-Host "  Username: admin"
        }
        
        Write-Host "`nTo stop the database, run:" -ForegroundColor Yellow
        Write-Host "  ./scripts/stop-database.ps1" -ForegroundColor White
        
        Write-Host "`nTo view credentials, run:" -ForegroundColor Yellow
        Write-Host "  ./scripts/show-credentials.ps1" -ForegroundColor White
        
        Write-Host "`nNote: Credentials are stored in .NET User Secrets" -ForegroundColor Gray
        Write-Host "Run 'dotnet build' in src/Web to auto-generate them" -ForegroundColor Gray
        
        Write-Host "`nTo view logs, run:" -ForegroundColor Yellow
        Write-Host "  docker-compose logs -f" -ForegroundColor White
    }
    else {
        Write-Error "Failed to start database container"
        exit 1
    }
}
finally {
    Pop-Location
}