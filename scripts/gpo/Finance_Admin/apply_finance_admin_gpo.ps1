<#
.SYNOPSIS
    Applies Group Policy Object for the Finance & Admin department.

.DESCRIPTION
    - Ensures the GPO is created and linked to the Finance & Admin OU
    - Logs configuration steps and expected software
    - Imports a standardised software list for department operations
#>

# ---------------- Configuration ----------------
$OU = "OU=Finance & Admin,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "FinanceAdmin_Policy"
$LogFile = "C:\scripts\logs\apply_finance_admin_gpo.log"
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

Write-Log "Starting GPO setup for Finance & Admin..."

Import-Module GroupPolicy -ErrorAction Stop

# Create the GPO if it doesn't exist
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

# Import department-specific software list
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common_software_lists.ps1"

Write-Log "Applying software requirements for Finance & Admin..."

foreach ($software in $FinanceAdminSoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for actual deployment logic
}

Write-Log "Finance & Admin department GPO configuration complete."
Write-Output "✅ Finance & Admin GPO applied. See log at: $LogFile"
