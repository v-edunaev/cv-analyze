# Setup Script for CV Analyzer Application

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "CV Analyzer - Setup Script" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check .NET
$dotnetVersion = dotnet --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ .NET SDK found: $dotnetVersion" -ForegroundColor Green
} else {
    Write-Host "✗ .NET SDK not found. Please install .NET 8.0 SDK" -ForegroundColor Red
    Write-Host "  Download from: https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Yellow
    exit 1
}

# Check Node.js
$nodeVersion = node --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Node.js found: $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "✗ Node.js not found. Please install Node.js 18+" -ForegroundColor Red
    Write-Host "  Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check PostgreSQL
$pgVersion = psql --version 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PostgreSQL found: $pgVersion" -ForegroundColor Green
} else {
    Write-Host "⚠ PostgreSQL not found in PATH" -ForegroundColor Yellow
    Write-Host "  Make sure PostgreSQL is installed and running" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Setting up Backend..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Backend setup
Set-Location -Path "$PSScriptRoot\backend"

Write-Host "Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Failed to restore packages" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Packages restored" -ForegroundColor Green

Write-Host "Building backend..." -ForegroundColor Yellow
dotnet build
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Build failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Backend built successfully" -ForegroundColor Green

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Setting up Frontend..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# Frontend setup
Set-Location -Path "$PSScriptRoot\frontend"

Write-Host "Installing npm packages..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ npm install failed" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Packages installed" -ForegroundColor Green

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Create PostgreSQL database: CREATE DATABASE cv_analyzer;" -ForegroundColor White
Write-Host "2. Update backend\appsettings.json with:" -ForegroundColor White
Write-Host "   - Database connection string" -ForegroundColor White
Write-Host "   - OpenAI or Gemini API key" -ForegroundColor White
Write-Host "3. Run migrations:" -ForegroundColor White
Write-Host "   cd backend" -ForegroundColor Cyan
Write-Host "   dotnet ef migrations add InitialCreate" -ForegroundColor Cyan
Write-Host "   dotnet ef database update" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start the application:" -ForegroundColor Yellow
Write-Host "Backend:  cd backend && dotnet run" -ForegroundColor Cyan
Write-Host "Frontend: cd frontend && npm run dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "See README.md for detailed documentation" -ForegroundColor White
