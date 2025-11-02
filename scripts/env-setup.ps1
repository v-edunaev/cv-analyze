#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Dynamic .env file creation from GitHub secrets or interactive prompts.

.DESCRIPTION
    This script creates .env file for local development by either:
    1. Fetching secrets from GitHub repository (requires gh CLI and authentication)
    2. Prompting user interactively for values
    3. Using provided parameters

.PARAMETER Source
    Source for environment variables: 'github', 'interactive', or 'parameters'.

.PARAMETER OutputFile
    The output file path. Defaults to ".env".

.PARAMETER Force
    Overwrite existing .env file without prompting.

.PARAMETER Repository
    GitHub repository in format "owner/repo" (only for github source).

.PARAMETER DbPassword
    Database password (only for parameters source).

.PARAMETER LlmProvider
    LLM Provider: OpenAI or Gemini (only for parameters source).

.PARAMETER OpenAiApiKey
    OpenAI API key (only for parameters source).

.PARAMETER OpenAiModel
    OpenAI model name (only for parameters source).

.PARAMETER GeminiApiKey
    Gemini API key (only for parameters source).

.PARAMETER GeminiModel
    Gemini model name (only for parameters source).

.EXAMPLE
    .\env-setup.ps1 -Source interactive
    
.EXAMPLE
    .\env-setup.ps1 -Source github -Repository "owner/repo"

.EXAMPLE
    .\env-setup.ps1 -Source parameters -DbPassword "pass123" -LlmProvider "OpenAI" -OpenAiApiKey "sk-..."

.NOTES
    For GitHub source, requires GitHub CLI (gh) to be installed and authenticated.
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Source for environment variables")]
    [ValidateSet("github", "interactive", "parameters")]
    [string]$Source = "interactive",
    
    [Parameter(HelpMessage = "Output file path")]
    [string]$OutputFile = ".env",
    
    [Parameter(HelpMessage = "Force overwrite existing file")]
    [switch]$Force,
    
    [Parameter(HelpMessage = "GitHub repository (owner/repo) - for github source")]
    [string]$Repository = "",
    
    # Parameters for 'parameters' source
    [Parameter(HelpMessage = "Database password")]
    [string]$DbPassword = "",
    
    [Parameter(HelpMessage = "LLM Provider (OpenAI or Gemini)")]
    [ValidateSet("OpenAI", "Gemini", "")]
    [string]$LlmProvider = "",
    
    [Parameter(HelpMessage = "OpenAI API key")]
    [string]$OpenAiApiKey = "",
    
    [Parameter(HelpMessage = "OpenAI model name")]
    [string]$OpenAiModel = "gpt-4o-mini",
    
    [Parameter(HelpMessage = "Gemini API key")]
    [string]$GeminiApiKey = "",
    
    [Parameter(HelpMessage = "Gemini model name")]
    [string]$GeminiModel = "gemini-1.5-flash"
)

# Color output functions
function Write-Success { param($Message) Write-Host "✓ $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "✗ $Message" -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host "⚠ $Message" -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host "ℹ $Message" -ForegroundColor Cyan }
function Write-Title { param($Message) Write-Host "`n$Message" -ForegroundColor Yellow }

# Check if file exists and handle overwrite
function Test-FileOverwrite {
    param($FilePath)
    
    if (Test-Path $FilePath) {
        if (-not $Force) {
            $response = Read-Host "File '$FilePath' already exists. Overwrite? (y/n)"
            if ($response -ne 'y' -and $response -ne 'Y') {
                Write-Warning "Operation cancelled."
                exit 0
            }
        }
        else {
            Write-Warning "Overwriting existing file: $FilePath"
        }
    }
}

# Fetch secrets from GitHub
function Get-GitHubSecrets {
    param($Repo)
    
    # Check if GitHub CLI is installed
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed."
        Write-Info "Install from: https://cli.github.com/"
        Write-Info "After installation, authenticate with: gh auth login"
        return $null
    }
    
    # Check authentication
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Not authenticated with GitHub CLI."
        Write-Info "Please authenticate with: gh auth login"
        return $null
    }
    
    # Get current repository if not specified
    if (-not $Repo) {
        try {
            $remoteUrl = git remote get-url origin 2>$null
            if ($remoteUrl -match "github\.com[:/]([^/]+/[^/]+?)(\.git)?$") {
                $Repo = $matches[1]
            }
            else {
                Write-Error "Could not detect GitHub repository from git remote."
                Write-Info "Please specify repository with -Repository parameter."
                return $null
            }
        }
        catch {
            Write-Error "Not in a git repository."
            Write-Info "Please specify repository with -Repository parameter."
            return $null
        }
    }
    
    Write-Info "Fetching secrets from repository: $Repo"
    
    # List secrets (note: values cannot be retrieved for security)
    $secretsList = gh secret list --repo $Repo --json name 2>&1 | ConvertFrom-Json
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to fetch secrets from GitHub."
        Write-Warning "Note: You need admin access to the repository to view secrets."
        Write-Info "Falling back to interactive mode..."
        return $null
    }
    
    Write-Warning "GitHub API does not allow retrieving secret values for security reasons."
    Write-Info "The following secrets are configured in the repository:"
    $secretsList | ForEach-Object { Write-Host "  - $($_.name)" -ForegroundColor Gray }
    Write-Info "Falling back to interactive mode to enter values..."
    
    return $null
}

# Get values interactively from user
function Get-InteractiveValues {
    Write-Title "Environment Setup - Interactive Mode"
    Write-Info "Please provide the following values:"
    Write-Host ""
    
    $values = @{}
    
    # Database password
    Write-Host "Database Configuration:" -ForegroundColor Yellow
    $securePassword = Read-Host "  Database password" -AsSecureString
    $values.DB_PASSWORD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
    
    Write-Host ""
    Write-Host "LLM Provider Configuration:" -ForegroundColor Yellow
    do {
        $provider = Read-Host "  LLM Provider (OpenAI/Gemini)"
    } while ($provider -ne "OpenAI" -and $provider -ne "Gemini")
    $values.LLM_PROVIDER = $provider
    
    Write-Host ""
    if ($provider -eq "OpenAI") {
        Write-Host "OpenAI Configuration:" -ForegroundColor Yellow
        $values.OPENAI_API_KEY = Read-Host "  OpenAI API key"
        $model = Read-Host "  OpenAI model (default: gpt-4o-mini)"
        $values.OPENAI_MODEL = if ($model) { $model } else { "gpt-4o-mini" }
        $values.GEMINI_API_KEY = ""
        $values.GEMINI_MODEL = "gemini-1.5-flash"
    }
    else {
        Write-Host "Gemini Configuration:" -ForegroundColor Yellow
        $values.GEMINI_API_KEY = Read-Host "  Gemini API key"
        $model = Read-Host "  Gemini model (default: gemini-1.5-flash)"
        $values.GEMINI_MODEL = if ($model) { $model } else { "gemini-1.5-flash" }
        $values.OPENAI_API_KEY = ""
        $values.OPENAI_MODEL = "gpt-4o-mini"
    }
    
    return $values
}

# Get values from parameters
function Get-ParameterValues {
    if (-not $DbPassword) {
        Write-Error "DbPassword parameter is required when using 'parameters' source."
        exit 1
    }
    
    if (-not $LlmProvider) {
        Write-Error "LlmProvider parameter is required when using 'parameters' source."
        exit 1
    }
    
    $values = @{
        DB_PASSWORD = $DbPassword
        LLM_PROVIDER = $LlmProvider
        OPENAI_API_KEY = $OpenAiApiKey
        OPENAI_MODEL = $OpenAiModel
        GEMINI_API_KEY = $GeminiApiKey
        GEMINI_MODEL = $GeminiModel
    }
    
    return $values
}

# Create .env file
function New-EnvFile {
    param($FilePath, $Values)
    
    $content = @"
# CV Analyzer Environment Configuration
# Generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# 
# IMPORTANT: This file contains sensitive information.
# Never commit this file to version control!

# ==============================================================================
# Database Configuration
# ==============================================================================
DB_PASSWORD=$($Values.DB_PASSWORD)

# ==============================================================================
# LLM Provider Configuration
# ==============================================================================
LLM_PROVIDER=$($Values.LLM_PROVIDER)

# ==============================================================================
# OpenAI Configuration
# ==============================================================================
OPENAI_API_KEY=$($Values.OPENAI_API_KEY)
OPENAI_MODEL=$($Values.OPENAI_MODEL)

# ==============================================================================
# Google Gemini Configuration
# ==============================================================================
GEMINI_API_KEY=$($Values.GEMINI_API_KEY)
GEMINI_MODEL=$($Values.GEMINI_MODEL)
"@
    
    try {
        $content | Out-File -FilePath $FilePath -Encoding UTF8 -NoNewline
        Write-Success "Environment file created: $FilePath"
        return $true
    }
    catch {
        Write-Error "Failed to create environment file: $($_.Exception.Message)"
        return $false
    }
}

# Check .gitignore
function Test-GitIgnoreEntry {
    $gitIgnorePath = ".gitignore"
    
    if (Test-Path $gitIgnorePath) {
        $content = Get-Content $gitIgnorePath -Raw
        if ($content -notmatch "^\.env$" -and $content -notmatch "\n\.env\n") {
            Write-Warning ".env is not in .gitignore"
            Write-Info "Consider adding '.env' to .gitignore to prevent committing secrets"
        }
    }
}

# Main execution
Write-Title "CV Analyzer - Environment Setup"

# Check for file overwrite
Test-FileOverwrite -FilePath $OutputFile

# Get values based on source
$values = $null
switch ($Source) {
    "github" {
        Write-Info "Attempting to fetch secrets from GitHub..."
        $values = Get-GitHubSecrets -Repo $Repository
        if (-not $values) {
            Write-Info "Switching to interactive mode..."
            $values = Get-InteractiveValues
        }
    }
    "interactive" {
        $values = Get-InteractiveValues
    }
    "parameters" {
        $values = Get-ParameterValues
    }
}

if (-not $values) {
    Write-Error "Failed to get environment values."
    exit 1
}

# Create .env file
if (New-EnvFile -FilePath $OutputFile -Values $values) {
    Write-Host ""
    Write-Success "Setup completed successfully!"
    Write-Info "Environment file: $OutputFile"
    Write-Host ""
    
    # Check .gitignore
    Test-GitIgnoreEntry
    
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. Review the generated .env file" -ForegroundColor Gray
    Write-Host "  2. Start the application with: docker-compose up" -ForegroundColor Gray
    Write-Host ""
}
else {
    Write-Error "Setup failed."
    exit 1
}
