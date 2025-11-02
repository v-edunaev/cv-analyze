#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Test Docker build for CV Analyzer backend.

.DESCRIPTION
    This script tests the Docker build process to ensure all dependencies resolve correctly.
    Useful for debugging Docker build issues before pushing to CI/CD.

.PARAMETER SkipCache
    Skip Docker build cache for a clean build.

.EXAMPLE
    .\test-docker-build.ps1
    
.EXAMPLE
    .\test-docker-build.ps1 -SkipCache
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Skip Docker build cache")]
    [switch]$SkipCache
)

# Color output functions
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "ℹ $Message" -ForegroundColor Cyan }

Write-Host "CV Analyzer - Docker Build Test" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow
Write-Host ""

# Check if Docker is available
try {
    $dockerVersion = docker --version 2>$null
    if (-not $dockerVersion) {
        Write-Error "Docker is not installed or not running"
        Write-Info "Please install Docker Desktop and ensure it's running"
        exit 1
    }
    Write-Success "Docker found: $dockerVersion"
} catch {
    Write-Error "Docker is not available"
    Write-Info "Please install Docker Desktop and ensure it's running"
    exit 1
}

Write-Host ""

# Build arguments
$buildArgs = @("build", "-f", "backend/Dockerfile", "-t", "cv-analyzer-backend-test")

if ($SkipCache) {
    $buildArgs += "--no-cache"
    Write-Info "Building without cache (clean build)..."
} else {
    Write-Info "Building with cache..."
}

$buildArgs += "."

Write-Info "Running: docker $($buildArgs -join ' ')"
Write-Host ""

try {
    # Run Docker build
    & docker @buildArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Success "Docker build completed successfully!"
        Write-Host ""
        Write-Info "Image created: cv-analyzer-backend-test"
        Write-Info "To run the container:"
        Write-Host "  docker run -p 5050:5050 cv-analyzer-backend-test" -ForegroundColor Gray
        Write-Host ""
        Write-Info "To clean up the test image:"
        Write-Host "  docker rmi cv-analyzer-backend-test" -ForegroundColor Gray
    } else {
        Write-Error "Docker build failed with exit code $LASTEXITCODE"
        Write-Host ""
        Write-Info "Common fixes:"
        Write-Info "  1. Ensure Directory.Packages.props is in the backend folder"
        Write-Info "  2. Check package versions are compatible with .NET 8"
        Write-Info "  3. Verify Dockerfile copies all required files"
        Write-Info "  4. Try running with -SkipCache for a clean build"
        exit 1
    }
} catch {
    Write-Error "Failed to run Docker build: $($_.Exception.Message)"
    exit 1
}