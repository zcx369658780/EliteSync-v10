param([Parameter(Mandatory)][string]$ConfigPath)
$ErrorActionPreference = 'Stop'
$exe = Join-Path $env:SystemRoot 'System32\WindowsSandbox.exe'
$signature = Get-AuthenticodeSignature -LiteralPath $exe
if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notmatch 'Microsoft Windows') {
    throw 'Existing Sandbox signature qualification failed; do not install or replace it.'
}
if (Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue) {
    throw 'An existing Sandbox may belong to the user; do not replace or close it.'
}
if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) { throw 'Missing frozen configuration' }
$process = Start-Process -FilePath $exe -ArgumentList ('"' + $ConfigPath + '"') -WindowStyle Hidden -PassThru
[ordered]@{ pid=$process.Id; creationUtc=$process.StartTime.ToUniversalTime().ToString('o'); executable=$exe } | ConvertTo-Json -Compress
