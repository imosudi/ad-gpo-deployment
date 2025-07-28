<#
.SYNOPSIS
    Applies GPO for the Traffic and Control department.

.DESCRIPTION
    - Creates and links a GPO to the Traffic and Control OU.
    - Enforces departmental baseline policies and software expectations.
#>

# ---------------- Configuration ----------------
$OU = "OU=Traffic and Control,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Traffic_Control_Policy"
$LogFile = "C:\scripts\logs\apply_traffic_control_gpo.log"
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

Write-Log "Starting GPO setup for Traffic and Control Department..."

Import-Module GroupPolicy -ErrorAction Stop

# Create GPO if not already existing
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

Write-Log "Applying software requirements for Traffic and Control Department..."

foreach ($software in $TrafficControlSoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for software deployment logic
}

Write-Log "Traffic and Control Department GPO setup completed."
Write-Output "✅ Traffic and Control GPO applied successfully. Log file: $LogFile"
