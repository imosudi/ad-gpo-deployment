<#
.SYNOPSIS
    Applies GPO for the Music & Library Mgt department.

.DESCRIPTION
    - Creates and links a Music_Library_Mgt GPO
    - Logs setup actions
    - Loads and lists required software for the department
#>

# ---------------- Configuration ----------------
$OU = "OU=Music & Library Mgt,OU=QuantumExpression,DC=quantumexpression,DC=net"
$GPOName = "Music_Library_Mgt_Policy"
$LogFile = "C:\scripts\logs\apply_music_library_gpo.log"
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

Write-Log "Starting GPO setup for Music & Library Mgt Department..."

Import-Module GroupPolicy -ErrorAction Stop

# Create the GPO if it doesn't exist
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    Write-Log "Creating GPO: $GPOName"
    New-GPO -Name $GPOName | Out-Null
} else {
    Write-Log "GPO already exists: $GPOName"
}

# Link GPO to the OU
try {
    New-GPLink -Name $GPOName -Target $OU -Enforced:$false -ErrorAction Stop
    Write-Log "GPO linked to $OU"
} catch {
    Write-Log "GPO link failed or already exists: $_"
}

# Import software list
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\common_software_lists.ps1"

Write-Log "Applying software requirements for Music & Library Mgt Department..."

foreach ($software in $MusicLibrarySoftware) {
    Write-Log "Expected software: $software"
    # Placeholder for future installation logic
}

Write-Log "Music & Library Mgt GPO setup completed."
Write-Output "✅ Music & Library Mgt Department GPO applied. See log at: $LogFile"
