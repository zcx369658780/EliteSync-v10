param([Parameter(Mandatory=$true)][string]$GradleHome)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '../../..')).Path
if (!(Test-Path -LiteralPath (Join-Path $GradleHome 'gradle.properties'))) {
    throw 'Supply a dedicated Gradle home with existing configured proxy and SDK settings; do not edit global settings.'
}
$env:GRADLE_USER_HOME = (Resolve-Path -LiteralPath $GradleHome).Path
$env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot'
$env:ANDROID_HOME = 'C:\Users\zcxve\AppData\Local\Android\Sdk'
$env:FLUTTER_STORAGE_BASE_URL = 'https://storage.googleapis.com'
Push-Location (Join-Path $repo 'apps/android')
try {
    & ./gradlew.bat assembleDebug '-PflutterDartDefines=ELITESYNC_V1008_LOCAL_BUILD=true' --console=plain
    if ($LASTEXITCODE -ne 0) { throw 'Local AAR/host build failed; retain stdout/stderr.' }
} finally { Pop-Location }
