#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs all .NET templates from this repository.

.DESCRIPTION
    This script installs all templates found in the templates directory to your local
    .NET CLI template cache, making them available for use with 'dotnet new'.

.EXAMPLE
    ./scripts/install-all.ps1
#>

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

Write-Host "Installing .NET Templates" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

# Get the repository root
$repoRoot = Split-Path -Parent $PSScriptRoot
$templatesDir = Join-Path $repoRoot "templates"

# Check if templates directory exists
if (-not (Test-Path $templatesDir)) {
    Write-Error "Templates directory not found at: $templatesDir"
    exit 1
}

# Get all template directories (those containing .template.config folder)
$templateDirs = Get-ChildItem -Path $templatesDir -Directory | 
    Where-Object { Test-Path (Join-Path $_.FullName ".template.config") }

if ($templateDirs.Count -eq 0) {
    Write-Warning "No templates found in $templatesDir"
    exit 0
}

Write-Host "`nFound $($templateDirs.Count) template(s) to install:`n" -ForegroundColor Green

$installed = 0
$failed = 0

foreach ($template in $templateDirs) {
    Write-Host "Installing: $($template.Name)" -ForegroundColor Yellow
    
    try {
        # Install the template
        dotnet new install $template.FullName --force
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Successfully installed $($template.Name)" -ForegroundColor Green
            $installed++
        } else {
            Write-Host "✗ Failed to install $($template.Name)" -ForegroundColor Red
            $failed++
        }
    }
    catch {
        Write-Host "✗ Error installing $($template.Name): $_" -ForegroundColor Red
        $failed++
    }
    
    Write-Host ""
}

# Summary
Write-Host "Installation Summary" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Installed: $installed" -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host "Failed: $failed" -ForegroundColor Red
}

Write-Host "`nTo see installed templates, run:" -ForegroundColor Yellow
Write-Host "  dotnet new list" -ForegroundColor White

Write-Host "`nTo create a new project from a template, run:" -ForegroundColor Yellow
Write-Host "  dotnet new <template-short-name> -n <project-name>" -ForegroundColor White

if ($failed -gt 0) {
    exit 1
}