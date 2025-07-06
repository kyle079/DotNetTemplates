#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Tests all .NET templates by creating sample projects.

.DESCRIPTION
    This script tests all templates by creating sample projects with various
    configuration options to ensure they work correctly.

.PARAMETER OutputDir
    The directory where test projects will be created. Default is ./test-output

.PARAMETER KeepOutput
    If specified, test output will not be deleted after testing.

.EXAMPLE
    ./scripts/test-templates.ps1
    
.EXAMPLE
    ./scripts/test-templates.ps1 -OutputDir C:\temp\template-tests -KeepOutput
#>

param(
    [string]$OutputDir = "",
    [switch]$KeepOutput
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

Write-Host "Testing .NET Templates" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan

# Get the repository root
$repoRoot = Split-Path -Parent $PSScriptRoot

# Set output directory
if ([string]::IsNullOrEmpty($OutputDir)) {
    $OutputDir = Join-Path $repoRoot "test-output"
}

# Create output directory
if (Test-Path $OutputDir) {
    if (-not $KeepOutput) {
        Write-Host "`nCleaning existing output directory..." -ForegroundColor Yellow
        Remove-Item -Path $OutputDir -Recurse -Force
    }
}

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Write-Host "`nOutput directory: $OutputDir" -ForegroundColor Gray

# Define test scenarios for Clean Architecture template
$testScenarios = @(
    @{
        Name = "CA-Angular-SqlServer"
        Template = "ca-sln"
        Args = @("-cf", "Angular", "-d", "sqlserver")
    },
    @{
        Name = "CA-React-PostgreSQL"
        Template = "ca-sln"
        Args = @("-cf", "React", "-d", "postgresql")
    },
    @{
        Name = "CA-ApiOnly-SQLite"
        Template = "ca-sln"
        Args = @("-cf", "None", "-d", "sqlite")
    },
    @{
        Name = "CA-Angular-Aspire"
        Template = "ca-sln"
        Args = @("-cf", "Angular", "--use-aspire", "true")
    }
)

$totalTests = $testScenarios.Count
$passed = 0
$failed = 0

Write-Host "`nRunning $totalTests test scenarios...`n" -ForegroundColor Yellow

foreach ($scenario in $testScenarios) {
    Write-Host "Test: $($scenario.Name)" -ForegroundColor Cyan
    Write-Host "Template: $($scenario.Template)" -ForegroundColor Gray
    Write-Host "Arguments: $($scenario.Args -join ' ')" -ForegroundColor Gray
    
    $projectPath = Join-Path $OutputDir $scenario.Name
    
    try {
        # Create the project
        Write-Host "Creating project..." -NoNewline
        
        $args = @("new", $scenario.Template, "-n", $scenario.Name, "-o", $projectPath) + $scenario.Args
        
        $process = Start-Process -FilePath "dotnet" -ArgumentList $args -NoNewWindow -PassThru -Wait
        
        if ($process.ExitCode -eq 0) {
            Write-Host " Done" -ForegroundColor Green
            
            # Try to build the project
            Write-Host "Building project..." -NoNewline
            
            Push-Location $projectPath
            try {
                dotnet build --configuration Release --verbosity quiet
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host " Done" -ForegroundColor Green
                    Write-Host "[OK] Test passed" -ForegroundColor Green
                    $passed++
                } else {
                    Write-Host " Failed" -ForegroundColor Red
                    Write-Host "[FAIL] Build failed" -ForegroundColor Red
                    $failed++
                }
            }
            finally {
                Pop-Location
            }
        } else {
            Write-Host " Failed" -ForegroundColor Red
            Write-Host "[FAIL] Project creation failed" -ForegroundColor Red
            $failed++
        }
    }
    catch {
        Write-Host "[FAIL] Error: $_" -ForegroundColor Red
        $failed++
    }
    
    Write-Host ""
}

# Summary
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "============" -ForegroundColor Cyan
Write-Host "Total: $totalTests" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "Failed: $failed" -ForegroundColor Red
}

# Cleanup
if (-not $KeepOutput -and $failed -eq 0) {
    Write-Host "`nCleaning up test output..." -ForegroundColor Yellow
    Remove-Item -Path $OutputDir -Recurse -Force
} elseif ($KeepOutput -or $failed -gt 0) {
    Write-Host "`nTest output kept at: $OutputDir" -ForegroundColor Yellow
}

if ($failed -gt 0) {
    exit 1
}