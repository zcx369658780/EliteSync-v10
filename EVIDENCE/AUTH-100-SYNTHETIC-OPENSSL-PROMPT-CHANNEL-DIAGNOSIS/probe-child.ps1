param([ValidateSet('A', 'B', 'C')][string]$Mode)

$openssl = 'C:\Program Files\Git\usr\bin\openssl.exe'
$syntheticKey = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth100-synthetic\synthetic-encrypted-key.pem'
$ErrorActionPreference = if ($Mode -eq 'C') { 'Stop' } else { 'Continue' }

try {
    switch ($Mode) {
        'A' { & $openssl pkey -in $syntheticKey -noout }
        'B' { & $openssl pkey -in $syntheticKey -noout 2>$null }
        'C' { & $openssl pkey -in $syntheticKey -noout }
    }
    if ($LASTEXITCODE -eq 0) {
        Write-Output 'AUTH100_CHILD=EXIT_ZERO'
        exit 0
    }
    Write-Output 'AUTH100_CHILD=NATIVE_NONZERO'
    exit 10
} catch {
    Write-Output 'AUTH100_CHILD=CAUGHT'
    exit 11
}
