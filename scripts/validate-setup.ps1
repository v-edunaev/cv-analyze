#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Validate the CV Analyzer project setup.

.DESCRIPTION
    This script validates that all components of the CV Analyzer project are properly configured
    and ready for development and deployment.
#>

# Color output functions
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "ℹ $Message" -ForegroundColor Cyan }

Write-Host "CV Analyzer Project Validation" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow
Write-Host ""

$ErrorCount = 0

# Check project structure
Write-Info "Checking project structure..."

$RequiredFiles = @(
    "analyze-cv.sln",
    "backend/CVAnalyzer.Api.csproj",
    "backend/CVAnalyzer.Tests/CVAnalyzer.Tests.csproj",
    "frontend/package.json",
    "docker-compose.yml",
    ".github/workflows/ci-cd.yml"
)

foreach ($file in $RequiredFiles) {
    if (Test-Path $file) {
        Write-Success "Found $file"
    } else {
        Write-Error "Missing $file"
        $ErrorCount++
    }
}

# Check for duplicate solution files (should not exist)
$DuplicateSolution = "backend/CVAnalyzer.sln"
if (Test-Path $DuplicateSolution) {
    Write-Warning "Found duplicate solution file: $DuplicateSolution"
    Write-Warning "This may cause 'multiple solution files' error. Consider removing it."
} else {
    Write-Success "No duplicate solution files found"
}

Write-Host ""

# Check .NET SDK
Write-Info "Checking .NET SDK..."
try {
    $dotnetVersion = dotnet --version 2>$null
    if ($dotnetVersion) {
        Write-Success ".NET SDK version: $dotnetVersion"
        
        # Check if it's .NET 8.0 or later
        $versionParts = $dotnetVersion.Split('.')
        $majorVersion = [int]$versionParts[0]
        if ($majorVersion -ge 8) {
            Write-Success ".NET version is compatible (8.0+)"
        } else {
            Write-Warning ".NET version may not be compatible. .NET 8.0+ recommended."
        }
    } else {
        Write-Error ".NET SDK not found"
        $ErrorCount++
    }
} catch {
    Write-Error ".NET SDK not found or not accessible"
    $ErrorCount++
}

Write-Host ""

# Check Node.js (for frontend)
Write-Info "Checking Node.js..."
try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Success "Node.js version: $nodeVersion"
    } else {
        Write-Warning "Node.js not found (needed for frontend development)"
    }
} catch {
    Write-Warning "Node.js not found (needed for frontend development)"
}

Write-Host ""

# Test solution build
Write-Info "Testing solution build..."
try {
    dotnet restore analyze-cv.sln --verbosity quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Solution restore successful"
        
        dotnet build analyze-cv.sln --no-restore --verbosity quiet 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Solution build successful"
        } else {
            Write-Error "Solution build failed"
            $ErrorCount++
        }
    } else {
        Write-Error "Solution restore failed"
        $ErrorCount++
    }
} catch {
    Write-Error "Failed to test solution build"
    $ErrorCount++
}

Write-Host ""

# Check environment files
Write-Info "Checking environment configuration..."

$EnvFiles = @(
    ".env.example",
    ".env.docker.example"
)

foreach ($file in $EnvFiles) {
    if (Test-Path $file) {
        Write-Success "Found $file"
    } else {
        Write-Warning "Missing $file (create from template if needed)"
    }
}

if (Test-Path ".env") {
    Write-Success "Found .env file"
} else {
    Write-Info "No .env file found (use setup-env.ps1 to create from GitHub secrets or copy from .env.example)"
}

Write-Host ""

# Check Docker
Write-Info "Checking Docker..."
try {
    $dockerVersion = docker --version 2>$null
    if ($dockerVersion) {
        Write-Success "Docker found: $dockerVersion"
        
        # Check if Docker is running
        docker info 2>$null >$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker daemon is running"
        } else {
            Write-Warning "Docker daemon is not running"
        }
    } else {
        Write-Warning "Docker not found (needed for containerized deployment)"
    }
} catch {
    Write-Warning "Docker not found (needed for containerized deployment)"
}

Write-Host ""

# Summary
Write-Host "Validation Summary" -ForegroundColor Yellow
Write-Host "=================" -ForegroundColor Yellow

if ($ErrorCount -eq 0) {
    Write-Success "All critical components are properly configured!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Info "  1. Set up environment: .\dev.ps1 setup-env"
    Write-Info "  2. Build and test: .\dev.ps1 build"
    Write-Info "  3. Run locally: dotnet run --project backend/CVAnalyzer.Api.csproj"
    Write-Info "  4. Or use Docker: docker-compose up"
} else {
    Write-Error "Found $ErrorCount critical issues that need to be resolved."
    Write-Info "Please fix the errors above before proceeding."
}

Write-Host ""
Write-Info "For detailed build instructions, see README.md"

exit $ErrorCount