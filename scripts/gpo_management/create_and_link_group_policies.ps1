<#
.SYNOPSIS
    Automates the creation and linking of Group Policy Objects (GPOs) to each department OU.

.DESCRIPTION
    - Creates a named GPO for each OU.
    - Links the GPO to the corresponding OU.
    - Logs the actions and handles existing GPOs or link states.

.NOTES
    Ensure you're running this with Domain Admin rights.
#>

# ------------------------ Configuration ------------------------
$BaseOU = "OU=QuantumExpression,DC=quantumexpression,DC=net"
$LogFile = "C:\scripts\logs\gpo_creation_linking.log"

$Departments = @(
    "Digital",
    "PR & Image Control",
    "Finance & Admin",
    "Sales & Marketing",
    "Production MCR",
    "News",
    "Music & Library Mgt",
    "Programs",
    "Quality Control",
    "Research",
    "Technology",
    "Traffic and Control",
    "Servers",
    "Service Accounts"
)
# ---------------------------------------------------------------

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

Write-Log "🚀 Starting GPO creation and linking process..."
Import-Module GroupPolicy

foreach ($dept in $Departments) {
    $sanitisedOU = $dept -replace '[^\w]', ''  # Remove special characters
    $ouDN = "OU=$dept,$BaseOU"
    $gpoName = "$dept GPO"

    try {
        # Create GPO if it doesn't exist
        $existingGPO = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
        if (-not $existingGPO) {
            New-GPO -Name $gpoName | Out-Null
            Write-Log "✅ Created GPO: '$gpoName'"
        } else {
            Write-Log "⚠️ GPO '$gpoName' already exists. Skipping creation."
        }

        # Link the GPO to the OU if not already linked
        $linked = Get-GPInheritance -Target $ouDN | Select-Object -ExpandProperty GpoLinks | Where-Object { $_.DisplayName -eq $gpoName }

        if (-not $linked) {
            New-GPLink -Name $gpoName -Target $ouDN -Enforced $false
            Write-Log "🔗 Linked GPO '$gpoName' to OU '$dept'"
        } else {
            Write-Log "🔁 GPO '$gpoName' already linked to '$dept'. Skipping link."
        }
    } catch {
        Write-Log "❌ Error processing '$dept': $_"
    }
}

Write-Log "✅ GPO automation completed for all departments."
Write-Output "Group Policy automation complete. Check log at: $LogFile"
