param(
    [string]$domain,
    [string]$token
)

# Use environment variables as fallback
if ([string]::IsNullOrEmpty($domain)) {
    $domain = $env:DUCKDNS_DOMAIN
}
if ([string]::IsNullOrEmpty($token)) {
    $token = $env:DUCKDNS_TOKEN
}

if ([string]::IsNullOrEmpty($domain) -or [string]::IsNullOrEmpty($token)) {
    Write-Error "Domain and token must be provided as script parameters or environment variables (DUCKDNS_DOMAIN, DUCKDNS_TOKEN)."
    exit 1
}

# Fetch current WAN IP
$currentIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

# Get the first domain from the list to check against
$domainToCheck = $domain.Split(',')[0].Trim()

# Resolve the current IP for the domain
$dnsIP = ""
try {
    $resolvedIPs = Resolve-DnsName -Name $domainToCheck -Type A -DnsOnly -ErrorAction Stop | Select-Object -ExpandProperty IPAddress
    if ($resolvedIPs) {
        $dnsIP = $resolvedIPs[0]
    }
}
catch {
    Write-Warning "Could not resolve DNS for '$domainToCheck'. Proceeding with update."
}

# Compare and update if necessary
if ($dnsIP -eq $currentIP) {
    Write-Output "$(Get-Date): IP for $domainToCheck ($currentIP) is already up to date. No update performed."
}
else {
    Write-Output "$(Get-Date): IP for $domainToCheck is $dnsIP, current IP is $currentIP. Updating..."
    # Update DuckDNS
    $updateUrl = "https://www.duckdns.org/update?domains=$domain&token=$token&ip=$currentIP"
    $response = Invoke-WebRequest -Uri $updateUrl

    # Log results (optional)
    if ($response.Content -eq "OK") {
        Write-Output "$(Get-Date): IP updated to $currentIP"
    } else {
        Write-Output "$(Get-Date): Update failed. Response: $($response.Content)"
    }
}
