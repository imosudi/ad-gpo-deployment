<#
.SYNOPSIS
    Creates Active Directory users for the Music & Library Management department.

.DESCRIPTION
    - Adds users to the "OU=Music & Library Mgt,OU=QuantumExpression,DC=quantumexpression,DC=net"
    - Enforces standard password and logging conventions.
#>

# ---------------- Configuration ----------------
$OU = "OU=Music & Library Mgt,OU=QuantumExpression,DC=quantumexpression,DC=net"
$DefaultPassword = "Quantum@123!"
$LogFile = "C:\scripts\logs\create_music_library_users.log"
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

Write-Log "Starting user creation for Music & Library Management..."

Import-Module ActiveDirectory -ErrorAction Stop

# Define users
$users = @(
    @{FirstName="Ngozi"; LastName="Umeh"; Username="numeh"},
    @{FirstName="Kolade"; LastName="Balogun"; Username="kbalogun"},
    @{FirstName="Fatima"; LastName="Bello"; Username="fbello"}
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

Write-Log "✅ Completed user creation for Music & Library Management."
Write-Output "Users created. Check log at: $LogFile"
