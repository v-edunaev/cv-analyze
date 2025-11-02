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
    [ValidateSet("build", "test", "validate", "docker-validate", "deploy-k8s", "setup-minikube", "cleanup-k8s", "setup-env", "help")]
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
    "validate" {
        Write-Info "Validating project setup..."
        & "scripts/validate-setup.ps1"
    }
    "docker-validate" {
        Write-Info "Validating Docker configuration..."
        & "scripts/validate-docker.ps1"
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
    "help" {
        Write-Info "Available commands:"
        Write-Host ""
        Write-Host "  build           - Build and test the solution" -ForegroundColor Green
        Write-Host "  test            - Run tests only" -ForegroundColor Green
        Write-Host "  validate        - Validate project setup" -ForegroundColor Green
        Write-Host "  docker-validate - Validate Docker configuration" -ForegroundColor Green
        Write-Host "  deploy-k8s      - Deploy to Kubernetes" -ForegroundColor Green
        Write-Host "  setup-minikube  - Setup Minikube for local development" -ForegroundColor Green
        Write-Host "  cleanup-k8s     - Cleanup Kubernetes resources" -ForegroundColor Green
        Write-Host "  setup-env       - Setup environment from GitHub secrets" -ForegroundColor Green
        Write-Host ""
        Write-Info "Examples:"
        Write-Host "  .\dev.ps1 build" -ForegroundColor Gray
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