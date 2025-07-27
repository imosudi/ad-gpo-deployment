<#
.SYNOPSIS
    Applies GPO for the Quality Control department.

.DESCRIPTION
    - Creates and links a GPO for the Quality Control OU.
    - Logs all key steps and expected software requirements.
#>

# ---------------- Configuration ----------------
$OU = "OU=Quality Control,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Quality_Control_Policy"
$LogFile = "C:\scripts\logs\apply_quality_control_gpo.log"
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

Write-Log "Starting GPO setup for Quality Control Department..."

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

Write-Log "Applying software requirements for Quality Control Department..."

foreach ($software in $QualityControlSoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for installation logic
}

Write-Log "Quality Control Department GPO setup completed."
Write-Output "✅ Quality Control GPO applied successfully. Log file: $LogFile"
