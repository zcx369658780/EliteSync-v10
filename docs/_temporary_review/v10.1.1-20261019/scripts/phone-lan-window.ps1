$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $MyInvocation.MyCommand.Path
$taskPlan=Get-Content -LiteralPath (Join-Path $taskRoot 'secrets/phone-lan-plan.json') -Raw | ConvertFrom-Json
if ($taskPlan.rule_name -ne 'EliteSync-v1011-phone-udp-20261019-once' -or $taskPlan.udp_port -ne 7882 -or $taskPlan.seconds -ne 1200) { throw 'Unexpected window scope' }
if (-not (Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $taskPlan.interface_index | Where-Object IPAddress -eq $taskPlan.host_ipv4)) { throw 'Host address changed' }
if (Get-NetFirewallRule -Name $taskPlan.rule_name -ErrorAction SilentlyContinue) { throw 'Rule name already exists; preserve it' }
$taskStart=[DateTimeOffset]::UtcNow
try {
 New-NetFirewallRule -Name $taskPlan.rule_name -DisplayName $taskPlan.rule_name -Direction Inbound -Action Allow -Protocol UDP -LocalAddress $taskPlan.host_ipv4 -LocalPort 7882 -RemoteAddress $taskPlan.phone_ipv4 -Profile Any | Out-Null
 @{state='ACTIVE';started_utc=$taskStart.ToString('o');ends_utc=$taskStart.AddSeconds(1200).ToString('o');port=7882;scope='exact host and phone IPv4'} | ConvertTo-Json | Set-Content (Join-Path $taskRoot 'phone-lan-window-state.json')
 while ([DateTimeOffset]::UtcNow -lt $taskStart.AddSeconds(1200) -and -not (Test-Path -LiteralPath (Join-Path $taskRoot 'phone-lan-window-stop'))) { Start-Sleep -Seconds 1 }
} finally {
 Remove-NetFirewallRule -Name $taskPlan.rule_name -ErrorAction SilentlyContinue
 @{state='CLOSED';closed_utc=[DateTimeOffset]::UtcNow.ToString('o');rule_absent= -not [bool](Get-NetFirewallRule -Name $taskPlan.rule_name -ErrorAction SilentlyContinue)} | ConvertTo-Json | Set-Content (Join-Path $taskRoot 'phone-lan-window-final.json')
}
