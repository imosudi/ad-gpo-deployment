<#
.SYNOPSIS
    Applies GPO for the Programs department.

.DESCRIPTION
    - Creates and links a Programs GPO
    - Logs setup actions
    - Loads and logs software requirements
#>

# ---------------- Configuration ----------------
$OU = "OU=Programs,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Programs_Policy"
$LogFile = "C:\scripts\logs\apply_programs_gpo.log"
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

Write-Log "Starting GPO setup for Programs Department..."

Import-Module GroupPolicy -ErrorAction Stop

# Create the GPO if not already existing
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

Write-Log "Applying software requirements for Programs Department..."

foreach ($software in $ProgramsSoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for actual install logic
}

Write-Log "Programs Department GPO setup completed."
Write-Output "✅ Programs GPO applied successfully. Log file: $LogFile"
