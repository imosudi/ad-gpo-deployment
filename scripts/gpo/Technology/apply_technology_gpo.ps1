<#
.SYNOPSIS
    Applies GPO for the Technology department.

.DESCRIPTION
    - Creates and links a GPO to the Technology OU.
    - Includes baseline setup and references department-specific software.
#>

# ---------------- Configuration ----------------
$OU = "OU=Technology,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Technology_Policy"
$LogFile = "C:\scripts\logs\apply_technology_gpo.log"
# ----------------------------------------------

function Write-Log {
    param ($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$timestamp - $message"
}

# Ensure log directory exists
$logDir = Split-Path $LogFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

Write-Log "Starting GPO setup for Technology Department..."

Import-Module GroupPolicy -ErrorAction Stop

# Create GPO if not existing
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    Write-Log "Creating GPO: $GPOName"
    New-GPO -Name $GPOName | Out-Null
} else {
    Write-Log "GPO already exists: $GPOName"
}

# Link GPO to OU
try {
    New-GPLink -Name $GPOName -Target $OU -Enforced:$false -ErrorAction Stop
    Write-Log "GPO linked to $OU"
} catch {
    Write-Log "GPO link failed or already exists: $_"
}

# Import software list
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common_software_lists.ps1"

Write-Log "Applying software requirements for Technology Department..."

foreach ($software in $TechnologySoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for software enforcement or validation
}

Write-Log "Technology Department GPO setup completed."
Write-Output "✅ Technology GPO applied successfully. Log file: $LogFile"
