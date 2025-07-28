<#
.SYNOPSIS
    Creates organisational units (OUs) for each company department under the domain.

.DESCRIPTION
    - Ensures ActiveDirectory module is available
    - Creates a base company OU if not present
    - Adds all departmental OUs under it
    - Logs progress to C:\scripts\logs\create_organizational_units.log
#>

# ------------------------ Configuration --------------------------
$baseOU        = "OU=QuantumExpression,DC=quantumexpression,DC=net"
$logFile       = "C:\scripts\logs\create_organizational_units.log"
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

# Create base OU if it doesn't exist
if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$baseOU'" -ErrorAction SilentlyContinue)) {
    New-ADOrganizationalUnit -Name "QuantumExpression" -Path "DC=quantumexpression,DC=net" -ProtectedFromAccidentalDeletion $true
    Write-Log "Created base OU: QuantumExpression"
} else {
    Write-Log "Base OU already exists: QuantumExpression"
}

# Create department OUs
foreach ($ou in $departmentOUs) {
    $ouDN = "OU=$ou,$baseOU"
    if (-not (Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$ouDN)" -ErrorAction SilentlyContinue)) {
        try {
            New-ADOrganizationalUnit -Name $ou -Path $baseOU -ProtectedFromAccidentalDeletion $true
            Write-Log "Created OU: $ou"
        } catch {
            Write-Log "Error creating OU: $ou - $_"
        }
    } else {
        Write-Log "OU already exists: $ou"
    }
}

Write-Log "Organisational Unit creation complete."
# End of script