<#
.SYNOPSIS
    Automates assigning users from each OU to their respective AD security group.

.DESCRIPTION
    For each OU under QuantumExpression, this script:
    - Creates a security group if not present.
    - Adds users in the OU to the group (if not already members).
    - Logs changes made.

.NOTES
    Run this with Domain Admin privileges.
#>

# ------------------ Configuration ------------------
$BaseDN = "OU=QuantumExpression,DC=quantumexpression,DC=net"
$LogPath = "C:\scripts\logs\group_membership.log"

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
# ---------------------------------------------------

function Write-Log {
    param ($message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogPath -Value "$timestamp - $message"
}

# Create log directory if missing
$logDir = Split-Path $LogPath
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

Write-Log "🚀 Starting group membership automation..."

Import-Module ActiveDirectory

foreach ($dept in $Departments) {
    $sanitisedGroupName = $dept -replace '[^\w]', '_'
    $groupName = "${sanitisedGroupName}_Group"
    $ouDN = "OU=$dept,$BaseDN"

    try {
        # Ensure group exists
        if (-not (Get-ADGroup -Filter "Name -eq '$groupName'" -ErrorAction SilentlyContinue)) {
            New-ADGroup -Name $groupName -GroupScope Global -Path $ouDN -Description "$dept users group" -PassThru | Out-Null
            Write-Log "✅ Created group '$groupName'"
        }

        # Get all users in OU
        $users = Get-ADUser -Filter * -SearchBase $ouDN -SearchScope Subtree

        foreach ($user in $users) {
            $isMember = Get-ADGroupMember -Identity $groupName -Recursive | Where-Object { $_.DistinguishedName -eq $user.DistinguishedName }
            if (-not $isMember) {
                Add-ADGroupMember -Identity $groupName -Members $user
                Write-Log "➕ Added $($user.SamAccountName) to group '$groupName'"
            } else {
                Write-Log "⏩ $($user.SamAccountName) already in group '$groupName'"
            }
        }
    } catch {
        Write-Log "❌ Error processing '$dept': $_"
    }
}

Write-Log "✅ Group membership automation complete."
Write-Output "Group membership assignment complete. See log at $LogPath"
