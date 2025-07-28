<#
.SYNOPSIS
    Creates system and service accounts under the Service Accounts OU.

.DESCRIPTION
    - Targets OU: "OU=Service Accounts,OU=QuantumExpression,DC=quantumexpression,DC=net"
    - These are typically non-human accounts used by applications, services, and scheduled tasks.
#>

# ---------------- Configuration ----------------
$OU = "OU=Service Accounts,OU=QuantumExpression,DC=quantumexpression,DC=net"
$DefaultPassword = "QuantumSvc@123!"
$LogFile = "C:\scripts\logs\create_service_accounts_users.log"
# ------------------------------------------------

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

Write-Log "🔧 Starting creation of service accounts..."

Import-Module ActiveDirectory -ErrorAction Stop

# Define service accounts
$accounts = @(
    @{Name="svcBackup"; Description="Backup Service Account"},
    @{Name="svcMonitoring"; Description="Monitoring Agent Account"},
    @{Name="svcWSUS"; Description="Windows Server Update Services Account"},
    @{Name="svcIISApp"; Description="IIS Application Pool Identity"},
    @{Name="svcSQLJobs"; Description="SQL Server Jobs Runner"}
)

foreach ($account in $accounts) {
    $samAccountName = $account.Name
    $userPrincipalName = "$samAccountName@quantumexpression.net"

    if (-not (Get-ADUser -Filter {SamAccountName -eq $samAccountName} -ErrorAction SilentlyContinue)) {
        try {
            New-ADUser `
                -Name $samAccountName `
                -SamAccountName $samAccountName `
                -UserPrincipalName $userPrincipalName `
                -Description $account.Description `
                -AccountPassword (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force) `
                -Path $OU `
                -Enabled $true `
                -PasswordNeverExpires $true `
                -CannotChangePassword $true

            Write-Log "✅ Created service account: $samAccountName"
        } catch {
            Write-Log "❌ Failed to create service account $samAccountName: $_"
        }
    } else {
        Write-Log "⚠️ Service account $samAccountName already exists. Skipping..."
    }
}

Write-Log "✅ Completed creation of all service accounts."
Write-Output "Service accounts created. Check log at: $LogFile"
