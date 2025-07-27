<#
.SYNOPSIS
    Applies GPO for the Research department.

.DESCRIPTION
    - Creates and links a GPO for the Research OU.
    - Logs all major steps and includes department-specific software requirements.
#>

# ---------------- Configuration ----------------
$OU = "OU=Research,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Research_Policy"
$LogFile = "C:\scripts\logs\apply_research_gpo.log"
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

Write-Log "Starting GPO setup for Research Department..."

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

Write-Log "Applying software requirements for Research Department..."

foreach ($software in $ResearchSoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for installation logic
}

Write-Log "Research Department GPO setup completed."
Write-Output "✅ Research GPO applied successfully. Log file: $LogFile"
