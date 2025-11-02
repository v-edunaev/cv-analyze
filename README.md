# CV Analyzer - AI-Powered Resume Management System

A production-ready full-stack application that automatically extracts and manages candidate information from CVs using AI. Built with ASP.NET Core, React, PostgreSQL, and integrated with OpenAI/Gemini APIs.

## 📋 Table of Contents
- [Features](#-features)
- [Quick Start](#-quick-start) 
- [Local Development](#-local-development)
- [Docker Deployment](#-docker-deployment)
- [Kubernetes Deployment](#-kubernetes-deployment)
- [Testing](#-testing)
- [CI/CD Pipeline](#-cicd-pipeline)
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
- **Security**: API key management, CORS, input validation

## 🚀 Quick Start

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

# 2. Configure environment
Copy-Item .env.docker .env
# Edit .env and add your OpenAI or Gemini API key

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

# 2. Configure environment
cp .env.docker .env
# Edit .env and add your OpenAI or Gemini API key

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
cd backend

# Restore packages
dotnet restore

# Update appsettings.json with your API key and database connection

# Run migrations
dotnet ef migrations add InitialCreate
dotnet ef database update

# Start backend
dotnet run
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

```powershell
cd frontend

# Type check
npm run type-check

# Lint
npm run lint

# Build test
npm run build
```

### Test Data

Sample CVs available in `test-data/`:
- `valid-cv-sample.txt` - Plain text CV
- `valid-cv-sample.pdf` - PDF CV (generated)
- `valid-cv-sample.docx` - Word CV (generated)
- `invalid-cv-*.txt` - Test edge cases

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
   - Build React app
   - ESLint
   - TypeScript check
   - Production build

3. **Docker Build**
   - Multi-stage builds
   - Image caching
   - Dockerfile linting

4. **Security Scan**
   - Trivy vulnerability scanning
   - SARIF upload to GitHub

### Running Locally

```powershell
# Backend
cd backend
dotnet restore
dotnet build --configuration Release
dotnet test
dotnet format --verify-no-changes

# Frontend
cd frontend
npm ci
npm run lint
npm run type-check
npm run build
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

### Environment Variables (Docker)

```bash
# .env file
DB_PASSWORD=your_secure_password
LLM_PROVIDER=OpenAI  # or Gemini
OPENAI_API_KEY=sk-your-key
OPENAI_MODEL=gpt-4o-mini
GEMINI_API_KEY=your-key
GEMINI_MODEL=gemini-1.5-flash
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
│   └── Dockerfile
├── backend/CVAnalyzer.Tests/
│   └── Services/             # Unit tests (including LLM tests)
├── frontend/
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── pages/            # Page components
│   │   └── services/         # API client
│   ├── Dockerfile
│   └── nginx.conf
├── k8s/                      # Kubernetes manifests
├── .github/workflows/        # CI/CD
├── test-data/                # Sample CVs
├── docker-compose.yml
└── README.md
```

## 🚀 Deployment Checklist

### Pre-deployment
- [ ] Configure API keys
- [ ] Set database password
- [ ] Review resource limits
- [ ] Set up SSL certificates
- [ ] Configure backup strategy

### Docker
- [ ] Test: `docker-compose up`
- [ ] Verify all services healthy
- [ ] Test file upload and AI
- [ ] Check database persistence

### Kubernetes
- [ ] Update secrets.yaml
- [ ] Build and push images
- [ ] Run deploy-k8s.ps1
- [ ] Verify pods running
- [ ] Check LoadBalancer IP
- [ ] Configure DNS
- [ ] Set up monitoring


## 🙏 Acknowledgments

- OpenAI & Google for AI APIs
- PdfPig & DocumentFormat.OpenXml for file parsing
- Microsoft for ASP.NET Core & EF Core
- React team for React framework

---

**Built with ❤️ using ASP.NET Core, React, TypeScript, and AI**
