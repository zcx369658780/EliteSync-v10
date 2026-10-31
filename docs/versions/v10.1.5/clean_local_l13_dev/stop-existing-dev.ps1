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
$context=(& $d context inspect desktop-linux | ConvertFrom-Json)[0]
if($LASTEXITCODE -ne 0 -or $context.Endpoints.docker.Host -ne 'npipe:////./pipe/dockerDesktopLinuxEngine'){throw 'Local Linux context mismatch'}
foreach($name in @($c.ApiContainer,$c.DbContainer)){
 $x=(& $d --context desktop-linux inspect $name | ConvertFrom-Json)[0]
 Assert-FrozenContainer $x $name $c
 if($LASTEXITCODE -ne 0 -or $x.Config.Labels.'elitesync.task' -ne $c.TaskId){throw 'Refusing to stop another resource'}
 if($x.State.Running){
  & $d --context desktop-linux stop --time 15 $name
  if($LASTEXITCODE -ne 0){throw 'A task service could not be stopped'}
 }
}
Write-Output 'Only the named task API and DB are stopped; no assets deleted.'
