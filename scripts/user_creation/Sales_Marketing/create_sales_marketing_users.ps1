<#
.SYNOPSIS
    Creates Active Directory users for the Sales & Marketing department.

.DESCRIPTION
    - Adds users to the "OU=Sales & Marketing,OU=QuantumExpression,DC=quantumexpression,DC=net"
    - Applies consistent password policy, logging, and error handling.
#>

# ---------------- Configuration ----------------
$OU = "OU=Sales & Marketing,OU=QuantumExpression,DC=quantumexpression,DC=net"
$DefaultPassword = "Quantum@123!"
$LogFile = "C:\scripts\logs\create_sales_marketing_users.log"
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

Write-Log "Starting user creation for Sales & Marketing department..."

Import-Module ActiveDirectory -ErrorAction Stop

# Define users
$users = @(
    @{FirstName="Samuel"; LastName="Ibrahim"; Username="sibrahim"},
    @{FirstName="Tola"; LastName="Oseni"; Username="toseni"},
    @{FirstName="Fiona"; LastName="Obasi"; Username="fobasi"}
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

Write-Log "✅ Completed user creation for Sales & Marketing department."
Write-Output "Sales & Marketing users created. See log: $LogFile"
