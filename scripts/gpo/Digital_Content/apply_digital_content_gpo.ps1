<#
.SYNOPSIS
    Applies the GPO policy for the Digital Content department.

.DESCRIPTION
    - Creates and links a GPO to the Digital Content OU
    - Applies configurations specific to content creation/editing
    - Logs all steps to support auditing and error tracking
#>

# ---------------- Configuration ----------------
$OU = "OU=Digital Content,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "DigitalContent_Policy"
$LogFile = "C:\scripts\logs\apply_digital_content_gpo.log"
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

Write-Log "Starting GPO setup for Digital Content..."

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

Write-Log "Applying software requirements for Digital Content..."

foreach ($software in $DigitalContentSoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for deployment integration
}

Write-Log "Digital Content GPO configuration complete."
Write-Output "✅ Digital Content GPO applied. See log at: $LogFile"
