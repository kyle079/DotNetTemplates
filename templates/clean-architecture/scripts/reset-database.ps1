#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Resets the development database by removing all data and restarting fresh.

.DESCRIPTION
    This script stops the database container, removes all data, and starts a fresh instance.
    It will also run migrations if the Web project is available.

.PARAMETER SkipMigrations
    If specified, doesn't run Entity Framework migrations after starting the database.

.EXAMPLE
    ./scripts/reset-database.ps1
    
.EXAMPLE
    ./scripts/reset-database.ps1 -SkipMigrations
#>

param(
    [switch]$SkipMigrations
)

$ErrorActionPreference = "Stop"

Write-Host "Resetting Development Database" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""
Write-Warning "This will DELETE all data in the development database!"
Write-Host "Are you sure you want to continue? (y/N)" -NoNewline
$confirmation = Read-Host

if ($confirmation -ne 'y') {
    Write-Host "`nOperation cancelled." -ForegroundColor Yellow
    exit 0
}

# Stop and remove the database with volumes
Write-Host "`nStopping and removing database..." -ForegroundColor Yellow
& "$PSScriptRoot/stop-database.ps1" -RemoveVolumes

# Wait a moment for cleanup
Start-Sleep -Seconds 2

# Start fresh database
Write-Host "`nStarting fresh database..." -ForegroundColor Yellow
& "$PSScriptRoot/start-database.ps1"

# Run migrations if requested
if (-not $SkipMigrations) {
    Write-Host "`nWaiting for database to be ready..." -ForegroundColor Yellow
    
    # Get the project name from the parent directory name or docker-compose.yml
    $projectRoot = Split-Path $PSScriptRoot -Parent
    $projectName = (Get-Item $projectRoot).Name.ToLower() -replace '[^a-z0-9]', ''
    
    # Get database password from user secrets
    $webProjectPath = Join-Path $projectRoot "src/Web"
    $dbPassword = "Your_password123!"
    
    if (Test-Path $webProjectPath) {
        Push-Location $webProjectPath
        try {
            $secrets = & dotnet user-secrets list 2>&1
            if ($LASTEXITCODE -eq 0) {
                $dbPasswordLine = $secrets | Where-Object { $_ -match "Docker:DbPassword" }
                if ($dbPasswordLine) {
                    $dbPassword = ($dbPasswordLine -split "=")[1].Trim()
                }
            }
        }
        finally {
            Pop-Location
        }
    }
    
    #if (UseSqlServer)
    # Wait for SQL Server to be ready
    $maxRetries = 30
    $retryCount = 0
    $containerName = "${projectName}-sqlserver"
    while ($retryCount -lt $maxRetries) {
        try {
            docker exec $containerName /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "$dbPassword" -Q "SELECT 1" | Out-Null
            break
        }
        catch {
            $retryCount++
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 1
        }
    }
    #endif
    
    #if (UsePostgreSQL)
    # Wait for PostgreSQL to be ready
    $maxRetries = 30
    $retryCount = 0
    $containerName = "${projectName}-postgresql"
    while ($retryCount -lt $maxRetries) {
        try {
            docker exec $containerName pg_isready -U postgres | Out-Null
            if ($LASTEXITCODE -eq 0) { break }
        }
        catch {
            # Ignore errors
        }
        $retryCount++
        Write-Host "." -NoNewline
        Start-Sleep -Seconds 1
    }
    #endif
    
    Write-Host ""
    
    # Check if we're in the right directory structure
    $webProjectPath = Join-Path (Split-Path $PSScriptRoot -Parent) "src/Web"
    if (Test-Path $webProjectPath) {
        Write-Host "`nRunning Entity Framework migrations..." -ForegroundColor Yellow
        
        Push-Location $webProjectPath
        try {
            dotnet ef database update
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "`n[OK] Database reset and migrations applied successfully!" -ForegroundColor Green
            }
            else {
                Write-Warning "Failed to apply migrations. You may need to run them manually."
            }
        }
        finally {
            Pop-Location
        }
    }
    else {
        Write-Host "`nNote: Run Entity Framework migrations from your Web project to set up the database schema." -ForegroundColor Yellow
    }
}
else {
    Write-Host "`n[OK] Database reset successfully!" -ForegroundColor Green
    Write-Host "`nNote: Migrations were skipped. Run them manually when ready." -ForegroundColor Yellow
}