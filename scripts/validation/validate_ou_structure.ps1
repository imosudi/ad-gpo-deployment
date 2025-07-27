<#
.SYNOPSIS
    Validates the existence of all required company department OUs in Active Directory.

.DESCRIPTION
    - Checks each OU under the base OU "QuantumExpression"
    - Logs found/missing OUs
    - Provides a summary report at the end
#>

# ------------------------ Configuration --------------------------
$baseOU        = "OU=QuantumExpression,DC=quantumexpression,DC=net"
#$logFile       = "C:\scripts\logs\validate_organizational_units.log"
$logFile       = "logs\validation.log" # Relative path for easier testing but ensure to adjust as needed.
$departmentOUs = @(
    "Executive Office", "Sysadmin", "Digital Content", "Business Development",
    "Digital", "PR & Image Control", "Finance & Admin", "Sales & Marketing",
    "Production MCR", "News", "Music & Library Mgt", "Programs", "Quality Control",
    "Research", "Technology", "Traffic and Control", "Servers", "Service Accounts", "General User"
)
# -----------------------------------------------------------------

function Write-Log {
    param ([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

# Ensure log directory exists
$logDir = Split-Path $logFile
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

# Import Active Directory module
Import-Module ActiveDirectory -ErrorAction Stop
Write-Log "ActiveDirectory module loaded."
Write-Log "Starting OU validation..."

# Validate base OU
$missingCount = 0
if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$baseOU)" -ErrorAction SilentlyContinue)) {
    Write-Log "❌ Base OU not found: $baseOU"
    Write-Output "Base OU not found. Please run create_organizational_units.ps1 first."
    return
} else {
    Write-Log "✅ Base OU found: $baseOU"
}

# Validate each department OU
foreach ($ou in $departmentOUs) {
    $ouDN = "OU=$ou,$baseOU"
    if (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ouDN)" -ErrorAction SilentlyContinue) {
        Write-Log "✅ OU exists: $ou"
    } else {
        Write-Log "❌ Missing OU: $ou"
        $missingCount++
    }
}

Write-Log "Validation complete. Total missing OUs: $missingCount"
Write-Output "Validation complete. See log for details: $logFile"
