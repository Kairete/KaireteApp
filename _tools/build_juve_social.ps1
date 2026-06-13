# Build APK Juve Social (sotto-app pilota tenant_id=3)
$ErrorActionPreference = "Stop"

$jdk = "C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"
if (-not (Test-Path $jdk)) {
    Write-Host "JDK 17 non trovato in $jdk"
    exit 1
}
$env:JAVA_HOME = $jdk
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
$env:GRADLE_OPTS = "-Xmx1024m"
$env:DART_VM_OPTIONS = "--old_gen_heap_size=512"

$flutter = "C:\Users\hp\flutter\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
    Write-Host "Flutter non trovato in $flutter"
    exit 1
}

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $root

$tenantId = if ($env:TENANT_ID) { $env:TENANT_ID } else { "3" }

Write-Host "Building Juve Social APK (tenant_id=$tenantId)..."

& $flutter pub get
& $flutter build apk --debug --flavor juveSocial --target-platform android-arm64 `
  --dart-define=APP_VARIANT=juve_social `
  --dart-define=TENANT_ID=$tenantId

$apkDir = Join-Path $root "build\app\outputs\flutter-apk"
$apk = Get-ChildItem $apkDir -Filter "*juve*debug*.apk" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $apk) {
    $apk = Get-ChildItem $apkDir -Filter "*debug*.apk" -ErrorAction SilentlyContinue | Select-Object -First 1
}
if (-not $apk) {
    Write-Host "Build fallita: nessun APK in $apkDir" -ForegroundColor Red
    exit 1
}

$destRoot = Join-Path $root "JuveSocial-debug.apk"
$destRelease = Join-Path $root "_release\JuveSocial-debug.apk"
New-Item -ItemType Directory -Force -Path (Split-Path $destRelease) | Out-Null
Copy-Item $apk.FullName $destRoot -Force
Copy-Item $apk.FullName $destRelease -Force

Write-Host ""
Write-Host "APK pronto:" -ForegroundColor Green
Write-Host $destRoot
Write-Host $destRelease
Write-Host "Package: com.kairete.tenant.juve_social"
