param([switch]$Initialize, [string]$EvidenceDirectory)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$backend = Join-Path $repo 'services/backend-laravel'
if (!(Test-Path -LiteralPath (Join-Path $backend '.env'))) {
    throw 'Create the dedicated local .env using the execution report; never copy production .env.'
}
$text = Get-Content -LiteralPath (Join-Path $backend '.env') -Raw
foreach ($required in @('APP_ENV=local','DB_HOST=127.0.0.1','DB_PORT=43316','DB_DATABASE=elitesync_v1006_dev','APP_SESSION_DRIVER=database')) {
    if ($text -notmatch ('(?m)^'+[regex]::Escape($required)+'\r?$')) { throw "Dedicated configuration mismatch: $required" }
}
$label = docker inspect --format '{{index .Config.Labels "elitesync.version"}}' elitesync-v1006-db
if ($LASTEXITCODE -ne 0 -or $label -ne 'v10.0.6') { throw 'Dedicated database container identity mismatch.' }
docker start elitesync-v1006-db | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Database start failed.' }
for ($attempt=0; $attempt -lt 30; $attempt++) {
    docker exec elitesync-v1006-db healthcheck.sh --connect --innodb_initialized
    if ($LASTEXITCODE -eq 0) { break }
    Start-Sleep -Seconds 1
}
if ($LASTEXITCODE -ne 0) { throw 'Dedicated database did not become ready.' }
Push-Location $backend
try {
    New-Item -ItemType Directory -Force storage/framework/views,storage/framework/cache/data,storage/framework/sessions,storage/logs | Out-Null
    if ($Initialize) {
        php artisan migrate --force --no-interaction
        if ($LASTEXITCODE -ne 0) { throw 'Migration failed.' }
        php artisan db:seed --class=V1006DevelopmentSeeder --force --no-interaction
        if ($LASTEXITCODE -ne 0) { throw 'Development seed failed.' }
    }
    # A threaded loopback front prevents browser speculative connections from
    # blocking PHP's single worker on Windows. No business logic lives in it.
    $startArguments = @{
        FilePath='C:\tools\php85\php.exe'; ArgumentList=@('-S','127.0.0.1:8001','-t','public','public/index.php')
        WorkingDirectory=$backend; WindowStyle='Hidden'; PassThru=$true
    }
    if ($EvidenceDirectory) {
        if (Test-Path -LiteralPath $EvidenceDirectory) { throw 'Evidence directory already exists; use a fresh run path.' }
        New-Item -ItemType Directory -Path $EvidenceDirectory | Out-Null
        $startArguments.RedirectStandardOutput = Join-Path $EvidenceDirectory 'laravel.stdout'
        $startArguments.RedirectStandardError = Join-Path $EvidenceDirectory 'laravel.stderr'
    }
    $phpProcess = Start-Process @startArguments
    Write-Host "Owned Laravel PID: $($phpProcess.Id); loopback front: 8000; PHP backend: 8001"
    try {
        if ($EvidenceDirectory) {
            python (Join-Path $PSScriptRoot 'local-http-front.py') (Join-Path $EvidenceDirectory 'http-front.stderr')
        } else {
            python (Join-Path $PSScriptRoot 'local-http-front.py')
        }
    }
    finally { if (!$phpProcess.HasExited) { Stop-Process -Id $phpProcess.Id } }
} finally { Pop-Location }
