# Check if running as Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

param(
    [string]$domain,
    [string]$token
)

# Define script path
$scriptDir = "C:\Scripts"
$scriptPath = Join-Path $scriptDir "Update-DuckDNS.ps1"

# Create directory if it does not exist
if (-NOT (Test-Path -Path $scriptDir)) {
    New-Item -ItemType Directory -Path $scriptDir | Out-Null
}

# Copy the script
Copy-Item -Path "Update-DuckDNS.ps1" -Destination $scriptPath -Force

# Define task parameters
$triggerStartup = New-ScheduledTaskTrigger -AtStartup
$triggerHourly = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 1) -RepetitionDuration ([System.TimeSpan]::MaxValue)

# Merge triggers
$trigger = @($triggerStartup, $triggerHourly)

# Create task action (runs script hidden)
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -File `"$scriptPath`" -domain `"$domain`" -token `"$token`""

# Register the task
Register-ScheduledTask -TaskName "DuckDNS_IP_Update" -Trigger $trigger -Action $action -RunLevel Highest -User "NT AUTHORITY\SYSTEM"
