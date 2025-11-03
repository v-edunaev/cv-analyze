# CV Analyzer - AI-Powered Resume Management System

**NOT** A production-ready full-stack application that automatically extracts and manages candidate information from CVs using AI. Built with ASP.NET Core, React, PostgreSQL, and integrated with OpenAI/Gemini APIs.

> I'm just testing something

## 📋 Table of Contents
- [Features](#-features)
- [Quick Start](#-quick-start) 
- [Local Development](#-local-development)
- [Docker Deployment](#-docker-deployment)
- [Kubernetes Deployment](#-kubernetes-deployment)
- [Testing](#-testing)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Security](#-security)
- [Architecture](#-architecture)
- [API Documentation](#-api-documentation)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)

## 🌟 Features

### Core Functionality
- **Multi-Format CV Upload**: PDF, DOCX, DOC, and TXT file support
- **AI-Powered Extraction**: Automatic parsing using OpenAI GPT-4 or Google Gemini
- **Smart Confirmation Dialog**: Review and edit AI-extracted data before saving
- **Interactive Dashboard**: Sort, filter, search, and manage candidates
- **Detailed Candidate Profiles**: Work experience, education, skills, contact info

### Technical Features
- **RESTful API**: Clean, documented ASP.NET Core 8.0 endpoints
- **Modern Frontend**: React 18 + TypeScript + Vite
- **Database**: PostgreSQL with Entity Framework Core
- **Containerized**: Docker and Kubernetes ready
- **CI/CD**: Automated testing, linting, and deployment pipelines
- **Security**: GitHub secrets integration, vulnerability scanning, input validation
- **Secrets Management**: Automated environment configuration from GitHub secrets

## 🚀 Quick Start

### Development Scripts

Use the convenient script launcher for common tasks:
```powershell
# Show all available commands
.\dev.ps1 help

# Install dependencies
.\dev.ps1 install

# Build everything
.\dev.ps1 build

# Run all tests
.\dev.ps1 test

# Run only frontend tests
.\dev.ps1 test-frontend

# Run only backend tests  
.\dev.ps1 test-backend

# Validate setup
.\dev.ps1 validate

# Run security checks
.\dev.ps1 security-check

# Clean build artifacts
.\dev.ps1 clean
```

All scripts are organized in the `scripts/` folder. See [scripts/README.md](scripts/README.md) for details.

### Prerequisites

**For Docker** (Recommended):
- Docker Desktop 4.0+ 
- Docker Compose 2.0+

**For Local Development**:
- .NET 8.0 SDK
- Node.js 18+
- PostgreSQL 12+

**For Kubernetes**:
- kubectl
- Kubernetes cluster (Minikube, Docker Desktop, AKS, EKS, GKE)

**Required**: OpenAI API Key OR Google Gemini API Key

### Fastest Setup (Docker Compose) - 2 Minutes

**Windows (PowerShell)**:
```powershell
# 1. Clone repository
git clone https://github.com/yourusername/cv-analyzer.git
cd cv-analyzer

# 2. Setup environment variables (interactive)
.\scripts\env-setup.ps1 -Source interactive
# You will be prompted to enter:
# - Database password
# - LLM Provider (OpenAI or Gemini)
# - API keys and model preferences

# 3. Start all services  
docker-compose up -d

# 4. Access application
# Frontend: http://localhost
# Backend API: http://localhost:5000
# Swagger: http://localhost:5000/swagger
```

**macOS/Linux (Bash)**:
```bash
# 1. Clone repository
git clone https://github.com/yourusername/cv-analyzer.git
cd cv-analyzer

# 2. Setup environment variables (interactive)
pwsh ./scripts/env-setup.ps1 -Source interactive
# Or manually create .env file with required variables

# 3. Start all services  
docker-compose up -d

# 4. Access application
# Frontend: http://localhost
# Backend API: http://localhost:5000
# Swagger: http://localhost:5000/swagger
```

## 💻 Local Development

### 1. Database Setup

**Windows (PowerShell)**:
```powershell
# Create PostgreSQL database
psql -U postgres
CREATE DATABASE cv_analyzer;
\q
```

**macOS (Bash)**:
```bash
# Install PostgreSQL (if not already installed)
brew install postgresql@16
brew services start postgresql@16

# Create database
psql postgres
CREATE DATABASE cv_analyzer;
\q
```

### 2. Backend Setup

**All Platforms** (Windows/macOS/Linux):
```bash
# From the root directory
dotnet restore analyze-cv.sln

# Update appsettings.json with your API key and database connection

# Run migrations
cd backend
dotnet ef migrations add InitialCreate
dotnet ef database update

# Start backend (from root directory)
cd ..
dotnet run --project backend/CVAnalyzer.Api.csproj
# API: http://localhost:5000
```

**macOS Prerequisites**:
```bash
# Install .NET 8 SDK
brew install --cask dotnet-sdk

# Verify installation
dotnet --version
```

### 3. Frontend Setup

**All Platforms** (Windows/macOS/Linux):
```bash
cd frontend

# Install dependencies
npm install

# Start dev server
npm run dev
# App: http://localhost:5173
```

**macOS Prerequisites**:
```bash
# Install Node.js 18+ (using nvm recommended)
brew install nvm
nvm install 18
nvm use 18

# Or install directly
brew install node@18
```

### 4. Generate Sample CVs

**Windows (PowerShell)**:
```powershell
# Generate test CV files (PDF, DOCX, TXT)
.\generate-sample-cvs.ps1
```

**macOS/Linux**:
```bash
# Sample CVs are pre-generated in test-data/
# To create custom samples, use LibreOffice or manually create files:
ls test-data/
# valid-cv-sample.txt, valid-cv-sample.pdf, valid-cv-sample.docx
```

## 🐳 Docker Deployment

### Using Docker Compose

**All Platforms** (Windows/macOS/Linux):
```bash
# Start all services
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Remove all data including database
docker-compose down -v
```

**macOS Prerequisites**:
```bash
# Install Docker Desktop for Mac
brew install --cask docker

# Start Docker Desktop (or open from Applications)
open -a Docker

# Verify installation
docker --version
docker-compose --version
```

### Docker Compose Services

1. **PostgreSQL** (port 5432) - Database with persistent storage
2. **Backend API** (port 5000) - ASP.NET Core with CV processing
3. **Frontend** (port 80) - React app served by Nginx

## ☸️ Kubernetes Deployment

### Quick Deploy

**Windows (PowerShell)**:
```powershell
# 1. Update secrets
notepad k8s\secrets.yaml
# Add your API keys (base64 encoded)

# 2. Deploy using script
.\deploy-k8s.ps1

# 3. Check status
kubectl get pods -n cv-analyzer
kubectl get svc -n cv-analyzer
```

**macOS/Linux (Bash)**:
```bash
# 1. Update secrets
nano k8s/secrets.yaml
# Add your API keys (base64 encoded)

# 2. Deploy manually
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress.yaml

# 3. Check status
kubectl get pods -n cv-analyzer
kubectl get svc -n cv-analyzer
```

### Local Kubernetes (Minikube)

**Windows (PowerShell)**:
```powershell
# Automated setup
.\setup-minikube.ps1

# This will:
# - Start Minikube
# - Build images
# - Deploy services
# - Open dashboard
```

**macOS (Bash)**:
```bash
# Install Minikube
brew install minikube

# Start Minikube
minikube start --driver=docker --cpus=4 --memory=8192

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server

# Build images in Minikube's Docker
eval $(minikube docker-env)
docker build -t cv-analyzer-backend:latest ./backend
docker build -t cv-analyzer-frontend:latest ./frontend

# Deploy to Minikube
kubectl apply -f k8s/

# Get service URL
minikube service frontend-service -n cv-analyzer --url
```

### Kubernetes Resources

- **Namespace**: cv-analyzer
- **Deployments**: PostgreSQL (1), Backend (2+), Frontend (2+)  
- **Services**: LoadBalancer, ClusterIP
- **PVC**: 10Gi database, 5Gi uploads
- **HPA**: Auto-scaling based on CPU/Memory
- **Ingress**: Optional NGINX with TLS

### Common K8s Commands

**All Platforms**:
```bash
# View all resources
kubectl get all -n cv-analyzer

# View logs
kubectl logs -f deployment/backend -n cv-analyzer

# Scale deployment
kubectl scale deployment backend --replicas=5 -n cv-analyzer

# Port forward
kubectl port-forward svc/frontend-service 8080:80 -n cv-analyzer

# Cleanup
kubectl delete namespace cv-analyzer
```

**macOS Kubernetes Options**:
```bash
# Option 1: Docker Desktop Kubernetes
# Enable in Docker Desktop → Preferences → Kubernetes

# Option 2: Minikube (recommended for development)
brew install kubectl minikube

# Option 3: Kind (Kubernetes in Docker)
brew install kind
kind create cluster --name cv-analyzer
```

## 🧪 Testing

### Backend Tests

**All Platforms**:
```bash
cd backend/CVAnalyzer.Tests

# Run tests
dotnet test

# With coverage
dotnet test --collect:"XPlat Code Coverage"

# View coverage report
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"coverage-report"
open coverage-report/index.html  # macOS
# or: start coverage-report/index.html  # Windows
```

### Frontend Tests  

**Comprehensive unit testing with Vitest + Testing Library**:
```bash
cd frontend

# Install dependencies
npm install

# Run tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run tests with UI
npm run test:ui

# Type check
npx tsc --noEmit

# Lint
npm run lint

# Build test
npm run build
```

**Test Coverage**:
- **Component Tests**: Upload CV, Dashboard, Candidate Management
- **Service Tests**: API client, HTTP error handling  
- **Integration Tests**: File upload workflows, data validation
- **Mock Data**: Realistic test fixtures based on actual CV formats
- **Error Scenarios**: Network failures, validation errors, edge cases

### Test Data

Sample CVs available in `test-data/`:
- `valid-cv-sample.txt` - Plain text CV
- `invalid-cv-corrupted.txt` - Corrupted file test
- `invalid-cv-empty.txt` - Empty file test  
- `invalid-cv-too-short.txt` - Insufficient content test

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

Located in `.github/workflows/ci-cd.yml`

**Jobs**:
1. **Backend Build & Test**
   - Build .NET project
   - Run unit tests
   - Code coverage analysis
   - C# linting

2. **Frontend Build & Test**
   - Node.js 18 setup with npm caching
   - Dependency installation
   - ESLint code quality checks
   - TypeScript compilation validation
   - Comprehensive unit tests with Vitest
   - Coverage reporting and upload
   - Production build verification

3. **Docker Build**
   - Multi-stage builds
   - Image caching
   - Dockerfile linting

4. **Security Scan**
   - Trivy vulnerability scanning
   - CodeQL security analysis
   - SARIF upload to GitHub

## 🔒 Security

### Security Policy

CV Analyzer follows security best practices and maintains a comprehensive security policy. See [SECURITY.md](SECURITY.md) for:

- **Vulnerability Reporting**: How to responsibly report security issues
- **Security Measures**: Application security, data protection, authentication
- **Development Security**: Secure coding practices, dependency management
- **Deployment Security**: Container security, Kubernetes security, network security

### Security Features

**Automated Security Scanning**:
- **CodeQL Analysis**: Weekly security code analysis
- **Dependency Scanning**: Automated vulnerability detection with Dependabot
- **Container Scanning**: Trivy security scanning for Docker images
- **Secret Scanning**: GitHub's automatic secret detection

**Security Tools**:
```bash
# Quick security check
.\dev.ps1 security-check

# Comprehensive security scan
.\scripts\security-scan.ps1 -Type all

# Check specific areas
.\scripts\security-scan.ps1 -Type secrets
.\scripts\security-scan.ps1 -Type dependencies
```

**Security Configuration**:
- All sensitive data stored as GitHub secrets
- Non-root container users
- Minimal attack surface with Alpine-based images
- Input validation and sanitization
- Rate limiting and CORS policies

### Vulnerability Management

- **Response Time**: Critical vulnerabilities addressed within 1-3 days
- **Automated Updates**: Dependabot creates PRs for security updates
- **Security Monitoring**: Continuous monitoring for new vulnerabilities
- **Incident Response**: Documented procedures for security incidents

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The project includes a comprehensive CI/CD pipeline (`.github/workflows/ci-cd.yml`) with:

**Security-First Approach**:
- Uses GitHub repository secrets (never hardcoded values)
- Automatic `.env` file generation from secrets during deployment
- Vulnerability scanning with Trivy
- Dockerfile linting with Hadolint

**Multi-Stage Pipeline**:
1. **Backend Build & Test**: .NET 8.0 build, unit tests, code coverage, C# linting
2. **Frontend Build & Test**: Node.js build, ESLint, TypeScript checks, testing
3. **Docker Build**: Multi-platform container builds with secret injection
4. **Security Scan**: Dependency and container vulnerability scanning
5. **Deploy Staging**: Automatic deployment to staging on `develop` branch
6. **Deploy Production**: Manual approval deployment to production on `main` branch

**Environment Management**:
- Automatic environment file creation from GitHub secrets
- Separate staging and production configurations
- No secrets exposed in logs or build artifacts

### Running Locally

Use the development scripts for common tasks:
```powershell
# Build and test everything
.\dev.ps1 build

# Just run tests
.\dev.ps1 test

# Validate project setup
.\dev.ps1 validate

# Manual commands (if needed)
dotnet restore analyze-cv.sln
dotnet build analyze-cv.sln --configuration Release
dotnet test analyze-cv.sln

# Frontend development
cd frontend
npm ci && npm run dev
```

## 🏗️ Architecture

### LLM Service Architecture

The application uses a modular LLM service architecture that supports multiple AI providers:

**Base Architecture**:
- `ILlmService` - Interface defining the contract for LLM services
- `LlmServiceBase` - Abstract base class with common functionality (prompt generation, JSON parsing)
- `LlmServiceFactory` - Factory pattern for provider selection based on configuration

**Implemented Providers**:
- `OpenAIService` - Uses the official OpenAI .NET SDK for GPT models
- `GeminiService` - Uses HTTP client for Google Gemini API integration

**Provider Selection**:
The system automatically selects the appropriate LLM provider based on the `LLM:Provider` configuration setting:
- `"openai"` → OpenAIService (uses official OpenAI SDK)
- `"gemini"` → GeminiService (uses HTTP client)
- Default → OpenAIService

**Benefits**:
- Easy to add new LLM providers
- Centralized prompt engineering in base class
- Provider-specific optimizations (official SDKs vs HTTP)
- Runtime provider switching via configuration
- Testable architecture with dependency injection

### System Diagram

```
                Client Browser
                      |
          ┌───────────▼────────────┐
          │  React Frontend        │
          │  (Vite + TypeScript)   │
          └───────────┬────────────┘
                      | REST API
          ┌───────────▼────────────┐
          │  ASP.NET Core API      │
          │  ┌──────────────────┐  │
          │  │ Controllers      │  │
          │  │ Services         │  │
          │  │ - CvProcessing   │  │
          │  │ - LlmFactory     │──┼─── LLM Provider Selection
          │  │ - OpenAIService  │──┼─── OpenAI API (Official SDK)
          │  │ - GeminiService  │──┼─── Google Gemini API (HTTP)
          │  │ - Candidate      │  │
          │  └────────┬─────────┘  │
          └───────────┼────────────┘
                      | EF Core
          ┌───────────▼────────────┐
          │  PostgreSQL Database   │
          │  Tables:               │
          │  - Candidates          │
          │  - WorkExperiences     │
          │  - Educations          │
          │  - Skills              │
          │  - CvFiles             │
          └────────────────────────┘
```

### Tech Stack

**Backend**: ASP.NET Core 8.0, EF Core, PostgreSQL, PdfPig, OpenXml, OpenAI SDK, Swagger
**Frontend**: React 18, TypeScript 5, Vite 5, React Router 6, Axios
**DevOps**: Docker, Kubernetes, GitHub Actions, Trivy, Hadolint

## 📚 API Documentation

### Swagger UI
- Local: http://localhost:5000/swagger
- Docker: http://localhost:5000/swagger

### Key Endpoints

**Upload CV**:
```http
POST /api/cvupload/upload
Content-Type: multipart/form-data
file: <CV file>
```

**Confirm Candidate**:
```http
POST /api/cvupload/confirm
{
  "fullName": "John Smith",
  "email": "john@email.com",
  ...
}
```

**Get Candidates**:
```http
GET /api/candidates?page=1&pageSize=10&search=john&sortBy=name
```

**Get Candidate by ID**:
```http
GET /api/candidates/{id}
```

**Update Candidate**:
```http
PUT /api/candidates/{id}
{
  "fullName": "John Smith",
  ...
}
```

**Delete Candidate**:
```http
DELETE /api/candidates/{id}
```

**Health Check**:
```http
GET /health
```

## ⚙️ Configuration

### Environment Variables

The application uses environment variables for configuration. **Never commit actual API keys or passwords to version control.**

All `.env` files are automatically ignored by git. The application generates `.env` files dynamically during:
- Local development (interactive prompt or GitHub CLI)
- CI/CD pipelines (from GitHub secrets)
- Deployments (from secrets managers)

### Local Development Setup

**Recommended: Interactive Setup** (Easiest):
```powershell
# Use the env-setup script for interactive prompts
.\scripts\env-setup.ps1 -Source interactive

# Or use the quick command
.\dev.ps1 env-setup
```

The script will prompt you for:
- Database password
- LLM Provider (OpenAI or Gemini)
- API keys
- Model preferences

**Alternative: From GitHub Secrets** (requires GitHub CLI):
```powershell
# Pull secrets from your GitHub repository
.\scripts\env-setup.ps1 -Source github -Repository "owner/repo"
```

**Alternative: Manual .env Creation**:

Create a `.env` file in the root directory:

```bash
# Database Configuration
DB_PASSWORD=your_secure_password

# LLM Provider (OpenAI or Gemini)
LLM_PROVIDER=OpenAI

# OpenAI Configuration
OPENAI_API_KEY=sk-your-openai-api-key
OPENAI_MODEL=gpt-4o-mini

# Gemini Configuration (if using Gemini)
GEMINI_API_KEY=your-gemini-api-key
GEMINI_MODEL=gemini-1.5-flash
```

### GitHub Secrets Setup

For CI/CD and deployment, set up GitHub repository secrets:

**Automated Setup**:
```powershell
# Interactive setup with GitHub CLI
.\scripts\setup-github-secrets.ps1 -Interactive

# Or get instructions for manual setup
.\scripts\setup-github-secrets.ps1
```

**Manual Setup**:
1. Go to your repository → Settings → Secrets and variables → Actions
2. Add these repository secrets:
   - `DB_PASSWORD` - Database password
   - `LLM_PROVIDER` - Either "OpenAI" or "Gemini"
   - `OPENAI_API_KEY` - Your OpenAI API key
   - `OPENAI_MODEL` - Model name (e.g., "gpt-4o-mini")
   - `GEMINI_API_KEY` - Your Google Gemini API key
   - `GEMINI_MODEL` - Model name (e.g., "gemini-1.5-flash")

### CI/CD Pipeline

The GitHub Actions workflow automatically creates `.env` files from secrets during:
- **Docker builds**: `.env` generated before building images
- **Staging deployment**: Environment-specific `.env` created
- **Production deployment**: Production `.env` generated from protected secrets

No `.env` files are committed to the repository. They are created dynamically on each deployment.

### Environment Variables (Docker)

For Docker Compose deployments, ensure `.env` file exists in the root directory:
```powershell
# Check if .env exists
if (-not (Test-Path .env)) {
    .\scripts\env-setup.ps1 -Source interactive
}

# Start services
docker-compose up -d
```

### Kubernetes Secrets

```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cv-analyzer-secrets
stringData:
  openai-api-key: "sk-your-key"
  gemini-api-key: "your-gemini-key"
  database-password: "secure-password"
```

### Local Configuration

```json
// backend/appsettings.json
{
  "LLM": {
    "Provider": "OpenAI",
    "OpenAI": {
      "ApiKey": "sk-your-key",
      "Model": "gpt-4o-mini"
    },
    "Gemini": {
      "ApiKey": "your-gemini-key",
      "Model": "gemini-1.5-flash"
    }
  },
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=cv_analyzer;Username=postgres;Password=pass"
  }
}
```

### Supported Models

**OpenAI** (via Official SDK): gpt-4o-mini (recommended), gpt-4o, gpt-4-turbo, gpt-3.5-turbo
**Gemini** (via HTTP API): gemini-1.5-flash (recommended), gemini-1.5-pro, gemini-1.0-pro

**Note**: OpenAI integration uses the official OpenAI .NET SDK for improved reliability and features, while Gemini uses direct HTTP API calls.

## 🐛 Troubleshooting

### Backend Won't Start

```powershell
# Check database
psql -U postgres -d cv_analyzer

# View logs
docker-compose logs backend

# Verify env vars
cat .env
```

### Frontend Can't Connect

**All Platforms**:
```bash
# Test backend
curl http://localhost:5000/health

# Check CORS in backend/Program.cs
```

**macOS Network Issues**:
```bash
# If using Docker Desktop, check host.docker.internal
# In backend appsettings.json, ensure CORS allows frontend origin

# Test with verbose curl
curl -v http://localhost:5000/health
```

### Database Migration Errors

```powershell
cd backend
dotnet ef database drop
dotnet ef database update
```

### Docker Build Fails

```powershell
docker system prune -a
docker-compose build --no-cache
```

### Kubernetes Pods Not Starting

```powershell
kubectl describe pod <pod-name> -n cv-analyzer
kubectl logs <pod-name> -n cv-analyzer
kubectl get events -n cv-analyzer
```

### LLM API Errors

- **401**: Check API key
- **429**: Rate limit - reduce requests
- **No response**: Check connectivity

## 📊 Project Structure

```
cv-analyzer/
├── analyze-cv.sln            # Main solution file
├── dev.ps1                   # Quick script launcher
├── .env.example              # Environment template
├── .env.docker.example       # Docker environment template
├── docker-compose.yml        # Docker services
├── backend/
│   ├── Controllers/          # API endpoints
│   ├── Services/             # Business logic
│   │   ├── ILlmService.cs    # LLM service interface & base class
│   │   ├── OpenAIService.cs  # OpenAI provider (official SDK)
│   │   ├── GeminiService.cs  # Gemini provider (HTTP client)
│   │   ├── LlmServiceFactory.cs # Provider selection
│   │   └── Other services...
│   ├── Models/               # Data models
│   ├── DTOs/                 # Data transfer objects
│   ├── Data/                 # EF Core context
│   ├── CVAnalyzer.Tests/     # Unit tests
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── pages/            # Page components
│   │   └── services/         # API client
│   ├── Dockerfile
│   └── nginx.conf
├── scripts/                  # All development scripts
│   ├── build.ps1             # Build and test
│   ├── validate-setup.ps1    # Project validation  
│   ├── validate-docker.ps1   # Docker validation
│   ├── deploy-k8s.ps1        # Kubernetes deployment
│   ├── setup-minikube.ps1    # Local K8s setup
│   ├── cleanup-k8s.ps1       # Resource cleanup
│   ├── populate-env-from-secrets.ps1 # GitHub secrets setup
│   └── README.md             # Scripts documentation
├── test-data/                # Sample CV files
│   ├── valid-cv-sample.*     # Valid test files
│   ├── invalid-cv-*.*        # Invalid test files  
│   └── README.md             # Test data documentation
├── k8s/                      # Kubernetes manifests
├── .github/workflows/        # CI/CD pipeline
│   └── ci-cd.yml            # Main workflow with secrets integration
└── README.md                 # This file
```

## 🚀 Deployment Checklist

### Pre-deployment
- [ ] Set up GitHub repository secrets:
  - [ ] `DB_PASSWORD` - Secure database password
  - [ ] `LLM_PROVIDER` - "OpenAI" or "Gemini"
  - [ ] `OPENAI_API_KEY` - Your OpenAI API key
  - [ ] `GEMINI_API_KEY` - Your Gemini API key (if using)
  - [ ] `OPENAI_MODEL` and `GEMINI_MODEL` - Model names
- [ ] Review resource limits in Kubernetes manifests
- [ ] Set up SSL certificates for production
- [ ] Configure backup strategy for database
- [ ] Set up monitoring and logging

### Docker
- [ ] Test: `docker-compose up`
- [ ] Verify all services healthy
- [ ] Test file upload and AI processing
- [ ] Check database persistence
- [ ] Verify environment variables loaded correctly

### Kubernetes
- [ ] Update secrets.yaml with base64 encoded values
- [ ] Build and push images to container registry
- [ ] Run deploy-k8s.ps1 or apply manifests manually
- [ ] Verify pods running: `kubectl get pods -n cv-analyzer`
- [ ] Check services: `kubectl get svc -n cv-analyzer`
- [ ] Test LoadBalancer IP access
- [ ] Configure DNS pointing to LoadBalancer
- [ ] Set up monitoring (Prometheus, Grafana)

### Security Verification
- [ ] Verify no secrets in container images
- [ ] Check vulnerability scan results in GitHub Actions
- [ ] Confirm API endpoints require authentication where needed
- [ ] Verify CORS settings for production domains
- [ ] Test rate limiting (if implemented)
- [ ] Confirm database access is restricted


## 🙏 Acknowledgments

- OpenAI & Google for AI APIs
- PdfPig & DocumentFormat.OpenXml for file parsing
- Microsoft for ASP.NET Core & EF Core
- React team for React framework
