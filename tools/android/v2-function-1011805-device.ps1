# Requires PowerShell 7. By default this checks the host only.
[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Apk,
    [Parameter(Mandatory)] [string] $PublicCertificate,
    [Parameter(Mandatory)] [string] $AndroidSdk,
    [string] $BuildToolsVersion = '36.0.0',
    [ValidateSet('Host', 'Reverse', 'Install')] [string] $Stage = 'Host',
    [string] $AuthorizedDeviceSerial,
    [string] $OwnerAuthorizationReference
)

$ErrorActionPreference = 'Stop'
$package = 'com.elitesync.v2functionp0'
$apkSha = 'd6064498bac327f40f2b2df9c5ed9664c819b29dfaffa916eaf6f6df7b649c05'
$signerSha = '9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09'
$tlsSha = '41e6411e5257d4986ab3d9a1b61d48abc739fb9f16055673a72e0fb02fe75f96'
$port = 'tcp:18444'

if ($Stage -ne 'Host' -and
    ($AuthorizedDeviceSerial -notmatch '^[A-Za-z0-9_-]+$' -or
     $AuthorizedDeviceSerial -like 'emulator-*' -or
     [string]::IsNullOrWhiteSpace($OwnerAuthorizationReference))) {
    throw 'Provide the explicitly authorized USB device serial and Owner authorization reference.'
}

$apkPath = (Resolve-Path -LiteralPath $Apk).ProviderPath
$certPath = (Resolve-Path -LiteralPath $PublicCertificate).ProviderPath
$buildTools = Join-Path $AndroidSdk "build-tools/$BuildToolsVersion"
$adb = Join-Path $AndroidSdk 'platform-tools/adb.exe'
if ((Get-FileHash -LiteralPath $apkPath).Hash -ne $apkSha) {
    throw 'Wrong APK SHA-256.'
}
$labels = & (Join-Path $buildTools 'aapt.exe') dump badging $apkPath
if ($LASTEXITCODE -ne 0 -or
    -not ($labels -match "^package: name='$([regex]::Escape($package))' versionCode='1011805'" ) -or
    -not ($labels -match "^native-code: 'arm64-v8a'$")) {
    throw 'Wrong APK package, version or ABI.'
}
$signature = & (Join-Path $buildTools 'apksigner.bat') verify --verbose --print-certs $apkPath
if ($LASTEXITCODE -ne 0 -or
    -not ($signature -match '^Verified using v2 scheme .*: true$') -or
    -not ($signature -match "^Signer #1 certificate SHA-256 digest: $signerSha$")) {
    throw 'Wrong APK signature.'
}
$cert = [System.Security.Cryptography.X509Certificates.X509Certificate2]::CreateFromPem(
    (Get-Content -LiteralPath $certPath -Raw)
)
try {
    if ($cert.GetCertHashString([System.Security.Cryptography.HashAlgorithmName]::SHA256) -ne $tlsSha) {
        throw 'Wrong trusted HTTPS certificate.'
    }
} finally {
    $cert.Dispose()
}
$status = & curl.exe --disable --noproxy '*' --proto '=https' --cacert $certPath --silent --show-error `
    --connect-timeout 4 --max-time 8 --output NUL --write-out '%{http_code}' `
    'https://127.0.0.1:18444/api/v1/profile/basic'
if ($LASTEXITCODE -ne 0 -or $status -ne '401') {
    throw 'Host HTTPS did not return the expected unauthenticated 401 under the fixed certificate.'
}
Write-Output "Host PASS $package 1011805, verified APK signature, pinned HTTPS 401."
if ($Stage -eq 'Host') {
    return
}

# These commands require genuine separate Owner authorization for this specific handset.
$transport = @('-s', $AuthorizedDeviceSerial)
$state = & $adb @transport get-state
if ($LASTEXITCODE -ne 0 -or $state -ne 'device') {
    throw 'The named phone is unavailable or USB debugging has not been approved.'
}
if ($Stage -eq 'Reverse') {
    & $adb @transport reverse --no-rebind $port $port
    if ($LASTEXITCODE -ne 0) { throw 'Reverse refused. Check the existing mapping without replacing it.' }
}
$mapping = & $adb @transport reverse --list
if ($LASTEXITCODE -ne 0 -or -not ($mapping -match '(?:^|\s)tcp:18444\s+tcp:18444(?:\s|$)')) {
    throw 'The named phone lacks the reviewed loopback mapping.'
}
if ($Stage -eq 'Install') {
    $existing = & $adb @transport shell pm path $package
    if ($existing -match '^package:') {
        throw 'The test package already exists. Preserve its data and review the installed version.'
    }
    & $adb @transport install $apkPath
    if ($LASTEXITCODE -ne 0) { throw 'Installation failed. Preserve the device and record the result.' }
}
