<#
.SYNOPSIS
    Creates Active Directory users for the PR & Image Control department.

.DESCRIPTION
    - Users are provisioned in "OU=PR & Image Control,OU=QuantumExpression,DC=quantumexpression,DC=net"
    - Includes basic logging, UPN setup, and change-password-on-logon enforcement.
#>

# ---------------- Configuration ----------------
$OU = "OU=PR & Image Control,OU=QuantumExpression,DC=quantumexpression,DC=net"
$DefaultPassword = "Quantum@123!"
$LogFile = "C:\scripts\logs\create_pr_image_control_users.log"
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

Write-Log "Starting user creation for PR & Image Control department..."

Import-Module ActiveDirectory -ErrorAction Stop

# Define users
$users = @(
    @{FirstName="Halima"; LastName="Umar"; Username="humar"},
    @{FirstName="Tunde"; LastName="Adebayo"; Username="tadebayo"},
    @{FirstName="Chinwe"; LastName="Nwankwo"; Username="cnwankwo"}
)

foreach ($user in $users) {
    $samAccountName = $user.Username
    $displayName = "$($user.FirstName) $($user.LastName)"
    $userPrincipalName = "$samAccountName@quantumexpression.net"

    if (-not (Get-ADUser -Filter {SamAccountName -eq $samAccountName} -ErrorAction SilentlyContinue)) {
        try {
            New-ADUser `
                -Name $displayName `
                -GivenName $user.FirstName `
                -Surname $user.LastName `
                -SamAccountName $samAccountName `
                -UserPrincipalName $userPrincipalName `
                -AccountPassword (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force) `
                -Path $OU `
                -Enabled $true `
                -ChangePasswordAtLogon $true

            Write-Log "✅ Created user: $displayName ($samAccountName)"
        } catch {
            Write-Log "❌ Failed to create user $samAccountName: $_"
        }
    } else {
        Write-Log "⚠️ User $samAccountName already exists. Skipping..."
    }
}

Write-Log "✅ Completed user creation for PR & Image Control department."
Write-Output "PR & Image Control users created. See log: $LogFile"
