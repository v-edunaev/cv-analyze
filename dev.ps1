#!/usr/bin/env pwsh
<#
.SYNOPSIS
    CV Analyzer - Quick Script Launcher

.DESCRIPTION
    Provides easy access to common development tasks for the CV Analyzer project.
    All scripts are organized in the scripts/ folder.

.PARAMETER Action
    The action to perform.

.EXAMPLE
    .\dev.ps1 build
    .\dev.ps1 test
    .\dev.ps1 validate
    .\dev.ps1 docker-validate
    .\dev.ps1 deploy-k8s
    .\dev.ps1 setup-minikube
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0, HelpMessage = "Action to perform")]
    [ValidateSet("build", "test", "test-backend", "test-frontend", "validate", "docker-validate", "docker-build", "deploy-k8s", "setup-minikube", "cleanup-k8s", "setup-env", "clean", "install", "security-check", "help")]
    [string]$Action = "help"
)

# Color output functions
function Write-Title { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

Write-Title "CV Analyzer - Development Scripts"
Write-Host ""

switch ($Action) {
    "build" {
        Write-Info "Building and testing the solution..."
        & "scripts/build.ps1" -Test
    }
    "test" {
        Write-Info "Running tests only..."
        & "scripts/build.ps1" -Test
    }
    "test-backend" {
        Write-Info "Running backend tests with coverage..."
        Set-Location "backend"
        dotnet test --configuration Release --verbosity normal --collect:"XPlat Code Coverage" --results-directory ./coverage
        Set-Location ".."
    }
    "test-frontend" {
        Write-Info "Running frontend tests with coverage..."
        Set-Location "frontend"
        if (-not (Test-Path "node_modules")) {
            Write-Info "Installing frontend dependencies..."
            npm install
        }
        npm run test:coverage
        Set-Location ".."
    }
    "validate" {
        Write-Info "Validating project setup..."
        & "scripts/validate-setup.ps1"
    }
    "docker-validate" {
        Write-Info "Validating Docker configuration..."
        & "scripts/validate-docker.ps1"
    }
    "docker-build" {
        Write-Info "Testing Docker build..."
        & "scripts/test-docker-build.ps1"
    }
    "deploy-k8s" {
        Write-Info "Deploying to Kubernetes..."
        & "scripts/deploy-k8s.ps1"
    }
    "setup-minikube" {
        Write-Info "Setting up Minikube..."
        & "scripts/setup-minikube.ps1"
    }
    "cleanup-k8s" {
        Write-Info "Cleaning up Kubernetes resources..."
        & "scripts/cleanup-k8s.ps1"
    }
    "setup-env" {
        Write-Info "Setting up environment from GitHub secrets..."
        & "scripts/populate-env-from-secrets.ps1"
    }
    "clean" {
        Write-Info "Cleaning build artifacts..."
        # Backend clean
        Set-Location "backend"
        dotnet clean
        Remove-Item -Path "bin", "obj" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "coverage" -Recurse -Force -ErrorAction SilentlyContinue
        Set-Location ".."
        
        # Frontend clean
        Set-Location "frontend"
        Remove-Item -Path "dist", "coverage" -Recurse -Force -ErrorAction SilentlyContinue
        Set-Location ".."
    }
    "security-check" {
        Write-Info "Running comprehensive security scan..."
        & "scripts/security-scan.ps1" -Type all
    }
    "install" {
        Write-Info "Installing dependencies..."
        # Backend dependencies
        Write-Info "Installing backend dependencies..."
        Set-Location "backend"
        dotnet restore
        Set-Location ".."
        
        # Frontend dependencies
        Write-Info "Installing frontend dependencies..."
        Set-Location "frontend"
        npm install
        Set-Location ".."
    }
    "help" {
        Write-Info "Available commands:"
        Write-Host ""
        Write-Host "  build           - Build and test the solution" -ForegroundColor Green
        Write-Host "  test            - Run tests only" -ForegroundColor Green
        Write-Host "  test-backend    - Run backend tests with coverage" -ForegroundColor Green
        Write-Host "  test-frontend   - Run frontend tests with coverage" -ForegroundColor Green
        Write-Host "  validate        - Validate project setup" -ForegroundColor Green
        Write-Host "  docker-validate - Validate Docker configuration" -ForegroundColor Green
        Write-Host "  docker-build    - Test Docker build process" -ForegroundColor Green
        Write-Host "  deploy-k8s      - Deploy to Kubernetes" -ForegroundColor Green
        Write-Host "  setup-minikube  - Setup Minikube for local development" -ForegroundColor Green
        Write-Host "  cleanup-k8s     - Cleanup Kubernetes resources" -ForegroundColor Green
        Write-Host "  setup-env       - Setup environment from GitHub secrets" -ForegroundColor Green
        Write-Host "  clean           - Clean build artifacts" -ForegroundColor Green
        Write-Host "  install         - Install dependencies for both projects" -ForegroundColor Green
        Write-Host "  security-check  - Run security vulnerability checks" -ForegroundColor Green
        Write-Host ""
        Write-Info "Examples:"
        Write-Host "  .\dev.ps1 build" -ForegroundColor Gray
        Write-Host "  .\dev.ps1 test-frontend" -ForegroundColor Gray
        Write-Host "  .\dev.ps1 security-check" -ForegroundColor Gray
        Write-Host "  .\dev.ps1 validate" -ForegroundColor Gray
        Write-Host "  .\dev.ps1 docker-validate" -ForegroundColor Gray
        Write-Host ""
        Write-Info "All scripts are located in the scripts/ folder"
        Write-Host ""
        Write-Info "For Docker development:"
        Write-Host "  docker-compose up --build" -ForegroundColor Gray
        Write-Host ""
        Write-Info "For local development:"
        Write-Host "  dotnet run --project backend/CVAnalyzer.Api.csproj" -ForegroundColor Gray
        Write-Host "  cd frontend && npm run dev" -ForegroundColor Gray
    }
    default {
        Write-Error "Unknown action: $Action"
        & $MyInvocation.MyCommand.Path "help"
        exit 1
    }
}