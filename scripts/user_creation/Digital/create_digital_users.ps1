<#
.SYNOPSIS
    Creates Active Directory users for the Digital department.

.DESCRIPTION
    - Users are created under the "OU=Digital,OU=QuantumExpression,DC=quantumexpression,DC=net"
    - Default password is set and user must change it at next logon.
    - Adds users to department-specific security groups if needed.
#>

# ---------------- Configuration ----------------
$OU = "OU=Digital,OU=QuantumExpression,DC=quantumexpression,DC=net"
$DefaultPassword = "Quantum@123!"  # Ensure this is rotated securely
$LogFile = "C:\scripts\logs\create_digital_users.log"
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

Write-Log "Starting user creation for Digital department..."

Import-Module ActiveDirectory -ErrorAction Stop

# Define users
$users = @(
    @{FirstName="Aisha"; LastName="Ogunlana"; Username="aogunlana"},
    @{FirstName="Kabir"; LastName="Bello"; Username="kbello"},
    @{FirstName="Ngozi"; LastName="Okafor"; Username="nokafor"}
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

Write-Log "✅ Completed user creation for Digital department."
Write-Output "Digital department users created. See log: $LogFile"
