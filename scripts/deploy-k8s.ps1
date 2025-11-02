# CV Analyzer - Kubernetes Deployment Script (PowerShell)

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CV Analyzer - Kubernetes Deploy" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$NAMESPACE = "cv-analyzer"
$DOCKER_REGISTRY = if ($env:DOCKER_REGISTRY) { $env:DOCKER_REGISTRY } else { "localhost:5000" }
$VERSION = if ($env:VERSION) { $env:VERSION } else { "latest" }

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

try {
    kubectl version --client --short | Out-Null
    Write-Host "✓ kubectl found" -ForegroundColor Green
} catch {
    Write-Host "✗ kubectl not found. Please install kubectl." -ForegroundColor Red
    exit 1
}

try {
    docker --version | Out-Null
    Write-Host "✓ docker found" -ForegroundColor Green
} catch {
    Write-Host "✗ docker not found. Please install Docker." -ForegroundColor Red
    exit 1
}

# Build Docker images
Write-Host ""
Write-Host "Building Docker images..." -ForegroundColor Yellow

# Check if .env file exists, if not create it
if (-not (Test-Path ".env")) {
    Write-Host "⚠ .env file not found. Creating from secrets..." -ForegroundColor Yellow
    & "$PSScriptRoot\env-setup.ps1" -Source interactive -Force
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✗ Failed to create .env file" -ForegroundColor Red
        exit 1
    }
}

Write-Host "Building backend image..."
docker build -t "${DOCKER_REGISTRY}/cv-analyzer-backend:${VERSION}" ./backend
Write-Host "✓ Backend image built" -ForegroundColor Green

Write-Host "Building frontend image..."
docker build -t "${DOCKER_REGISTRY}/cv-analyzer-frontend:${VERSION}" ./frontend
Write-Host "✓ Frontend image built" -ForegroundColor Green

# Push images (optional)
if ($env:PUSH_IMAGES -eq "true") {
    Write-Host ""
    Write-Host "Pushing images to registry..." -ForegroundColor Yellow
    docker push "${DOCKER_REGISTRY}/cv-analyzer-backend:${VERSION}"
    docker push "${DOCKER_REGISTRY}/cv-analyzer-frontend:${VERSION}"
    Write-Host "✓ Images pushed to registry" -ForegroundColor Green
}

# Confirm secrets update
Write-Host ""
Write-Host "⚠ Please update k8s/secrets.yaml with your actual API keys!" -ForegroundColor Yellow
$response = Read-Host "Have you updated the secrets? (y/n)"
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "✗ Please update secrets.yaml and run again" -ForegroundColor Red
    exit 1
}

# Apply Kubernetes manifests
Write-Host ""
Write-Host "Deploying to Kubernetes..." -ForegroundColor Yellow

# Create namespace
kubectl apply -f k8s/namespace.yaml
Write-Host "✓ Namespace created" -ForegroundColor Green

# Apply configurations
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
Write-Host "✓ ConfigMap and Secrets applied" -ForegroundColor Green

# Create PVCs
kubectl apply -f k8s/pvc.yaml
Write-Host "✓ Persistent Volume Claims created" -ForegroundColor Green

# Deploy database
kubectl apply -f k8s/postgres-deployment.yaml
Write-Host "✓ PostgreSQL deployed" -ForegroundColor Green

# Wait for database
Write-Host "Waiting for database to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=120s
Write-Host "✓ Database is ready" -ForegroundColor Green

# Deploy backend
kubectl apply -f k8s/backend-deployment.yaml
Write-Host "✓ Backend deployed" -ForegroundColor Green

# Wait for backend
Write-Host "Waiting for backend to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=backend -n $NAMESPACE --timeout=120s
Write-Host "✓ Backend is ready" -ForegroundColor Green

# Deploy frontend
kubectl apply -f k8s/frontend-deployment.yaml
Write-Host "✓ Frontend deployed" -ForegroundColor Green

# Apply HPA
kubectl apply -f k8s/hpa.yaml
Write-Host "✓ Horizontal Pod Autoscalers created" -ForegroundColor Green

# Apply ingress (optional)
if (Test-Path "k8s/ingress.yaml") {
    kubectl apply -f k8s/ingress.yaml
    Write-Host "✓ Ingress created" -ForegroundColor Green
}

# Get service info
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$frontendIP = kubectl get svc frontend-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>$null

if ([string]::IsNullOrEmpty($frontendIP)) {
    Write-Host "⚠ LoadBalancer IP is pending. Waiting for external IP..." -ForegroundColor Yellow
    Write-Host "Run: kubectl get svc frontend-service -n $NAMESPACE -w" -ForegroundColor White
} else {
    Write-Host "✓ Application is available at: http://$frontendIP" -ForegroundColor Green
}

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  kubectl get pods -n $NAMESPACE" -ForegroundColor White
Write-Host "  kubectl get svc -n $NAMESPACE" -ForegroundColor White
Write-Host "  kubectl logs -f deployment/backend -n $NAMESPACE" -ForegroundColor White
Write-Host "  kubectl logs -f deployment/frontend -n $NAMESPACE" -ForegroundColor White
Write-Host ""
