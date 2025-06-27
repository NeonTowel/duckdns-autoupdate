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

# Validate domain format
if ($domain -notmatch '^[a-zA-Z0-9.-]+\.duckdns\.org$') {
    Write-Error "Invalid domain format. Please provide a valid DuckDNS domain (e.g., 'example.duckdns.org')."
    exit 1
}

# Validate token
if ([string]::IsNullOrEmpty($token)) {
    Write-Error "Token must be provided as a parameter or environment variable (DUCKDNS_TOKEN)."
    exit 1
}

# Fetch current WAN IP
$currentIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

# DNS servers to try for resolution
$dnsServers = @("1.1.1.1", "8.8.8.8", "9.9.9.9", "208.67.222.222", "208.67.220.220", "4.2.2.1")

# Resolve the current IP for the domain
$dnsIP = ""
foreach ($server in $dnsServers) {
    Write-Output "$(Get-Date): INFO: Resolving $domain using $server..."
    try {
        $resolvedIPs = Resolve-DnsName -Name $domain -Type A -DnsOnly -Server $server -ErrorAction Stop | Select-Object -ExpandProperty IPAddress
        if ($resolvedIPs) {
            $dnsIP = $resolvedIPs | Select-Object -First 1
            if ($dnsIP -match '^(\d{1,3}\.){3}\d{1,3}$') {
                break # Successfully resolved to a valid IPv4
            }
        }
    }
    catch {
        Write-Output "$(Get-Date): INFO: Failed to resolve $domain using $server. Trying next..."
    }
}

# Compare and update if necessary
if ($dnsIP -eq $currentIP) {
    Write-Output "$(Get-Date): IP for $domain ($currentIP) is already up to date. No update performed."
}
else {
    Write-Output "$(Get-Date): IP for $domain is $dnsIP, current IP is $currentIP. Updating..."
    
    # DuckDNS expects only the subdomain part
    $subdomain = $domain.Replace(".duckdns.org", "")
    
    # Update DuckDNS
    $updateUrl = "https://www.duckdns.org/update?domains=$subdomain&token=$token&ip=$currentIP"
    $response = Invoke-WebRequest -Uri $updateUrl

    # Log results (optional)
    if ($response.Content -eq "OK") {
        Write-Output "$(Get-Date): IP updated to $currentIP"
    } else {
        Write-Output "$(Get-Date): Update failed. Response: $($response.Content)"
    }
}
