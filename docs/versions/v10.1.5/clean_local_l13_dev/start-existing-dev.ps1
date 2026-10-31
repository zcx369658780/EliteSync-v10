#requires -Version 7.0
param([Parameter(Mandatory)][string]$ConfigPath)
$ErrorActionPreference='Stop'
$c=Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
if($c.TaskId -ne 'V1015_CLEAN_LOCAL_L13_DEV_ENTRY_HOST_API_LEGACY_SESSION_20261031'){throw 'Task ownership mismatch'}
function Get-FrozenShape($x) {
 $ports=@(foreach($p in $x.HostConfig.PortBindings.psobject.Properties){foreach($z in @($p.Value)){if($null -ne $z){$p.Name+'|'+$z.HostIp+'|'+$z.HostPort}}})
 [ordered]@{
  Id=$x.Id; Image=$x.Image; User=$x.Config.User
  ReadonlyRootfs=[bool]$x.HostConfig.ReadonlyRootfs; Privileged=[bool]$x.HostConfig.Privileged
  CapDrop=@($x.HostConfig.CapDrop | Sort-Object)
  SecurityOpt=@($x.HostConfig.SecurityOpt | Sort-Object)
  NetworkMode=$x.HostConfig.NetworkMode
  Networks=@($x.NetworkSettings.Networks.psobject.Properties | Sort-Object Name | ForEach-Object {$_.Name+'|'+$_.Value.NetworkID})
  Mounts=@($x.Mounts | ForEach-Object {$_.Type+'|'+$_.Source+'|'+$_.Destination+'|'+$_.RW.ToString().ToLowerInvariant()} | Sort-Object)
  Ports=@($ports | Sort-Object)
 }
}
function Assert-FrozenContainer($x,$name,$c) {
 $expected=$c.FrozenContainers.$name
 if($null -eq $expected){throw 'No frozen identity for this resource'}
 $actual=Get-FrozenShape $x
 if(($actual | ConvertTo-Json -Depth 10 -Compress) -cne ($expected | ConvertTo-Json -Depth 10 -Compress)){throw 'Container ID/image/mount/network/port/security identity changed; review required'}
}

$d=$c.DockerExe
$s=Get-AuthenticodeSignature -LiteralPath $d
if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Docker Inc'){throw 'Docker signature qualification failed'}
if((Get-FileHash -LiteralPath $d -Algorithm SHA256).Hash -ne $c.DockerCliSha256){throw 'Docker CLI changed; obtain a new qualification before starting'}
$context=(& $d context inspect desktop-linux | ConvertFrom-Json)[0]
if($LASTEXITCODE -ne 0 -or $context.Endpoints.docker.Host -ne 'npipe:////./pipe/dockerDesktopLinuxEngine'){throw 'Only the already-running local Linux engine is allowed'}
$server=& $d --context desktop-linux version --format '{{.Server.Os}}'
if($LASTEXITCODE -ne 0 -or $server -ne 'linux'){throw 'Existing Linux engine unavailable; do not start/restart Desktop or WSL'}
$head=& git --no-optional-locks -c core.fsmonitor=false -C $c.DevRoot rev-parse HEAD
if($LASTEXITCODE -ne 0 -or $head -ne $c.SourceCommit){throw 'Source baseline changed'}
$dirty=& git --no-optional-locks -c core.fsmonitor=false -C $c.DevRoot status --porcelain=v1 --untracked-files=normal
if($LASTEXITCODE -ne 0 -or $dirty){throw 'Source is no longer clean; review changes before starting'}
foreach($name in @($c.DbContainer,$c.ApiContainer)){
 $x=(& $d --context desktop-linux inspect $name | ConvertFrom-Json)[0]
 Assert-FrozenContainer $x $name $c
 if($LASTEXITCODE -ne 0 -or $x.Config.Labels.'elitesync.task' -ne $c.TaskId -or -not $x.HostConfig.ReadonlyRootfs -or $x.HostConfig.Privileged -or $x.Config.User -notin @('999:999','10001:10001')){throw 'Container ownership/isolation mismatch'}
 if($x.State.Running){throw 'A task service is already running; do not implicitly restart it'}
 if($name -eq $c.DbContainer -and $x.HostConfig.PortBindings.psobject.Properties.Count -gt 0){throw 'DB must not publish a host port'}
 if($name -eq $c.ApiContainer){
  $binding=$x.HostConfig.PortBindings.'8080/tcp'
  if($binding.Count -ne 1 -or $binding[0].HostIp -ne '127.0.0.1' -or [int]$binding[0].HostPort -ne [int]$c.ApiPort){throw 'Loopback binding mismatch'}
 }
}
$front=(& $d --context desktop-linux network inspect $c.FrontendNetwork | ConvertFrom-Json)[0]
if($LASTEXITCODE -ne 0 -or $front.Labels.'elitesync.task' -ne $c.TaskId -or $front.Options.'com.docker.network.bridge.enable_ip_masquerade' -ne 'false'){throw 'Frontend network qualification changed'}
& $d --context desktop-linux start $c.DbContainer
if($LASTEXITCODE -ne 0){throw 'Private DB did not start'}
& $d --context desktop-linux start $c.ApiContainer
if($LASTEXITCODE -ne 0){& $d --context desktop-linux stop --time 15 $c.DbContainer;throw 'Private API did not start'}
$ok=$false
for($i=0;$i -lt 20;$i++){
 try{
  $r=Invoke-RestMethod -Uri ('http://127.0.0.1:'+ $c.ApiPort +'/api/v1/app/health') -NoProxy -TimeoutSec 3
  if($r.status -eq 'ok' -and $r.checks.database.ok){$ok=$true;break}
 }catch{}
 Start-Sleep -Seconds 2
}
if(-not $ok){
 & $d --context desktop-linux stop --time 15 $c.ApiContainer $c.DbContainer
 throw 'Loopback health not verified; own services stopped. Do not alter host firewall/Desktop/WSL.'
}
Write-Output ('Manual synthetic development API ready on http://127.0.0.1:'+ $c.ApiPort)
