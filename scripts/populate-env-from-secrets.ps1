#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Populate .env file from GitHub secrets for local development.

.DESCRIPTION
    This script retrieves secrets from a GitHub repository and creates a local .env file.
    It uses the GitHub CLI to fetch secrets and requires authentication.

.PARAMETER Repository
    The GitHub repository in the format "owner/repo". Defaults to current repository.

.PARAMETER Environment
    The environment name (e.g., 'staging', 'production'). Optional.

.PARAMETER OutputFile
    The output file path. Defaults to ".env".

.PARAMETER Force
    Overwrite existing .env file without prompting.

.EXAMPLE
    .\populate-env-from-secrets.ps1
    
.EXAMPLE
    .\populate-env-from-secrets.ps1 -Repository "username/cv-analyzer" -OutputFile ".env.local"

.EXAMPLE
    .\populate-env-from-secrets.ps1 -Environment "production" -Force

.NOTES
    Requires GitHub CLI (gh) to be installed and authenticated.
    Install GitHub CLI: https://cli.github.com/
    Authenticate: gh auth login
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "GitHub repository (owner/repo)")]
    [string]$Repository = "",
    
    [Parameter(HelpMessage = "Environment name (optional)")]
    [string]$Environment = "",
    
    [Parameter(HelpMessage = "Output file path")]
    [string]$OutputFile = ".env",
    
    [Parameter(HelpMessage = "Force overwrite existing file")]
    [switch]$Force
)

# Color output functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

# Check if GitHub CLI is installed
function Test-GitHubCli {
    try {
        $null = Get-Command gh -ErrorAction Stop
        return $true
    }
    catch {
        Write-Error "GitHub CLI (gh) is not installed or not in PATH."
        Write-Info "Please install GitHub CLI: https://cli.github.com/"
        Write-Info "After installation, authenticate with: gh auth login"
        return $false
    }
}

# Check if user is authenticated with GitHub CLI
function Test-GitHubAuth {
    try {
        $authStatus = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        else {
            Write-Error "Not authenticated with GitHub CLI."
            Write-Info "Please authenticate with: gh auth login"
            return $false
        }
    }
    catch {
        Write-Error "Failed to check GitHub CLI authentication status."
        return $false
    }
}

# Get current repository if not specified
function Get-CurrentRepository {
    if (-not $Repository) {
        try {
            $remoteUrl = git remote get-url origin 2>$null
            if ($remoteUrl -match "github\.com[:/]([^/]+/[^/]+?)(\.git)?$") {
                return $matches[1]
            }
        }
        catch {
            # Ignore errors
        }
        
        Write-Error "Could not determine repository. Please specify with -Repository parameter."
        Write-Info "Example: -Repository 'username/cv-analyzer'"
        return $null
    }
    return $Repository
}

# Fetch secrets from GitHub
function Get-GitHubSecrets {
    param($Repo, $Env)
    
    Write-Info "Fetching secrets from repository: $Repo"
    
    try {
        if ($Env) {
            $secretsJson = gh secret list --repo $Repo --env $Env --json name,visibility 2>&1
        }
        else {
            $secretsJson = gh secret list --repo $Repo --json name,visibility 2>&1
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to fetch secrets: $secretsJson"
            return $null
        }
        
        $secrets = $secretsJson | ConvertFrom-Json
        return $secrets
    }
    catch {
        Write-Error "Error fetching secrets: $($_.Exception.Message)"
        return $null
    }
}

# Get secret value (this is a simulation since actual secret values can't be retrieved via CLI)
function Get-SecretPlaceholder {
    param($SecretName)
    
    # Note: GitHub CLI doesn't allow retrieving secret values for security reasons
    # This creates placeholder values that need to be manually filled
    switch ($SecretName) {
        "DB_PASSWORD" { return "your-database-password-here" }
        "LLM_PROVIDER" { return "OpenAI" }
        "OPENAI_API_KEY" { return "sk-your-openai-api-key-here" }
        "OPENAI_MODEL" { return "gpt-4o-mini" }
        "GEMINI_API_KEY" { return "your-gemini-api-key-here" }
        "GEMINI_MODEL" { return "gemini-1.5-flash" }
        default { return "your-$($SecretName.ToLower())-value-here" }
    }
}

# Create .env file
function New-EnvFile {
    param($Secrets, $FilePath)
    
    $envContent = @()
    $envContent += "# Environment file generated from GitHub secrets"
    $envContent += "# Generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $envContent += ""
    $envContent += "# Database Configuration"
    $envContent += ""
    $envContent += "# LLM Provider Configuration"
    $envContent += ""
    $envContent += "# OpenAI Configuration"
    $envContent += ""
    $envContent += "# Gemini Configuration"
    $envContent += ""
    
    $secretsFound = @()
    $expectedSecrets = @("DB_PASSWORD", "LLM_PROVIDER", "OPENAI_API_KEY", "OPENAI_MODEL", "GEMINI_API_KEY", "GEMINI_MODEL")
    
    foreach ($expectedSecret in $expectedSecrets) {
        $secret = $Secrets | Where-Object { $_.name -eq $expectedSecret }
        if ($secret) {
            $placeholder = Get-SecretPlaceholder $expectedSecret
            $envContent += "$($expectedSecret)=$placeholder"
            $secretsFound += $expectedSecret
        }
        else {
            Write-Warning "Secret '$expectedSecret' not found in repository"
            $placeholder = Get-SecretPlaceholder $expectedSecret
            $envContent += "# $($expectedSecret)=$placeholder  # Not found in GitHub secrets"
        }
    }
    
    # Add any additional secrets found
    foreach ($secret in $Secrets) {
        if ($secret.name -notin $expectedSecrets) {
            $placeholder = Get-SecretPlaceholder $secret.name
            $envContent += "$($secret.name)=$placeholder"
            $secretsFound += $secret.name
        }
    }
    
    try {
        $envContent | Out-File -FilePath $FilePath -Encoding UTF8
        Write-Success "Environment file created: $FilePath"
        Write-Info "Secrets found: $($secretsFound -join ', ')"
        Write-Warning "Note: Placeholder values have been used. Please update with actual values."
        return $true
    }
    catch {
        Write-Error "Failed to create environment file: $($_.Exception.Message)"
        return $false
    }
}

# Main execution
function Main {
    Write-Info "CV Analyzer - Environment File Generator"
    Write-Info "========================================"
    
    # Check prerequisites
    if (-not (Test-GitHubCli)) { exit 1 }
    if (-not (Test-GitHubAuth)) { exit 1 }
    
    # Get repository
    $repo = Get-CurrentRepository
    if (-not $repo) { exit 1 }
    
    # Check if output file exists
    if ((Test-Path $OutputFile) -and -not $Force) {
        $response = Read-Host "File '$OutputFile' already exists. Overwrite? (y/N)"
        if ($response -notmatch "^[Yy]") {
            Write-Info "Operation cancelled."
            exit 0
        }
    }
    
    # Fetch secrets
    $secrets = Get-GitHubSecrets -Repo $repo -Env $Environment
    if (-not $secrets) { exit 1 }
    
    if ($secrets.Count -eq 0) {
        Write-Warning "No secrets found in repository '$repo'"
        if ($Environment) {
            Write-Info "Environment: $Environment"
        }
        exit 1
    }
    
    # Create .env file
    if (New-EnvFile -Secrets $secrets -FilePath $OutputFile) {
        Write-Info ""
        Write-Info "Next steps:"
        Write-Info "1. Edit '$OutputFile' and replace placeholder values with actual secrets"
        Write-Info "2. Ensure '$OutputFile' is in your .gitignore file"
        Write-Info "3. Test your application with the new environment file"
        exit 0
    }
    else {
        exit 1
    }
}

# Run main function
Main