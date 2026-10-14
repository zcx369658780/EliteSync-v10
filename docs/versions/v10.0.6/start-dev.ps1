param([switch]$Initialize)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
$backend = Join-Path $repo 'services/backend-laravel'
if (!(Test-Path -LiteralPath (Join-Path $backend '.env'))) {
    throw 'Create the dedicated local .env using the execution report; never copy production .env.'
}
$text = Get-Content -LiteralPath (Join-Path $backend '.env') -Raw
foreach ($required in @('APP_ENV=local','DB_HOST=127.0.0.1','DB_PORT=43316','DB_DATABASE=elitesync_v1006_dev','SESSION_DRIVER=database')) {
    if ($text -notmatch ('(?m)^'+[regex]::Escape($required)+'\r?$')) { throw "Dedicated configuration mismatch: $required" }
}
$label = docker inspect --format '{{index .Config.Labels "elitesync.version"}}' elitesync-v1006-db
if ($LASTEXITCODE -ne 0 -or $label -ne 'v10.0.6') { throw 'Dedicated database container identity mismatch.' }
docker start elitesync-v1006-db | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Database start failed.' }
Push-Location $backend
try {
    New-Item -ItemType Directory -Force storage/framework/views,storage/framework/cache/data,storage/framework/sessions,storage/logs | Out-Null
    if ($Initialize) {
        php artisan migrate --force --no-interaction
        if ($LASTEXITCODE -ne 0) { throw 'Migration failed.' }
        php artisan db:seed --class=V1006DevelopmentSeeder --force --no-interaction
        if ($LASTEXITCODE -ne 0) { throw 'Development seed failed.' }
    }
    # Foreground local server; Ctrl-C stops this owned process only.
    php -S 127.0.0.1:8000 -t public public/index.php
} finally { Pop-Location }
