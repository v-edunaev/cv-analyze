# Development Scripts

This folder contains all the development and deployment scripts for the CV Analyzer project.

## Quick Start

Use the main launcher from the root directory:
```powershell
.\dev.ps1 help
```

## Available Scripts

### Build & Test
- **`build.ps1`** - Build and test the solution with various options
- **`validate-setup.ps1`** - Validate the complete project setup
- **`validate-docker.ps1`** - Validate Docker configuration

### Environment Setup
- **`populate-env-from-secrets.ps1`** - Setup environment from GitHub secrets
- **`setup-github-secrets.ps1`** - Helper to setup GitHub secrets
- **`create-env-template.ps1`** / **`create-env-template.sh`** - Create environment templates

### Kubernetes Deployment
- **`deploy-k8s.ps1`** / **`deploy-k8s.sh`** - Deploy to Kubernetes
- **`setup-minikube.ps1`** - Setup Minikube for local development
- **`cleanup-k8s.ps1`** - Cleanup Kubernetes resources

## Usage Examples

```powershell
# Quick build and test
.\scripts\build.ps1 -Test

# Full build with coverage
.\scripts\build.ps1 -Configuration Release -Test -Coverage

# Validate everything
.\scripts\validate-setup.ps1

# Check Docker setup
.\scripts\validate-docker.ps1

# Deploy to Kubernetes
.\scripts\deploy-k8s.ps1

# Setup local environment
.\scripts\populate-env-from-secrets.ps1
```

## Organization

All scripts are organized by function:
- **Build scripts** - Building, testing, validation
- **Environment scripts** - Setting up development environment
- **Deployment scripts** - Kubernetes and Docker deployment
- **Utility scripts** - Helper scripts for various tasks