#!/bin/bash

# CV Analyzer - Kubernetes Deployment Script

set -e

echo "=================================="
echo "CV Analyzer - Kubernetes Deploy"
echo "=================================="
echo ""

# Configuration
NAMESPACE="cv-analyzer"
DOCKER_REGISTRY=${DOCKER_REGISTRY:-"localhost:5000"}
VERSION=${VERSION:-"latest"}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v kubectl &> /dev/null; then
    print_error "kubectl not found. Please install kubectl."
    exit 1
fi
print_status "kubectl found"

if ! command -v docker &> /dev/null; then
    print_error "docker not found. Please install Docker."
    exit 1
fi
print_status "docker found"

# Build Docker images
echo ""
echo "Building Docker images..."

echo "Building backend image..."
docker build -t ${DOCKER_REGISTRY}/cv-analyzer-backend:${VERSION} ./backend
print_status "Backend image built"

echo "Building frontend image..."
docker build -t ${DOCKER_REGISTRY}/cv-analyzer-frontend:${VERSION} ./frontend
print_status "Frontend image built"

# Push images to registry (optional, for remote clusters)
if [ "$PUSH_IMAGES" = "true" ]; then
    echo ""
    echo "Pushing images to registry..."
    docker push ${DOCKER_REGISTRY}/cv-analyzer-backend:${VERSION}
    docker push ${DOCKER_REGISTRY}/cv-analyzer-frontend:${VERSION}
    print_status "Images pushed to registry"
fi

# Update secrets with your API keys
echo ""
print_warning "Please update k8s/secrets.yaml with your actual API keys before deploying!"
read -p "Have you updated the secrets? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Please update secrets.yaml and run again"
    exit 1
fi

# Apply Kubernetes manifests
echo ""
echo "Deploying to Kubernetes..."

# Create namespace
kubectl apply -f k8s/namespace.yaml
print_status "Namespace created"

# Apply configurations and secrets
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml
print_status "ConfigMap and Secrets applied"

# Create persistent volumes
kubectl apply -f k8s/pvc.yaml
print_status "Persistent Volume Claims created"

# Deploy database
kubectl apply -f k8s/postgres-deployment.yaml
print_status "PostgreSQL deployed"

# Wait for database to be ready
echo "Waiting for database to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n ${NAMESPACE} --timeout=120s
print_status "Database is ready"

# Deploy backend
kubectl apply -f k8s/backend-deployment.yaml
print_status "Backend deployed"

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n ${NAMESPACE} --timeout=120s
print_status "Backend is ready"

# Deploy frontend
kubectl apply -f k8s/frontend-deployment.yaml
print_status "Frontend deployed"

# Apply HPA
kubectl apply -f k8s/hpa.yaml
print_status "Horizontal Pod Autoscalers created"

# Apply ingress (optional)
if [ -f "k8s/ingress.yaml" ]; then
    kubectl apply -f k8s/ingress.yaml
    print_status "Ingress created"
fi

# Get service information
echo ""
echo "=================================="
echo "Deployment Complete!"
echo "=================================="
echo ""

# Get frontend service
FRONTEND_SERVICE=$(kubectl get svc frontend-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")

if [ "$FRONTEND_SERVICE" = "pending" ]; then
    print_warning "LoadBalancer IP is pending. Waiting for external IP..."
    echo "Run: kubectl get svc frontend-service -n ${NAMESPACE} -w"
else
    print_status "Application is available at: http://${FRONTEND_SERVICE}"
fi

echo ""
echo "Useful commands:"
echo "  kubectl get pods -n ${NAMESPACE}"
echo "  kubectl get svc -n ${NAMESPACE}"
echo "  kubectl logs -f deployment/backend -n ${NAMESPACE}"
echo "  kubectl logs -f deployment/frontend -n ${NAMESPACE}"
echo ""
