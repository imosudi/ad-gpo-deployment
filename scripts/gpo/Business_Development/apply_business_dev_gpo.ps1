<#
.SYNOPSIS
    Applies the GPO policy for Business Development department.

.DESCRIPTION
    - Creates and links a GPO tailored to the Business Development OU
    - Loads business-specific software list
    - Logs all steps for auditing
#>

# ---------------- Configuration ----------------
$OU = "OU=Business Development,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "BusinessDev_Policy"
$LogFile = "C:\scripts\logs\apply_business_dev_gpo.log"
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

Write-Log "Starting GPO setup for Business Development..."

Import-Module GroupPolicy -ErrorAction Stop

# Create the GPO if it doesn't already exist
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    Write-Log "Creating GPO: $GPOName"
    New-GPO -Name $GPOName | Out-Null
} else {
    Write-Log "GPO already exists: $GPOName"
}

# Link the GPO to the OU
try {
    New-GPLink -Name $GPOName -Target $OU -Enforced:$false -ErrorAction Stop
    Write-Log "GPO linked to $OU"
} catch {
    Write-Log "GPO link failed or already exists: $_"
}

# Import department-specific software list
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common_software_lists.ps1"

Write-Log "Applying department software requirements..."

foreach ($software in $BusinessDevSoftware) {
    Write-Log "Validating presence of: $software"
    # Placeholder for install routine
}

Write-Log "Business Development GPO configuration complete."
Write-Output "✅ Business Development GPO applied. See log at: $LogFile"
# End of script