$ErrorActionPreference='Stop'
$taskRoot=Split-Path -Parent $MyInvocation.MyCommand.Path
$taskPlan=Get-Content -LiteralPath (Join-Path $taskRoot 'secrets/phone-lan-plan.json') -Raw | ConvertFrom-Json
$taskState=Get-Content -LiteralPath (Join-Path $taskRoot 'phone-lan-window-state.json') -Raw | ConvertFrom-Json
if ([DateTimeOffset]::UtcNow -ge [DateTimeOffset]::Parse($taskState.ends_utc) -or (Test-Path -LiteralPath (Join-Path $taskRoot 'phone-lan-window-final.json'))) {throw 'Original window closed'}
$taskRule=Get-NetFirewallRule -Name 'EliteSync-v1011-phone-udp-20261019-once'
$taskRule | Get-NetFirewallAddressFilter | Set-NetFirewallAddressFilter -RemoteAddress @($taskPlan.phone_ipv4,$taskPlan.host_ipv4)
@{self_source_added=$true;original_deadline_unchanged=$true;time=[DateTimeOffset]::UtcNow.ToString('o')} | ConvertTo-Json | Set-Content (Join-Path $taskRoot 'phone-lan-self-amendment.json')
