#!/usr/bin/env python3
"""
Script de téléchargement et de vérification d'intégrité SHA-256 des modèles OCR.
"""

import hashlib
import json
import os
import sys
import urllib.request

MANIFEST_PATH = os.path.join(os.path.dirname(__file__), "..", "assets", "manifests", "models.json")
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "models")

def compute_sha256(filepath: str) -> str:
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest()

def verify_models():
    if not os.path.exists(MANIFEST_PATH):
        print(f"[!] Erreur: manifeste introuvable à '{MANIFEST_PATH}'")
        sys.exit(1)

    with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
        manifest = json.load(f)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    models = manifest.get("models", [])
    print(f"[*] Vérification de {len(models)} modèle(s) répertorié(s)...")

    for item in models:
        model_id = item["id"]
        filename = item["filename"]
        expected_sha = item["sha256"]
        target_path = os.path.join(OUTPUT_DIR, filename)

        if os.path.exists(target_path):
            actual_sha = compute_sha256(target_path)
            if actual_sha.lower() == expected_sha.lower():
                print(f"[OK] {model_id} ({filename}) - Intégrité vérifiée.")
            else:
                print(f"[WARN] {model_id} - Hash non correspondant: attendu {expected_sha}, calculé {actual_sha}")
        else:
            print(f"[-] {model_id} ({filename}) - Non téléchargé (mode offline / à la demande)")

if __name__ == "__main__":
    verify_models()
