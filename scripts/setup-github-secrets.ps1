#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Set up GitHub secrets for CV Analyzer CI/CD pipeline.

.DESCRIPTION
    This script helps you set up the required GitHub secrets for the CV Analyzer project.
    It can either set secrets directly using GitHub CLI or provide instructions for manual setup.

.PARAMETER Repository
    The GitHub repository in the format "owner/repo". Defaults to current repository.

.PARAMETER Environment
    The environment name (e.g., 'staging', 'production'). Optional.

.PARAMETER Interactive
    Run in interactive mode to input secret values.

.PARAMETER DryRun
    Show what would be done without actually setting secrets.

.EXAMPLE
    .\setup-github-secrets.ps1 -Interactive
    
.EXAMPLE
    .\setup-github-secrets.ps1 -Repository "username/cv-analyzer" -Environment "production"

.EXAMPLE
    .\setup-github-secrets.ps1 -DryRun

.NOTES
    Requires GitHub CLI (gh) to be installed and authenticated for automatic setup.
    Otherwise, provides instructions for manual setup via GitHub web interface.
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "GitHub repository (owner/repo)")]
    [string]$Repository = "",
    
    [Parameter(HelpMessage = "Environment name (optional)")]
    [string]$Environment = "",
    
    [Parameter(HelpMessage = "Run in interactive mode")]
    [switch]$Interactive,
    
    [Parameter(HelpMessage = "Show what would be done without executing")]
    [switch]$DryRun
)

# Color output functions
function Write-Success { param($Message) Write-Host $Message -ForegroundColor Green }
function Write-Error { param($Message) Write-Host $Message -ForegroundColor Red }
function Write-Warning { param($Message) Write-Host $Message -ForegroundColor Yellow }
function Write-Info { param($Message) Write-Host $Message -ForegroundColor Cyan }

# Required secrets configuration
$RequiredSecrets = @{
    "DB_PASSWORD" = @{
        Description = "Database password for PostgreSQL"
        Example = "SecurePassword123!"
        Required = $true
    }
    "LLM_PROVIDER" = @{
        Description = "LLM Provider (OpenAI or Gemini)"
        Example = "OpenAI"
        Required = $true
    }
    "OPENAI_API_KEY" = @{
        Description = "OpenAI API key from platform.openai.com"
        Example = "sk-..."
        Required = $false
        Note = "Required if using OpenAI as LLM provider"
    }
    "OPENAI_MODEL" = @{
        Description = "OpenAI model to use"
        Example = "gpt-4o-mini"
        Required = $false
    }
    "GEMINI_API_KEY" = @{
        Description = "Google Gemini API key from makersuite.google.com"
        Example = "AIza..."
        Required = $false
        Note = "Required if using Gemini as LLM provider"
    }
    "GEMINI_MODEL" = @{
        Description = "Gemini model to use"
        Example = "gemini-1.5-flash"
        Required = $false
    }
}

# Check if GitHub CLI is available
function Test-GitHubCli {
    try {
        $null = Get-Command gh -ErrorAction Stop
        $authStatus = gh auth status 2>&1
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

# Get current repository
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
        return $null
    }
    return $Repository
}

# Set secret using GitHub CLI
function Set-GitHubSecret {
    param($Repo, $SecretName, $SecretValue, $Env)
    
    if ($DryRun) {
        Write-Info "[DRY RUN] Would set secret: $SecretName"
        return $true
    }
    
    try {
        if ($Env) {
            $result = echo $SecretValue | gh secret set $SecretName --repo $Repo --env $Env 2>&1
        }
        else {
            $result = echo $SecretValue | gh secret set $SecretName --repo $Repo 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "✓ Set secret: $SecretName"
            return $true
        }
        else {
            Write-Error "✗ Failed to set secret $SecretName`: $result"
            return $false
        }
    }
    catch {
        Write-Error "✗ Error setting secret $SecretName`: $($_.Exception.Message)"
        return $false
    }
}

# Interactive input for secrets
function Get-SecretValue {
    param($SecretName, $SecretConfig)
    
    Write-Info ""
    Write-Info "Setting up: $SecretName"
    Write-Info "Description: $($SecretConfig.Description)"
    Write-Info "Example: $($SecretConfig.Example)"
    if ($SecretConfig.Note) {
        Write-Warning "Note: $($SecretConfig.Note)"
    }
    
    if ($SecretConfig.Required) {
        do {
            $value = Read-Host "Enter value for $SecretName (required)"
        } while (-not $value)
    }
    else {
        $value = Read-Host "Enter value for $SecretName (optional, press Enter to skip)"
    }
    
    return $value
}

# Show manual setup instructions
function Show-ManualInstructions {
    param($Repo)
    
    Write-Info ""
    Write-Info "Manual GitHub Secrets Setup"
    Write-Info "============================"
    Write-Info ""
    Write-Info "Since GitHub CLI is not available, please set up secrets manually:"
    Write-Info ""
    Write-Info "1. Go to: https://github.com/$Repo/settings/secrets/actions"
    Write-Info "2. Click 'New repository secret' for each of the following:"
    Write-Info ""
    
    foreach ($secretName in $RequiredSecrets.Keys) {
        $config = $RequiredSecrets[$secretName]
        $required = if ($config.Required) { "(REQUIRED)" } else { "(optional)" }
        
        Write-Info "   Secret Name: $secretName $required"
        Write-Info "   Description: $($config.Description)"
        Write-Info "   Example: $($config.Example)"
        if ($config.Note) {
            Write-Warning "   Note: $($config.Note)"
        }
        Write-Info ""
    }
    
    if ($Environment) {
        Write-Info "Environment-specific secrets:"
        Write-Info "1. Go to: https://github.com/$Repo/settings/environments"
        Write-Info "2. Create or edit environment: $Environment"
        Write-Info "3. Add the same secrets to the environment"
    }
}

# Main execution
function Main {
    Write-Info "CV Analyzer - GitHub Secrets Setup"
    Write-Info "==================================="
    
    # Get repository
    $repo = Get-CurrentRepository
    if (-not $repo) { exit 1 }
    
    Write-Info "Repository: $repo"
    if ($Environment) {
        Write-Info "Environment: $Environment"
    }
    Write-Info ""
    
    # Check GitHub CLI availability
    $hasGitHubCli = Test-GitHubCli
    
    if (-not $hasGitHubCli) {
        Write-Warning "GitHub CLI not available or not authenticated."
        Write-Info "For automatic setup, install GitHub CLI and run: gh auth login"
        
        Show-ManualInstructions -Repo $repo
        exit 0
    }
    
    if ($DryRun) {
        Write-Info "DRY RUN MODE - No secrets will actually be set"
        Write-Info ""
    }
    
    # Interactive mode
    if ($Interactive) {
        Write-Info "Interactive mode: Please enter values for each secret."
        Write-Info "Leave optional secrets empty to skip them."
        
        $secretsToSet = @{}
        
        foreach ($secretName in $RequiredSecrets.Keys) {
            $config = $RequiredSecrets[$secretName]
            $value = Get-SecretValue -SecretName $secretName -SecretConfig $config
            
            if ($value) {
                $secretsToSet[$secretName] = $value
            }
        }
        
        Write-Info ""
        Write-Info "Setting secrets..."
        
        $successCount = 0
        foreach ($secretName in $secretsToSet.Keys) {
            if (Set-GitHubSecret -Repo $repo -SecretName $secretName -SecretValue $secretsToSet[$secretName] -Env $Environment) {
                $successCount++
            }
        }
        
        Write-Info ""
        Write-Success "Successfully set $successCount out of $($secretsToSet.Count) secrets."
        
        if ($successCount -eq $secretsToSet.Count) {
            Write-Info ""
            Write-Info "All secrets have been set up successfully!"
            Write-Info "Your CI/CD pipeline should now work with these secrets."
        }
    }
    else {
        # Non-interactive mode - show instructions
        Write-Info "Available secrets to configure:"
        Write-Info ""
        
        foreach ($secretName in $RequiredSecrets.Keys) {
            $config = $RequiredSecrets[$secretName]
            $required = if ($config.Required) { "(REQUIRED)" } else { "(optional)" }
            
            Write-Info "  $secretName $required"
            Write-Info "    $($config.Description)"
            if ($config.Note) {
                Write-Warning "    Note: $($config.Note)"
            }
        }
        
        Write-Info ""
        Write-Info "Run with -Interactive flag to set secrets interactively."
        Write-Info "Or set them manually at: https://github.com/$repo/settings/secrets/actions"
    }
}

# Run main function
Main