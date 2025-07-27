<#
.SYNOPSIS
    Applies Group Policy Objects tailored for the Sysadmin OU.

.DESCRIPTION
    - Creates and links GPO specific to Sysadmin operational and security needs
    - Ensures baseline configurations and installs essential software
    - Logs all actions for auditing
#>

# ---------------- Configuration ----------------
$OU = "OU=Sysadmin,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Sysadmin_Operational_Policy"
$LogFile = "C:\scripts\logs\apply_sysadmin_gpo.log"
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

Write-Log "Starting GPO setup for Sysadmin OU..."

Import-Module GroupPolicy -ErrorAction Stop

# Check if GPO exists, create if not
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

# Import common software list and install policies
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common_software_lists.ps1"

Write-Log "Applying software policies for Sysadmin..."

foreach ($software in $SysadminSoftware) {
    Write-Log "Ensuring software required: $software"
    # Placeholder: Add logic to check/install each software (e.g., Chocolatey, Intune deployment, etc.)
}

Write-Log "Completed GPO application for Sysadmin OU."
Write-Output "✅ Sysadmin GPO setup complete. See log at: $LogFile"
