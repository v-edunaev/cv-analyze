#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Security validation script for CV Analyzer
    
.DESCRIPTION
    Performs comprehensive security checks including:
    - Secret scanning in source code
    - Dependency vulnerability scanning
    - Docker image security analysis
    - Configuration validation
    
.PARAMETER Type
    Type of security check to perform: all, secrets, dependencies, docker, config
    
.EXAMPLE
    .\security-scan.ps1 -Type all
    .\security-scan.ps1 -Type secrets
    .\security-scan.ps1 -Type dependencies
#>

param(
    [Parameter(Position = 0)]
    [ValidateSet("all", "secrets", "dependencies", "docker", "config")]
    [string]$Type = "all"
)

$RootDir = Split-Path -Parent $PSCommandPath | Split-Path -Parent

function Write-SecurityHeader {
    param($Message)
    Write-Host ""
    Write-Host "🔒 $Message" -ForegroundColor Cyan
    Write-Host ("=" * ($Message.Length + 3)) -ForegroundColor Cyan
}

function Write-SecurityResult {
    param($Status, $Message)
    if ($Status -eq "PASS") {
        Write-Host "✅ $Message" -ForegroundColor Green
    } elseif ($Status -eq "WARN") {
        Write-Host "⚠️  $Message" -ForegroundColor Yellow
    } else {
        Write-Host "❌ $Message" -ForegroundColor Red
    }
}

function Test-Secrets {
    Write-SecurityHeader "Scanning for potential secrets in source code"
    
    $secretPatterns = @{
        "API Keys" = "api[_-]?key\s*[:=]\s*['\"]?[a-zA-Z0-9]{20,}"
        "Passwords" = "password\s*[:=]\s*['\"]?[^'\"\s]{8,}"
        "Secrets" = "secret\s*[:=]\s*['\"]?[a-zA-Z0-9]{16,}"
        "Tokens" = "token\s*[:=]\s*['\"]?[a-zA-Z0-9]{20,}"
        "Connection Strings" = "connectionstring\s*[:=]\s*['\"]?.*server.*password"
        "Private Keys" = "-----BEGIN\s+(RSA\s+)?PRIVATE\s+KEY-----"
    }
    
    $excludePatterns = @(
        "**/node_modules/**",
        "**/bin/**",
        "**/obj/**",
        "**/dist/**",
        "**/coverage/**",
        "**/.git/**",
        "**/SECURITY.md"
    )
    
    $foundSecrets = $false
    
    foreach ($type in $secretPatterns.Keys) {
        $pattern = $secretPatterns[$type]
        $results = Get-ChildItem -Path $RootDir -Recurse -Include "*.cs", "*.ts", "*.tsx", "*.js", "*.json", "*.yml", "*.yaml", "*.ps1", "*.sh" |
                   Where-Object { 
                       $path = $_.FullName.Replace($RootDir, "").Replace("\", "/")
                       -not ($excludePatterns | Where-Object { $path -like $_ })
                   } |
                   Select-String -Pattern $pattern -AllMatches
        
        if ($results) {
            Write-SecurityResult "FAIL" "Found potential $type:"
            $results | ForEach-Object { 
                $relativePath = $_.Filename.Replace($RootDir, "").TrimStart("\", "/")
                Write-Host "    📁 $relativePath:$($_.LineNumber)" -ForegroundColor Red
                Write-Host "    💡 $($_.Line.Trim())" -ForegroundColor Gray
            }
            $foundSecrets = $true
        }
    }
    
    if (-not $foundSecrets) {
        Write-SecurityResult "PASS" "No obvious secrets found in source code"
    }
    
    # Check for .env files in wrong locations
    $envFiles = Get-ChildItem -Path $RootDir -Name ".env*" -Recurse
    if ($envFiles) {
        Write-SecurityResult "WARN" "Found .env files (ensure they're in .gitignore):"
        $envFiles | ForEach-Object { Write-Host "    📄 $_" -ForegroundColor Yellow }
    }
}

function Test-Dependencies {
    Write-SecurityHeader "Checking dependencies for known vulnerabilities"
    
    # .NET dependencies
    if (Test-Path "$RootDir/backend") {
        Write-Host "Checking .NET dependencies..." -ForegroundColor Yellow
        Set-Location "$RootDir/backend"
        
        try {
            $dotnetVulns = dotnet list package --vulnerable --include-transitive 2>&1
            if ($LASTEXITCODE -eq 0 -and $dotnetVulns -notcontains "no vulnerable packages") {
                Write-SecurityResult "WARN" ".NET packages have vulnerabilities"
                Write-Host $dotnetVulns -ForegroundColor Yellow
            } else {
                Write-SecurityResult "PASS" ".NET dependencies are secure"
            }
        } catch {
            Write-SecurityResult "WARN" "Could not check .NET dependencies: $_"
        }
    }
    
    # Node.js dependencies
    if (Test-Path "$RootDir/frontend/package.json") {
        Write-Host "Checking npm dependencies..." -ForegroundColor Yellow
        Set-Location "$RootDir/frontend"
        
        try {
            $npmAudit = npm audit --json 2>&1 | ConvertFrom-Json
            $vulnerabilities = $npmAudit.metadata.vulnerabilities
            
            if ($vulnerabilities.total -gt 0) {
                Write-SecurityResult "WARN" "npm packages have $($vulnerabilities.total) vulnerabilities"
                Write-Host "    High: $($vulnerabilities.high), Moderate: $($vulnerabilities.moderate), Low: $($vulnerabilities.low)" -ForegroundColor Yellow
                Write-Host "    Run 'npm audit fix' to resolve automatically fixable issues" -ForegroundColor Cyan
            } else {
                Write-SecurityResult "PASS" "npm dependencies are secure"
            }
        } catch {
            Write-SecurityResult "WARN" "Could not check npm dependencies: $_"
        }
    }
    
    Set-Location $RootDir
}

function Test-DockerSecurity {
    Write-SecurityHeader "Checking Docker security configuration"
    
    $dockerfiles = Get-ChildItem -Path $RootDir -Name "Dockerfile" -Recurse
    
    foreach ($dockerfile in $dockerfiles) {
        $fullPath = Join-Path $RootDir $dockerfile
        $content = Get-Content $fullPath
        
        Write-Host "Analyzing $dockerfile..." -ForegroundColor Yellow
        
        # Check for root user
        if ($content -match "USER\s+root" -or -not ($content -match "USER\s+\w+")) {
            Write-SecurityResult "WARN" "$dockerfile: Running as root user"
        } else {
            Write-SecurityResult "PASS" "$dockerfile: Non-root user configured"
        }
        
        # Check for security updates
        if ($content -match "apt-get\s+update" -and $content -match "apt-get\s+upgrade") {
            Write-SecurityResult "PASS" "$dockerfile: Security updates included"
        } else {
            Write-SecurityResult "WARN" "$dockerfile: Consider adding security updates (apt-get upgrade)"
        }
        
        # Check for minimal base images
        if ($content -match "FROM.*alpine" -or $content -match "FROM.*slim") {
            Write-SecurityResult "PASS" "$dockerfile: Using minimal base image"
        } else {
            Write-SecurityResult "WARN" "$dockerfile: Consider using minimal base images (alpine/slim variants)"
        }
    }
}

function Test-Configuration {
    Write-SecurityHeader "Validating security configuration"
    
    # Check GitHub Actions permissions
    $workflowFiles = Get-ChildItem -Path "$RootDir/.github/workflows" -Name "*.yml" -ErrorAction SilentlyContinue
    foreach ($workflow in $workflowFiles) {
        $content = Get-Content "$RootDir/.github/workflows/$workflow" -Raw
        if ($content -match "permissions:\s*write-all") {
            Write-SecurityResult "WARN" "$workflow: Using 'write-all' permissions"
        } else {
            Write-SecurityResult "PASS" "$workflow: Restricted permissions configured"
        }
    }
    
    # Check for security workflows
    if (Test-Path "$RootDir/.github/workflows/codeql.yml") {
        Write-SecurityResult "PASS" "CodeQL security scanning enabled"
    } else {
        Write-SecurityResult "WARN" "CodeQL security scanning not configured"
    }
    
    # Check for dependabot
    if (Test-Path "$RootDir/.github/dependabot.yml") {
        Write-SecurityResult "PASS" "Dependabot automatic updates enabled"
    } else {
        Write-SecurityResult "WARN" "Dependabot not configured for automatic dependency updates"
    }
    
    # Check for security policy
    if (Test-Path "$RootDir/SECURITY.md") {
        Write-SecurityResult "PASS" "Security policy documented"
    } else {
        Write-SecurityResult "WARN" "No SECURITY.md policy file found"
    }
    
    # Check .gitignore for sensitive files
    if (Test-Path "$RootDir/.gitignore") {
        $gitignore = Get-Content "$RootDir/.gitignore" -Raw
        $requiredPatterns = @(".env", "*.key", "*.pem", "secrets/")
        $missing = @()
        
        foreach ($pattern in $requiredPatterns) {
            if ($gitignore -notmatch [regex]::Escape($pattern)) {
                $missing += $pattern
            }
        }
        
        if ($missing.Count -eq 0) {
            Write-SecurityResult "PASS" ".gitignore includes security patterns"
        } else {
            Write-SecurityResult "WARN" ".gitignore missing patterns: $($missing -join ', ')"
        }
    } else {
        Write-SecurityResult "WARN" "No .gitignore file found"
    }
}

# Main execution
try {
    Set-Location $RootDir
    
    Write-Host "🔒 CV Analyzer Security Scan" -ForegroundColor Cyan
    Write-Host "============================" -ForegroundColor Cyan
    Write-Host "Scan Type: $Type" -ForegroundColor Gray
    Write-Host "Directory: $RootDir" -ForegroundColor Gray
    
    switch ($Type) {
        "all" {
            Test-Secrets
            Test-Dependencies
            Test-DockerSecurity
            Test-Configuration
        }
        "secrets" { Test-Secrets }
        "dependencies" { Test-Dependencies }
        "docker" { Test-DockerSecurity }
        "config" { Test-Configuration }
    }
    
    Write-Host ""
    Write-Host "🔒 Security scan completed!" -ForegroundColor Green
    Write-Host "Review any warnings or failures above and address them before production deployment." -ForegroundColor Yellow
    
} catch {
    Write-Error "Security scan failed: $_"
    exit 1
} finally {
    Set-Location $RootDir
}