param([Parameter(Mandatory=$true)][string]$EvidenceDirectory)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$backend=Join-Path $repo 'services/backend-laravel'
foreach($port in @(8000,8001)){
    if(Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue){throw "Port $port already owned; refusing to replace it"}
}
$label=docker inspect --format '{{index .Config.Labels "elitesync.version"}}' elitesync-v1007-db
if($LASTEXITCODE -ne 0 -or $label -ne 'v10.0.7'){throw 'Container identity mismatch'}
New-Item -ItemType Directory -Path $EvidenceDirectory -Force|Out-Null
$php=Start-Process -FilePath 'C:\tools\php85\php.exe' -ArgumentList @('-S','127.0.0.1:8001','-t','public','public/index.php') -WorkingDirectory $backend -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $EvidenceDirectory 'laravel.stdout') -RedirectStandardError (Join-Path $EvidenceDirectory 'laravel.stderr')
$front=Start-Process -FilePath (Get-Command python).Source -ArgumentList @((Join-Path $PSScriptRoot 'local-http-front.py'),(Join-Path $EvidenceDirectory 'front.stderr')) -WorkingDirectory $repo -WindowStyle Hidden -PassThru
@{php_pid=$php.Id;front_pid=$front.Id;database='elitesync_v1007_dev';front_port=8000;php_port=8001}|ConvertTo-Json|Set-Content -LiteralPath (Join-Path $EvidenceDirectory 'owned-processes.json') -Encoding utf8
Write-Output 'Owned V1007 loopback Laravel/front started; no seed performed.'
