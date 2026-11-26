<#
.SYNOPSIS
    Compile the Rust OCR core for Android targets using cargo-ndk.
.DESCRIPTION
    Installs cargo-ndk if needed, adds Android rustup targets,
    compiles the crate into .so files, and copies them to android/src/main/jniLibs.
#>

param(
    [string]$Target = "all", # "all", "x86_64" (emulator), "arm64" (device)
    [string]$Profile = "release"
)

$ErrorActionPreference = "Stop"

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host " Compilation de flutter_rust_ocr pour Android (NDK)   " -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

# Check Rust
if (-not (Get-Command "cargo" -ErrorAction SilentlyContinue)) {
    Write-Error "Cargo n'a pas été trouvé dans le PATH. Veuillez installer Rust."
    exit 1
}

# Check or install cargo-ndk
if (-not (Get-Command "cargo-ndk" -ErrorAction SilentlyContinue)) {
    Write-Host "cargo-ndk n'est pas installé. Installation automatique..." -ForegroundColor Yellow
    cargo install cargo-ndk
}

$RootDir = (Resolve-Path "$PSScriptRoot\..").Path
$RustDir = Join-Path $RootDir "rust"
$JniLibsDir = Join-Path $RootDir "android\src\main\jniLibs"

# Ensure output directories exist
New-Item -ItemType Directory -Force -Path "$JniLibsDir\arm64-v8a" | Out-Null
New-Item -ItemType Directory -Force -Path "$JniLibsDir\x86_64" | Out-Null
New-Item -ItemType Directory -Force -Path "$JniLibsDir\armeabi-v7a" | Out-Null

Push-Location $RustDir
try {
    if ($Target -eq "all" -or $Target -eq "x86_64") {
        Write-Host "-> Compilation cible x86_64 (Émulateur Android)..." -ForegroundColor Green
        rustup target add x86_64-linux-android
        if ($Profile -eq "release") {
            cargo ndk -t x86_64 -o $JniLibsDir build --release
        } else {
            cargo ndk -t x86_64 -o $JniLibsDir build
        }
    }

    if ($Target -eq "all" -or $Target -eq "arm64") {
        Write-Host "-> Compilation cible arm64-v8a (Appareils physiques)..." -ForegroundColor Green
        rustup target add aarch64-linux-android
        if ($Profile -eq "release") {
            cargo ndk -t arm64-v8a -o $JniLibsDir build --release
        } else {
            cargo ndk -t arm64-v8a -o $JniLibsDir build
        }
    }

    Write-Host "`nSuccès ! Les bibliothèques .so ont été générées dans :" -ForegroundColor Green
    Write-Host "$JniLibsDir" -ForegroundColor White
} finally {
    Pop-Location
}
