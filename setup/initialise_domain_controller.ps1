<#
.SYNOPSIS
    Initialises a new Windows Server as the first Domain Controller in a new AD forest.

.DESCRIPTION
    - Installs necessary roles (AD DS, DNS)
    - Promotes the server to a Domain Controller
    - Creates a new forest and root domain
    - Configures basic DNS forwarding
    - Writes log entries to C:\scripts\logs\initialise_domain_controller.log

.NOTES
    Ensure you run this script with elevated privileges.
#>

# ------------------------- Configuration -------------------------
$domainName     = "quantumexpression.net"
$netbiosName    = "QUANTUMEXPRESSION"
$safeModePwd    = ConvertTo-SecureString "Str0ngP@ssw0rd!" -AsPlainText -Force
$logPath        = "C:\scripts\logs\initialise_domain_controller.log"
$dnsForwarder   = @("8.8.8.8", "4.2.2.2", "4.2.2.6") #"8.8.8.8"
# -----------------------------------------------------------------

function Write-Log {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logPath -Value "$timestamp - $message"
}

# Create log directory if not exists
$logDir = Split-Path -Path $logPath
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

Write-Log "---- Domain Controller Initialisation Started ----"

# Step 1: Install AD DS and DNS roles
Write-Log "Installing AD-Domain-Services and DNS roles..."
Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools -ErrorAction Stop
Write-Log "Role installation complete."

# Step 2: Promote server to Domain Controller
Write-Log "Promoting server to Domain Controller for domain: $domainName..."

Install-ADDSForest `
    -DomainName $domainName `
    -DomainNetbiosName $netbiosName `
    -SafeModeAdministratorPassword $safeModePwd `
    -InstallDns `
    -Force `
    -ErrorAction Stop

Write-Log "Domain Controller promotion command issued. Server will reboot."

# Optional: Add DNS forwarder
Register-ObjectEvent -InputObject $global:ExecutionContext.InvokeCommand `
    -EventName 'OnScriptEnd' `
    -Action {
        Start-Sleep -Seconds 10
        Write-Log "Post-reboot: Configuring DNS forwarder to $dnsForwarder"
        Set-DnsServerForwarder -IPAddress $dnsForwarder -PassThru | Out-Null
        Write-Log "DNS forwarder configured."
    }

Write-Log "---- Script completed. Awaiting reboot... ----"
