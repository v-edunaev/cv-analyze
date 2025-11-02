# CV Analyzer - Kubernetes Cleanup Script

$ErrorActionPreference = "Stop"

Write-Host "==================================" -ForegroundColor Red
Write-Host "CV Analyzer - Kubernetes Cleanup" -ForegroundColor Red
Write-Host "==================================" -ForegroundColor Red
Write-Host ""

$NAMESPACE = "cv-analyzer"

# Confirm deletion
Write-Host "⚠ WARNING: This will delete all resources in the $NAMESPACE namespace!" -ForegroundColor Yellow
Write-Host "This includes:" -ForegroundColor Yellow
Write-Host "  - All deployments and pods" -ForegroundColor Yellow
Write-Host "  - All services" -ForegroundColor Yellow
Write-Host "  - All persistent volume claims (DATABASE DATA WILL BE LOST!)" -ForegroundColor Red
Write-Host "  - All configmaps and secrets" -ForegroundColor Yellow
Write-Host ""

$response = Read-Host "Are you sure you want to continue? (yes/no)"
if ($response -ne "yes") {
    Write-Host "✓ Cleanup cancelled" -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Starting cleanup..." -ForegroundColor Yellow

try {
    # Delete HPA
    if (kubectl get hpa -n $NAMESPACE 2>$null) {
        kubectl delete -f k8s/hpa.yaml 2>$null
        Write-Host "✓ HPA deleted" -ForegroundColor Green
    }

    # Delete Ingress
    if (Test-Path "k8s/ingress.yaml") {
        kubectl delete -f k8s/ingress.yaml 2>$null
        Write-Host "✓ Ingress deleted" -ForegroundColor Green
    }

    # Delete deployments
    kubectl delete -f k8s/frontend-deployment.yaml 2>$null
    Write-Host "✓ Frontend deployment deleted" -ForegroundColor Green

    kubectl delete -f k8s/backend-deployment.yaml 2>$null
    Write-Host "✓ Backend deployment deleted" -ForegroundColor Green

    kubectl delete -f k8s/postgres-deployment.yaml 2>$null
    Write-Host "✓ PostgreSQL deployment deleted" -ForegroundColor Green

    # Wait for pods to terminate
    Write-Host "Waiting for pods to terminate..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5

    # Delete PVCs (this will delete data!)
    Write-Host ""
    Write-Host "⚠ Deleting persistent volume claims (DATA WILL BE LOST)..." -ForegroundColor Red
    $confirmPvc = Read-Host "Continue? (yes/no)"
    if ($confirmPvc -eq "yes") {
        kubectl delete -f k8s/pvc.yaml 2>$null
        Write-Host "✓ PVCs deleted" -ForegroundColor Green
    } else {
        Write-Host "⚠ PVCs preserved (delete manually if needed)" -ForegroundColor Yellow
    }

    # Delete configmaps and secrets
    kubectl delete -f k8s/configmap.yaml 2>$null
    kubectl delete -f k8s/secrets.yaml 2>$null
    Write-Host "✓ ConfigMaps and Secrets deleted" -ForegroundColor Green

    # Delete namespace
    Write-Host ""
    $deleteNamespace = Read-Host "Delete namespace '$NAMESPACE'? (yes/no)"
    if ($deleteNamespace -eq "yes") {
        kubectl delete -f k8s/namespace.yaml
        Write-Host "✓ Namespace deleted" -ForegroundColor Green
    } else {
        Write-Host "⚠ Namespace preserved" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "Cleanup Complete!" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green

} catch {
    Write-Host ""
    Write-Host "✗ Error during cleanup: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "You can manually clean up with:" -ForegroundColor Yellow
    Write-Host "  kubectl delete namespace $NAMESPACE" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "To verify cleanup:" -ForegroundColor Yellow
Write-Host "  kubectl get all -n $NAMESPACE" -ForegroundColor White
Write-Host ""
