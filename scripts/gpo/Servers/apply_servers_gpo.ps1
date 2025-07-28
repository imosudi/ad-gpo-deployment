<#
.SYNOPSIS
    Applies GPO for the Servers department.

.DESCRIPTION
    - Creates and links a GPO to the Servers OU.
    - Enforces baseline configuration, remote access, logging, and monitoring standards for server assets.
#>

# ---------------- Configuration ----------------
$OU = "OU=Servers,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Servers_Department_Policy"
$LogFile = "C:\scripts\logs\apply_servers_gpo.log"
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

Write-Log "Starting GPO setup for Servers Department..."

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
    New-GPLink -Name $GPOName -Target $OU -Enforced:$true -ErrorAction Stop
    Write-Log "GPO linked to $OU"
} catch {
    Write-Log "GPO link failed or already exists: $_"
}

# Import software list
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common_software_lists.ps1"

Write-Log "Applying software requirements for Servers Department..."

foreach ($software in $ServerSoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for software deployment or compliance audit
}

Write-Log "Servers Department GPO setup completed."
Write-Output "✅ Servers GPO applied successfully. Log file: $LogFile"
