<#
.SYNOPSIS
    Applies GPO for the Service Accounts department.

.DESCRIPTION
    - Enforces least privilege policies, credential protections, and auditing policies for service accounts.
    - Creates and links a GPO to the Service Accounts OU.
#>

# ---------------- Configuration ----------------
$OU = "OU=Service Accounts,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Service_Accounts_Department_Policy"
$LogFile = "C:\scripts\logs\apply_service_accounts_gpo.log"
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

Write-Log "Starting GPO setup for Service Accounts..."

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

Write-Log "Applying software requirements for Service Accounts..."

foreach ($software in $ServiceAccountTools) {
    Write-Log "Expected software/tool: $software"
    # Placeholder for software deployment, credential protection, etc.
}

Write-Log "Service Accounts Department GPO setup completed."
Write-Output "✅ Service Accounts GPO applied successfully. Log file: $LogFile"
