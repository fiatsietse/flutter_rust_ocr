#!/usr/bin/env bash
set -e

echo "====================================================="
echo " Compilation de flutter_rust_ocr pour Android (NDK)   "
echo "====================================================="

if ! command -v cargo &> /dev/null; then
    echo "Erreur: cargo n'a pas été trouvé dans le PATH."
    exit 1
fi

if ! command -v cargo-ndk &> /dev/null; then
    echo "cargo-ndk non trouvé. Installation..."
    cargo install cargo-ndk
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
RUST_DIR="$ROOT_DIR/rust"
JNI_DIR="$ROOT_DIR/android/src/main/jniLibs"

mkdir -p "$JNI_DIR/arm64-v8a"
mkdir -p "$JNI_DIR/x86_64"
mkdir -p "$JNI_DIR/armeabi-v7a"

cd "$RUST_DIR"

echo "-> Compilation x86_64 (Émulateur)..."
rustup target add x86_64-linux-android
cargo ndk -t x86_64 -o "$JNI_DIR" build --release

echo "-> Compilation arm64-v8a (Appareils physiques)..."
rustup target add aarch64-linux-android
cargo ndk -t arm64-v8a -o "$JNI_DIR" build --release

echo ""
echo "Compilation terminée avec succès dans : $JNI_DIR"
