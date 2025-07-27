<#
.SYNOPSIS
    Applies Group Policy Object for the Sales & Marketing department.

.DESCRIPTION
    - Creates and links GPO to Sales & Marketing OU
    - Logs all operations
    - References expected software list for compliance
#>

# ---------------- Configuration ----------------
$OU = "OU=Sales & Marketing,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "SalesMarketing_Policy"
$LogFile = "C:\scripts\logs\apply_sales_marketing_gpo.log"
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

Write-Log "Starting GPO setup for Sales & Marketing..."

Import-Module GroupPolicy -ErrorAction Stop

# Create the GPO if it doesn't already exist
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    Write-Log "Creating GPO: $GPOName"
    New-GPO -Name $GPOName | Out-Null
} else {
    Write-Log "GPO already exists: $GPOName"
}

# Link GPO to the OU
try {
    New-GPLink -Name $GPOName -Target $OU -Enforced:$false -ErrorAction Stop
    Write-Log "GPO linked to $OU"
} catch {
    Write-Log "GPO link failed or already exists: $_"
}

# Import software expectations
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common_software_lists.ps1"

Write-Log "Applying software requirements for Sales & Marketing..."

foreach ($software in $SalesMarketingSoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for future automation
}

Write-Log "Sales & Marketing department GPO configuration complete."
Write-Output "✅ Sales & Marketing GPO applied. See log at: $LogFile"
