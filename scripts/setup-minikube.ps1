# CV Analyzer - Local Development with Minikube

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CV Analyzer - Minikube Setup" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check for Minikube
try {
    minikube version | Out-Null
    Write-Host "✓ Minikube found" -ForegroundColor Green
} catch {
    Write-Host "✗ Minikube not found. Please install Minikube." -ForegroundColor Red
    Write-Host "Visit: https://minikube.sigs.k8s.io/docs/start/" -ForegroundColor Yellow
    exit 1
}

# Start Minikube
Write-Host ""
Write-Host "Starting Minikube cluster..." -ForegroundColor Yellow
minikube start --cpus=4 --memory=8192 --driver=docker

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to start Minikube" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Minikube cluster started" -ForegroundColor Green

# Enable addons
Write-Host ""
Write-Host "Enabling Minikube addons..." -ForegroundColor Yellow
minikube addons enable ingress
minikube addons enable metrics-server
Write-Host "✓ Addons enabled" -ForegroundColor Green

# Configure Docker to use Minikube's Docker daemon
Write-Host ""
Write-Host "Configuring Docker environment..." -ForegroundColor Yellow
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
Write-Host "✓ Docker environment configured" -ForegroundColor Green

# Build images in Minikube
Write-Host ""
Write-Host "Building Docker images in Minikube..." -ForegroundColor Yellow

Write-Host "Building backend..."
docker build -t cv-analyzer-backend:latest ./backend
Write-Host "✓ Backend built" -ForegroundColor Green

Write-Host "Building frontend..."
docker build -t cv-analyzer-frontend:latest ./frontend
Write-Host "✓ Frontend built" -ForegroundColor Green

# Deploy application
Write-Host ""
Write-Host "Deploying application to Minikube..." -ForegroundColor Yellow

# Update secrets
Write-Host "⚠ Make sure to update k8s/secrets.yaml with your API keys!" -ForegroundColor Yellow
$response = Read-Host "Continue with deployment? (y/n)"
if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "✓ Deployment cancelled" -ForegroundColor Green
    exit 0
}

# Apply manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml

Write-Host "Waiting for database..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=postgres -n cv-analyzer --timeout=120s

kubectl apply -f k8s/backend-deployment.yaml
Write-Host "Waiting for backend..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=backend -n cv-analyzer --timeout=120s

kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/hpa.yaml

Write-Host "✓ Application deployed" -ForegroundColor Green

# Get access URL
Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Minikube Setup Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Getting service URL..." -ForegroundColor Yellow
$url = minikube service frontend-service -n cv-analyzer --url

Write-Host "✓ Application is available at: $url" -ForegroundColor Green

Write-Host ""
Write-Host "Useful Minikube commands:" -ForegroundColor Yellow
Write-Host "  minikube dashboard" -ForegroundColor White
Write-Host "  minikube service frontend-service -n cv-analyzer" -ForegroundColor White
Write-Host "  minikube stop" -ForegroundColor White
Write-Host "  minikube delete" -ForegroundColor White
Write-Host ""

# Optionally open dashboard
$openDashboard = Read-Host "Open Minikube dashboard? (y/n)"
if ($openDashboard -eq "y" -or $openDashboard -eq "Y") {
    minikube dashboard
}
