#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Uninstalls all .NET templates from this repository.

.DESCRIPTION
    This script uninstalls all templates that were previously installed from this
    repository, removing them from your local .NET CLI template cache.

.EXAMPLE
    ./scripts/uninstall-all.ps1
#>

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $true

Write-Host "Uninstalling .NET Templates" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

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

Write-Host "`nFound $($templateDirs.Count) template(s) to uninstall:`n" -ForegroundColor Yellow

$uninstalled = 0
$failed = 0
$notInstalled = 0

foreach ($template in $templateDirs) {
    Write-Host "Checking: $($template.Name)" -ForegroundColor Yellow
    
    # Read template.json to get the short name
    $templateConfigPath = Join-Path $template.FullName ".template.config/template.json"
    
    try {
        $templateConfig = Get-Content $templateConfigPath -Raw | ConvertFrom-Json
        $shortName = $templateConfig.shortName
        
        # Check if template is installed
        $installedTemplates = dotnet new list 2>$null | Out-String
        
        if ($installedTemplates -match $shortName) {
            Write-Host "Uninstalling: $shortName ($($template.Name))" -ForegroundColor Yellow
            
            # Uninstall the template
            dotnet new uninstall $template.FullName
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Successfully uninstalled $($template.Name)" -ForegroundColor Green
                $uninstalled++
            } else {
                Write-Host "✗ Failed to uninstall $($template.Name)" -ForegroundColor Red
                $failed++
            }
        } else {
            Write-Host "- Template $shortName not currently installed" -ForegroundColor Gray
            $notInstalled++
        }
    }
    catch {
        Write-Host "✗ Error processing $($template.Name): $_" -ForegroundColor Red
        $failed++
    }
    
    Write-Host ""
}

# Summary
Write-Host "Uninstall Summary" -ForegroundColor Cyan
Write-Host "=================" -ForegroundColor Cyan
Write-Host "Uninstalled: $uninstalled" -ForegroundColor Green
Write-Host "Not installed: $notInstalled" -ForegroundColor Gray
if ($failed -gt 0) {
    Write-Host "Failed: $failed" -ForegroundColor Red
}

Write-Host "`nTo see remaining templates, run:" -ForegroundColor Yellow
Write-Host "  dotnet new list" -ForegroundColor White

if ($failed -gt 0) {
    exit 1
}