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
- **`test-docker-build.ps1`** - Test Docker build process
- **`security-scan.ps1`** - Comprehensive security vulnerability scanning

### Environment Setup
- **`env-setup.ps1`** - **NEW**: Dynamic .env file creation (interactive, GitHub, or parameters)
- **`populate-env-from-secrets.ps1`** - Legacy: Setup environment from GitHub secrets
- **`setup-github-secrets.ps1`** - Helper to setup GitHub secrets
- **`create-env-template.ps1`** / **`create-env-template.sh`** - Legacy: Create environment templates

### Kubernetes Deployment
- **`deploy-k8s.ps1`** / **`deploy-k8s.sh`** - Deploy to Kubernetes
- **`setup-minikube.ps1`** - Setup Minikube for local development
- **`cleanup-k8s.ps1`** - Cleanup Kubernetes resources

## Usage Examples

```powershell
# Development workflow (using root dev.ps1)
.\dev.ps1 env-setup       # NEW: Setup environment interactively
.\dev.ps1 install         # Install all dependencies
.\dev.ps1 build           # Build everything
.\dev.ps1 test            # Run all tests
.\dev.ps1 test-frontend   # Run only frontend tests
.\dev.ps1 security-check  # Quick security check

# Environment setup options
.\scripts\env-setup.ps1 -Source interactive              # Interactive prompts (recommended)
.\scripts\env-setup.ps1 -Source github -Repository "owner/repo"  # From GitHub secrets
.\scripts\env-setup.ps1 -Source parameters -DbPassword "pass" -LlmProvider "OpenAI" -OpenAiApiKey "sk-..."

# Advanced build options
.\scripts\build.ps1 -Test -Coverage

# Security scanning
.\scripts\security-scan.ps1 -Type all        # Full security scan
.\scripts\security-scan.ps1 -Type secrets    # Secret scanning only
.\scripts\security-scan.ps1 -Type dependencies # Dependency vulnerabilities

# Validation
.\scripts\validate-setup.ps1
.\scripts\validate-docker.ps1

# Deployment
.\scripts\deploy-k8s.ps1
```

## Organization

All scripts are organized by function:
- **Build scripts** - Building, testing, validation
- **Environment scripts** - Setting up development environment
- **Deployment scripts** - Kubernetes and Docker deployment
- **Utility scripts** - Helper scripts for various tasks