#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Displays the Docker service credentials from .NET User Secrets.

.DESCRIPTION
    This script shows the credentials for all configured Docker services
    that are stored in .NET User Secrets.
#>

$ErrorActionPreference = "Stop"

Write-Host "Docker Service Credentials" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan

$webProjectPath = Join-Path (Split-Path $PSScriptRoot -Parent) "src/Web"

# Check if the Web project exists
if (-not (Test-Path $webProjectPath)) {
    Write-Error "Web project not found at: $webProjectPath"
    exit 1
}

# Change to Web project directory
Push-Location $webProjectPath
try {
    # Get user secrets
    $secrets = & dotnet user-secrets list 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`nNo user secrets found. Run the project build first to initialize them." -ForegroundColor Yellow
        Write-Host "The credentials will be generated automatically on first build." -ForegroundColor Gray
        exit 0
    }
    
    # Parse and display secrets
    $dockerSecrets = $secrets | Where-Object { $_ -match "Docker:" -or $_ -match "ConnectionStrings:" -or $_ -match "RabbitMQ:" }
    
    if ($dockerSecrets.Count -eq 0) {
        Write-Host "`nNo Docker credentials found in user secrets." -ForegroundColor Yellow
        Write-Host "Build the Web project to automatically generate them." -ForegroundColor Gray
    } else {
        Write-Host "`nDocker Credentials:" -ForegroundColor Yellow
        
        # Display database credentials
        $dbPassword = $secrets | Where-Object { $_ -match "Docker:DbPassword" }
        if ($dbPassword) {
            $password = ($dbPassword -split "=")[1].Trim()
            Write-Host "`nDatabase:" -ForegroundColor Cyan
            Write-Host "  Username: sa (SQL Server) / postgres (PostgreSQL)" -ForegroundColor White
            Write-Host "  Password: $password" -ForegroundColor White
        }
        
        # Display Redis credentials
        $redisPassword = $secrets | Where-Object { $_ -match "Docker:RedisPassword" }
        if ($redisPassword) {
            $password = ($redisPassword -split "=")[1].Trim()
            Write-Host "`nRedis:" -ForegroundColor Cyan
            Write-Host "  Password: $password" -ForegroundColor White
        }
        
        # Display RabbitMQ credentials
        $rabbitPassword = $secrets | Where-Object { $_ -match "Docker:RabbitMQPassword" }
        if ($rabbitPassword) {
            $password = ($rabbitPassword -split "=")[1].Trim()
            Write-Host "`nRabbitMQ:" -ForegroundColor Cyan
            Write-Host "  Username: admin" -ForegroundColor White
            Write-Host "  Password: $password" -ForegroundColor White
            Write-Host "  Management UI: http://localhost:15672" -ForegroundColor White
        }
        
        Write-Host "`n[!] These credentials are stored securely in .NET User Secrets" -ForegroundColor Green
        Write-Host "[!] To view all secrets, run:" -ForegroundColor Yellow
        Write-Host "    cd src/Web" -ForegroundColor White
        Write-Host "    dotnet user-secrets list" -ForegroundColor White
    }
}
finally {
    Pop-Location
}