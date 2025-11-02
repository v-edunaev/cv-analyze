#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validate Docker configuration for CV Analyzer.

.DESCRIPTION
    This script validates the Docker setup and configuration files.
#>

# Color output functions
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "ℹ $Message" -ForegroundColor Cyan }

Write-Host "Docker Configuration Validation" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow
Write-Host ""

$ErrorCount = 0

# Check Docker files
Write-Info "Checking Docker configuration files..."

$DockerFiles = @(
    @{ Path = "docker-compose.yml"; Description = "Docker Compose configuration" },
    @{ Path = "backend/Dockerfile"; Description = "Backend Dockerfile" },
    @{ Path = "frontend/Dockerfile"; Description = "Frontend Dockerfile" }
)

foreach ($file in $DockerFiles) {
    if (Test-Path $file.Path) {
        Write-Success "Found $($file.Path) - $($file.Description)"
    } else {
        Write-Error "Missing $($file.Path) - $($file.Description)"
        $ErrorCount++
    }
}

Write-Host ""

# Validate backend Dockerfile
Write-Info "Validating backend Dockerfile structure..."

if (Test-Path "backend/Dockerfile") {
    $dockerfileContent = Get-Content "backend/Dockerfile" -Raw
    
    # Check for consolidated solution file usage
    if ($dockerfileContent -match "analyze-cv\.sln") {
        Write-Success "Backend Dockerfile uses consolidated solution file (analyze-cv.sln)"
    } else {
        Write-Warning "Backend Dockerfile may not be using the correct solution file"
    }
    
    # Check for multi-stage build
    if ($dockerfileContent -match "FROM.*AS build" -and $dockerfileContent -match "FROM.*AS runtime") {
        Write-Success "Backend Dockerfile uses multi-stage build"
    } else {
        Write-Warning "Backend Dockerfile should use multi-stage build for optimization"
    }
    
    # Check for proper WORKDIR
    if ($dockerfileContent -match "WORKDIR /src") {
        Write-Success "Backend Dockerfile has proper working directory setup"
    } else {
        Write-Warning "Backend Dockerfile should set WORKDIR /src for build stage"
    }
} else {
    Write-Error "Backend Dockerfile not found"
    $ErrorCount++
}

Write-Host ""

# Validate docker-compose.yml
Write-Info "Validating docker-compose.yml structure..."

if (Test-Path "docker-compose.yml") {
    $composeContent = Get-Content "docker-compose.yml" -Raw
    
    # Check for correct backend build context
    if ($composeContent -match "context:\s*\." -and $composeContent -match "dockerfile:\s*backend/Dockerfile") {
        Write-Success "Docker Compose uses correct backend build context (root directory)"
    } elseif ($composeContent -match "context:\s*\./backend") {
        Write-Warning "Docker Compose uses old backend build context - should use root directory"
    } else {
        Write-Error "Docker Compose backend build context configuration issue"
        $ErrorCount++
    }
    
    # Check for required services
    $requiredServices = @("database", "backend", "frontend")
    $allServicesFound = $true
    
    foreach ($service in $requiredServices) {
        if ($composeContent -match "${service}:") {
            Write-Success "Found required service: $service"
        } else {
            Write-Error "Missing required service: $service"
            $allServicesFound = $false
            $ErrorCount++
        }
    }
    
    if ($allServicesFound) {
        Write-Success "All required services are defined"
    }
} else {
    Write-Error "docker-compose.yml not found"
    $ErrorCount++
}

Write-Host ""

# Check for environment files
Write-Info "Checking environment configuration..."

$EnvFiles = @(
    @{ Path = ".env.docker.example"; Description = "Docker environment template"; Required = $false },
    @{ Path = ".env"; Description = "Local environment file"; Required = $false }
)

foreach ($file in $EnvFiles) {
    if (Test-Path $file.Path) {
        Write-Success "Found $($file.Path) - $($file.Description)"
    } else {
        if ($file.Required) {
            Write-Error "Missing $($file.Path) - $($file.Description)"
            $ErrorCount++
        } else {
            Write-Info "Optional file not found: $($file.Path) - $($file.Description)"
        }
    }
}

Write-Host ""

# Summary
Write-Host "Validation Summary" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow

if ($ErrorCount -eq 0) {
    Write-Success "Docker configuration is properly set up!"
    Write-Host ""
    Write-Info "Next steps for Docker development:"
    Write-Info "  1. Ensure Docker is installed and running"
    Write-Info "  2. Set up environment: .\setup-env.ps1"
    Write-Info "  3. Build and run: docker-compose up --build"
    Write-Info "  4. Access the application at http://localhost"
} else {
    Write-Error "Found $ErrorCount issues that need to be resolved."
    Write-Info "Please fix the errors above before using Docker."
}

Write-Host ""
Write-Info "For Docker usage instructions, see README.md"

exit $ErrorCount