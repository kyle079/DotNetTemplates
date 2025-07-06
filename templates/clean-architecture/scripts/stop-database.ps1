#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Stops the development database Docker container.

.DESCRIPTION
    This script stops and removes the database container started by start-database.ps1.
    Data is preserved in Docker volumes.

.PARAMETER RemoveVolumes
    If specified, also removes the data volumes (WARNING: This will delete all data!)

.EXAMPLE
    ./scripts/stop-database.ps1
    
.EXAMPLE
    ./scripts/stop-database.ps1 -RemoveVolumes
#>

param(
    [switch]$RemoveVolumes
)

$ErrorActionPreference = "Stop"

Write-Host "Stopping Development Database" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Check if docker-compose exists
$dockerComposeFile = Join-Path $PSScriptRoot "../docker-compose.yml"
if (-not (Test-Path $dockerComposeFile)) {
    Write-Error "docker-compose.yml not found at: $dockerComposeFile"
    exit 1
}

# Get credentials from user secrets to set environment variables
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

# Stop the database
Write-Host "`nStopping database container..." -ForegroundColor Yellow

Push-Location (Split-Path $dockerComposeFile -Parent)
try {
    # Set environment variables for docker-compose
    foreach ($key in $envVars.Keys) {
        [Environment]::SetEnvironmentVariable($key, $envVars[$key], [EnvironmentVariableTarget]::Process)
    }
    
    if ($RemoveVolumes) {
        Write-Warning "This will remove all database data! Are you sure? (y/N)"
        $confirmation = Read-Host
        if ($confirmation -ne 'y') {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            exit 0
        }
        
        docker-compose down -v
    }
    else {
        docker-compose down
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[OK] Database stopped successfully!" -ForegroundColor Green
        
        if (-not $RemoveVolumes) {
            Write-Host "`nNote: Database data is preserved in Docker volumes." -ForegroundColor Gray
            Write-Host "To remove data as well, run:" -ForegroundColor Yellow
            Write-Host "  ./scripts/stop-database.ps1 -RemoveVolumes" -ForegroundColor White
        }
    }
    else {
        Write-Error "Failed to stop database container"
        exit 1
    }
}
finally {
    Pop-Location
}