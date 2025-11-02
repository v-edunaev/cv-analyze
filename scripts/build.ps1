#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build and test the CV Analyzer solution.

.DESCRIPTION
    This script builds and tests the CV Analyzer solution from the root directory,
    avoiding the multiple solution file issue.

.PARAMETER Configuration
    Build configuration (Debug or Release). Defaults to Debug.

.PARAMETER Test
    Run tests after building.

.PARAMETER Coverage
    Collect code coverage when running tests.

.PARAMETER Format
    Check code formatting.

.EXAMPLE
    .\build.ps1
    
.EXAMPLE
    .\build.ps1 -Configuration Release -Test -Coverage

.EXAMPLE
    .\build.ps1 -Format
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Build configuration")]
    [ValidateSet("Debug", "Release")]
    [string]$Configuration = "Debug",
    
    [Parameter(HelpMessage = "Run tests")]
    [switch]$Test,
    
    [Parameter(HelpMessage = "Collect code coverage")]
    [switch]$Coverage,
    
    [Parameter(HelpMessage = "Check code formatting")]
    [switch]$Format
)

# Color output functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

# Get script directory and find the root directory (parent of scripts)
$ScriptRoot = Split-Path $PSScriptRoot -Parent
$SolutionFile = Join-Path $ScriptRoot "analyze-cv.sln"

# Check if solution file exists
if (-not (Test-Path $SolutionFile)) {
    Write-Error "Solution file not found: $SolutionFile"
    Write-Info "Please run this script from the root directory of the CV Analyzer project."
    exit 1
}

Write-Info "CV Analyzer Build Script"
Write-Info "========================"
Write-Info "Configuration: $Configuration"
Write-Info "Solution: $SolutionFile"
Write-Info ""

try {
    # Restore dependencies
    Write-Info "Restoring dependencies..."
    dotnet restore $SolutionFile
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to restore dependencies"
        exit 1
    }
    Write-Success "✓ Dependencies restored"

    # Build solution
    Write-Info "Building solution..."
    dotnet build $SolutionFile --no-restore --configuration $Configuration
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to build solution"
        exit 1
    }
    Write-Success "✓ Solution built successfully"

    # Run tests if requested
    if ($Test) {
        Write-Info "Running tests..."
        
        $testArgs = @(
            "test", $SolutionFile,
            "--no-build",
            "--configuration", $Configuration,
            "--verbosity", "normal"
        )
        
        if ($Coverage) {
            $testArgs += @(
                "--collect:`"XPlat Code Coverage`"",
                "--results-directory", (Join-Path $ScriptRoot "backend/coverage")
            )
        }
        
        & dotnet @testArgs
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Tests failed"
            exit 1
        }
        Write-Success "✓ All tests passed"
        
        if ($Coverage) {
            Write-Info "Code coverage reports generated in $(Join-Path $ScriptRoot 'backend/coverage')/"
        }
    }

    # Check formatting if requested
    if ($Format) {
        Write-Info "Checking code formatting..."
        dotnet format $SolutionFile --verify-no-changes --verbosity diagnostic
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Code formatting issues found. Run 'dotnet format $SolutionFile' to fix them."
        }
        else {
            Write-Success "✓ Code formatting is correct"
        }
    }

    Write-Info ""
    Write-Success "Build completed successfully!"
    
    if (-not $Test -and -not $Format) {
        Write-Info "Next steps:"
        Write-Info "  - Run tests: .\dev.ps1 test"
        Write-Info "  - Check formatting: .\scripts\build.ps1 -Format"
        Write-Info "  - Full build with tests: .\dev.ps1 build"
    }
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}