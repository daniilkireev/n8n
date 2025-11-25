# wsl_portproxy_8787.ps1
# Run from elevated PowerShell (Run as Administrator)

$port = 8787
$listenAddress = "0.0.0.0"
$firewallRuleName = "WSL_8787"

Write-Host "=== Configure WSL portproxy for port $port ==="

# 1. Ensure IP Helper service is running
Write-Host "Checking IP Helper service (iphlpsvc)..." 
$service = Get-Service iphlpsvc -ErrorAction Stop
if ($service.Status -ne 'Running') {
    Write-Host "Starting iphlpsvc..."
    Start-Service iphlpsvc
}
Write-Host "iphlpsvc status: $($service.Status)"

# 2. Get WSL IP (eth0)
Write-Host "Getting WSL IP from eth0..."
$wslIp = wsl.exe ip -4 addr show eth0 |
    Select-String -Pattern "inet " |
    ForEach-Object {
        ($_ -split "\s+")[2].Split("/")[0]
    } |
    Select-Object -First 1

if (-not $wslIp) {
    Write-Host "ERROR: Cannot get WSL IP. Make sure WSL distro is running." -ForegroundColor Red
    exit 1
}

Write-Host "WSL IP detected: $wslIp"

# 3. Delete old portproxy rule (if any)
Write-Host "Deleting old portproxy rule (if exists)..." 
netsh interface portproxy delete v4tov4 listenaddress=$listenAddress listenport=$port | Out-Null

# 4. Create new portproxy rule
Write-Host ("Creating portproxy rule {0}:{1} -> {2}:{1}" -f $listenAddress, $port, $wslIp)
netsh interface portproxy add v4tov4 listenaddress=$listenAddress listenport=$port connectaddress=$wslIp connectport=$port

Write-Host "Current portproxy rules:"
netsh interface portproxy show v4tov4

# 5. Recreate firewall rule
Write-Host "Recreating firewall rule $firewallRuleName ..." 
Remove-NetFirewallRule -DisplayName $firewallRuleName -ErrorAction SilentlyContinue

New-NetFirewallRule `
    -DisplayName $firewallRuleName `
    -Direction Inbound `
    -LocalPort $port `
    -Protocol TCP `
    -Action Allow `
    -Profile Any `
    -RemoteAddress Any | Out-Null

Write-Host "Firewall rule state:"
Get-NetFirewallRule -DisplayName $firewallRuleName | Format-List DisplayName,Enabled,Direction,Action,Profile

Write-Host "=== Done. Test from other machine: http://<Windows_IP>:$port ==="
