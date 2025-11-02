#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Simple script to create .env file template with GitHub secrets structure.

.DESCRIPTION
    This script creates a .env file template based on the secrets defined in GitHub Actions.
    Since secret values cannot be retrieved for security reasons, it creates a template
    with placeholder values that match the expected secrets.

.PARAMETER OutputFile
    The output file path. Defaults to ".env".

.PARAMETER Force
    Overwrite existing .env file without prompting.

.EXAMPLE
    .\create-env-template.ps1
    
.EXAMPLE
    .\create-env-template.ps1 -OutputFile ".env.local" -Force

.NOTES
    This script creates a template with placeholder values.
    You must manually update the values with your actual secrets.
#>

[CmdletBinding()]
param(
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

# Create .env file template
function New-EnvTemplate {
    param($FilePath)
    
    $envContent = @"
# CV Analyzer Environment Configuration
# Generated on: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# 
# This file contains environment variables for the CV Analyzer application.
# Replace placeholder values with your actual secrets.
# 
# IMPORTANT: Never commit this file to version control!
# Make sure .env is in your .gitignore file.

# ==============================================================================
# Database Configuration
# ==============================================================================
DB_PASSWORD=your-secure-database-password-here

# ==============================================================================
# LLM Provider Configuration
# ==============================================================================
# Supported values: OpenAI, Gemini
LLM_PROVIDER=OpenAI

# ==============================================================================
# OpenAI Configuration
# ==============================================================================
# Get your API key from: https://platform.openai.com/api-keys
OPENAI_API_KEY=sk-your-openai-api-key-here
OPENAI_MODEL=gpt-4o-mini

# ==============================================================================
# Google Gemini Configuration
# ==============================================================================
# Get your API key from: https://makersuite.google.com/app/apikey
GEMINI_API_KEY=your-gemini-api-key-here
GEMINI_MODEL=gemini-1.5-flash

# ==============================================================================
# Additional Configuration (if needed)
# ==============================================================================
# Add any additional environment variables here
"@
    
    try {
        $envContent | Out-File -FilePath $FilePath -Encoding UTF8
        return $true
    }
    catch {
        Write-Error "Failed to create environment file: $($_.Exception.Message)"
        return $false
    }
}

# Check if .gitignore includes .env
function Test-GitIgnore {
    $gitIgnorePath = ".gitignore"
    
    if (Test-Path $gitIgnorePath) {
        $gitIgnoreContent = Get-Content $gitIgnorePath -Raw
        if ($gitIgnoreContent -match "\.env") {
            return $true
        }
    }
    return $false
}

# Add .env to .gitignore if needed
function Add-ToGitIgnore {
    $gitIgnorePath = ".gitignore"
    
    if (-not (Test-Path $gitIgnorePath)) {
        Write-Info "Creating .gitignore file..."
        "# Environment files`n.env`n.env.*" | Out-File -FilePath $gitIgnorePath -Encoding UTF8
    }
    else {
        Write-Info "Adding .env to existing .gitignore..."
        "`n# Environment files`n.env`n.env.*" | Add-Content -Path $gitIgnorePath
    }
}

# Main execution
function Main {
    Write-Info "CV Analyzer - Environment File Template Generator"
    Write-Info "================================================="
    
    # Check if output file exists
    if ((Test-Path $OutputFile) -and -not $Force) {
        $response = Read-Host "File '$OutputFile' already exists. Overwrite? (y/N)"
        if ($response -notmatch "^[Yy]") {
            Write-Info "Operation cancelled."
            exit 0
        }
    }
    
    # Create .env template
    if (New-EnvTemplate -FilePath $OutputFile) {
        Write-Success "Environment template created: $OutputFile"
        
        # Check .gitignore
        if (-not (Test-GitIgnore)) {
            $response = Read-Host "Add .env to .gitignore to prevent committing secrets? (Y/n)"
            if ($response -notmatch "^[Nn]") {
                Add-ToGitIgnore
                Write-Success ".env added to .gitignore"
            }
        }
        else {
            Write-Success ".env is already in .gitignore"
        }
        
        Write-Info ""
        Write-Info "Next steps:"
        Write-Info "1. Edit '$OutputFile' and replace placeholder values with your actual secrets:"
        Write-Info "   - Get OpenAI API key from: https://platform.openai.com/api-keys"
        Write-Info "   - Get Gemini API key from: https://makersuite.google.com/app/apikey"
        Write-Info "   - Set a secure database password"
        Write-Info "2. Choose your LLM provider (OpenAI or Gemini)"
        Write-Info "3. Test your application with: docker-compose up -d"
        Write-Info ""
        Write-Warning "IMPORTANT: Never commit '$OutputFile' to version control!"
        
        exit 0
    }
    else {
        exit 1
    }
}

# Run main function
Main