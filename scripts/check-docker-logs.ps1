#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Check Docker Compose logs for potential secret leakage.

.DESCRIPTION
    This script analyzes Docker Compose logs to detect potential secret exposure.
    It checks for:
    - API keys (OpenAI, Gemini, generic)
    - Database passwords
    - Connection strings with credentials
    - JWT tokens
    - Common secret patterns

.PARAMETER ServiceName
    Specific service to check. If not provided, checks all services.

.PARAMETER Tail
    Number of log lines to check per service (default: 500).

.PARAMETER ShowMatches
    Display the actual matches found (WARNING: May expose secrets).

.EXAMPLE
    .\check-docker-logs.ps1
    
.EXAMPLE
    .\check-docker-logs.ps1 -ServiceName backend -Tail 1000

.EXAMPLE
    .\check-docker-logs.ps1 -ShowMatches

.NOTES
    Run this regularly to ensure no secrets are being logged.
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Service name to check")]
    [string]$ServiceName = "",
    
    [Parameter(HelpMessage = "Number of log lines to check")]
    [int]$Tail = 500,
    
    [Parameter(HelpMessage = "Show actual matches (WARNING: May expose secrets)")]
    [switch]$ShowMatches
)

# Color output functions
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "ℹ $Message" -ForegroundColor Cyan }
function Write-Title { param($Message) Write-Host "`n$Message" -ForegroundColor Yellow }

# Secret patterns to detect
$secretPatterns = @{
    "OpenAI API Key" = "sk-[a-zA-Z0-9]{20,}"
    "Generic API Key" = "api[_-]?key['\"":\s=]+[a-zA-Z0-9_-]{20,}"
    "Password in URL" = "://[^:]+:([^@\s]+)@"
    "Connection String Password" = "Password\s*=\s*[^;]{3,}"
    "JWT Token" = "eyJ[a-zA-Z0-9_-]{10,}\.[a-zA-Z0-9_-]{10,}"
    "Generic Secret" = "secret['\"":\s=]+[a-zA-Z0-9_-]{10,}"
    "Bearer Token" = "Bearer\s+[a-zA-Z0-9_-]{20,}"
    "Database Password Variable" = "DB_PASSWORD['\"":\s=]+[^\s]{3,}"
    "Environment Variable Leak" = "(OPENAI_API_KEY|GEMINI_API_KEY|DB_PASSWORD)\s*[:=]\s*[^\s]{3,}"
}

# Additional patterns for configuration files
$configPatterns = @{
    "Hardcoded DB Password" = 'POSTGRES_PASSWORD\s*[:=]\s*[^\s$]{3,}'
    "API Key in Config" = '(openai|gemini).*key["\']?\s*[:=]\s*["\']?[a-zA-Z0-9_-]{20,}'
}

Write-Title "Docker Logs Secret Scanner"

# Check if docker-compose is available
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Error "docker-compose not found. Please install Docker Compose."
    exit 1
}

# Get list of services
if ($ServiceName) {
    $services = @($ServiceName)
} else {
    try {
        $services = docker-compose ps --services 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "No running services found. Make sure docker-compose is running."
            Write-Info "You can still check logs with: docker-compose logs --tail $Tail"
            exit 0
        }
    } catch {
        Write-Error "Failed to get service list: $($_.Exception.Message)"
        exit 1
    }
}

$totalIssues = 0
$issuesByService = @{}

foreach ($service in $services) {
    Write-Title "Checking service: $service"
    
    # Get logs
    try {
        $logs = docker-compose logs --tail $Tail $service 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not retrieve logs for service: $service"
            continue
        }
    } catch {
        Write-Warning "Error retrieving logs for $service: $($_.Exception.Message)"
        continue
    }
    
    $serviceIssues = @()
    
    # Check each pattern
    foreach ($patternName in $secretPatterns.Keys) {
        $pattern = $secretPatterns[$patternName]
        
        # Search for pattern in logs
        $matches = [regex]::Matches($logs, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        
        if ($matches.Count -gt 0) {
            $issue = @{
                Pattern = $patternName
                Count = $matches.Count
                Matches = $matches
            }
            $serviceIssues += $issue
            $totalIssues += $matches.Count
            
            Write-Warning "Found $($matches.Count) potential $patternName leak(s)"
            
            if ($ShowMatches) {
                foreach ($match in $matches) {
                    $context = $logs.Substring([Math]::Max(0, $match.Index - 50), [Math]::Min(100, $logs.Length - [Math]::Max(0, $match.Index - 50)))
                    Write-Host "    Context: $context" -ForegroundColor DarkGray
                }
            } else {
                Write-Info "    Use -ShowMatches to see actual values (WARNING: Will expose secrets!)"
            }
        }
    }
    
    if ($serviceIssues.Count -eq 0) {
        Write-Success "No secret patterns detected in $service logs"
    } else {
        $issuesByService[$service] = $serviceIssues
    }
}

# Summary
Write-Title "Summary"

if ($totalIssues -eq 0) {
    Write-Success "No potential secret leaks detected in Docker logs!"
    Write-Info "Scanned $($services.Count) service(s) with $Tail log lines each"
} else {
    Write-Error "Found $totalIssues potential secret leak(s) across $($issuesByService.Count) service(s)"
    Write-Host ""
    
    foreach ($service in $issuesByService.Keys) {
        Write-Host "  $service:" -ForegroundColor Yellow
        foreach ($issue in $issuesByService[$service]) {
            Write-Host "    - $($issue.Pattern): $($issue.Count) occurrence(s)" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Warning "RECOMMENDATIONS:"
    Write-Host "  1. Review the application logging configuration" -ForegroundColor White
    Write-Host "  2. Ensure secrets are not being logged at any level" -ForegroundColor White
    Write-Host "  3. Use secure logging practices (mask/redact sensitive data)" -ForegroundColor White
    Write-Host "  4. Check application code for Debug/Info logs that might expose secrets" -ForegroundColor White
    Write-Host "  5. Consider using structured logging with secret filtering" -ForegroundColor White
    Write-Host ""
    
    exit 1
}

# Additional checks
Write-Title "Additional Security Checks"

# Check docker-compose.yml for hardcoded secrets
Write-Info "Checking docker-compose.yml for hardcoded secrets..."
if (Test-Path "docker-compose.yml") {
    $composeContent = Get-Content "docker-compose.yml" -Raw
    $foundHardcoded = $false
    
    foreach ($patternName in $configPatterns.Keys) {
        $pattern = $configPatterns[$patternName]
        $matches = [regex]::Matches($composeContent, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        
        # Filter out default/placeholder values
        $realMatches = $matches | Where-Object { 
            $_.Value -notmatch '\$\{' -and 
            $_.Value -notmatch 'postgres123' -and
            $_.Value -notmatch 'your.*key' -and
            $_.Value -notmatch 'example'
        }
        
        if ($realMatches.Count -gt 0) {
            Write-Warning "Potential hardcoded secret in docker-compose.yml: $patternName"
            $foundHardcoded = $true
        }
    }
    
    if (-not $foundHardcoded) {
        Write-Success "No hardcoded secrets detected in docker-compose.yml"
    }
} else {
    Write-Warning "docker-compose.yml not found"
}

# Check .env file (if it exists and is not gitignored)
Write-Info "Checking if .env is properly gitignored..."
if (Test-Path ".gitignore") {
    $gitignore = Get-Content ".gitignore" -Raw
    if ($gitignore -match "^\.env$|^\s*\.env\s*$") {
        Write-Success ".env is properly gitignored"
    } else {
        Write-Error ".env is NOT in .gitignore - Risk of committing secrets!"
    }
} else {
    Write-Warning ".gitignore not found"
}

Write-Host ""
Write-Info "Scan complete. Run this check regularly to ensure no secret leakage."
Write-Host ""
