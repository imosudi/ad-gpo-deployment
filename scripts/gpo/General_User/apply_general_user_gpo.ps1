<#
.SYNOPSIS
    Applies a standard GPO for all General Users.

.DESCRIPTION
    - Creates and links a baseline user policy GPO for General Users
    - Applies standard software provisioning
    - Logs actions for compliance and traceability
#>

# ---------------- Configuration ----------------
$OU = "OU=General User,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "GeneralUser_Baseline_Policy"
$LogFile = "C:\scripts\logs\apply_general_user_gpo.log"
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

Write-Log "Starting GPO setup for General Users..."

Import-Module GroupPolicy -ErrorAction Stop

# Create the GPO if it doesn't exist
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    Write-Log "Creating new GPO: $GPOName"
    New-GPO -Name $GPOName | Out-Null
} else {
    Write-Log "GPO already exists: $GPOName"
}

# Link the GPO to the OU
try {
    New-GPLink -Name $GPOName -Target $OU -Enforced:$false -ErrorAction Stop
    Write-Log "GPO linked to $OU"
} catch {
    Write-Log "GPO already linked or encountered error: $_"
}

# Import general software list
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common_software_lists.ps1"

Write-Log "Applying baseline software policies for General Users..."

foreach ($software in $GeneralUserSoftware) {
    Write-Log "Ensuring software required: $software"
    # Placeholder for software check/install routine
}

Write-Log "Completed GPO application for General User OU."
Write-Output "✅ General User GPO setup complete. See log at: $LogFile"
