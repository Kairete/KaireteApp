# Build APK debug (PC con poca RAM: chiudi browser/Cursor extra prima di eseguire)
$ErrorActionPreference = "Stop"
$jdk = "C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"
if (-not (Test-Path $jdk)) {
  Write-Host "JDK 17 non trovato in $jdk"
  exit 1
}
$env:JAVA_HOME = $jdk
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
# PC con poca RAM: abbassate a -Xmx768m se serve
$env:GRADLE_OPTS = "-Xmx1024m"
$env:DART_VM_OPTIONS = "--old_gen_heap_size=512"

$flutter = "C:\Users\hp\flutter\bin\flutter.bat"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

& $flutter pub get
& $flutter build apk --debug --target-platform android-arm64

$apk = Join-Path $root "build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk"
if (-not (Test-Path $apk)) {
  $apk = Join-Path $root "build\app\outputs\flutter-apk\app-debug.apk"
}
if (Test-Path $apk) {
  $dest = Join-Path $root "Kairete-debug.apk"
  Copy-Item $apk $dest -Force
  Write-Host ""
  Write-Host "APK pronto:" -ForegroundColor Green
  Write-Host $dest
} else {
  Write-Host "Build fallita. Usa GitHub Actions (vedi BUILD_APK.md)." -ForegroundColor Red
  exit 1
}
