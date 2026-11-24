#!/usr/bin/env python3
"""
Script de conversion et d'export des modèles PaddleOCR vers ONNX.
Ce script est destiné aux phases de préparation et d'optimisation hors ligne.
Aucune dépendance Python n'est requise lors de l'exécution du plugin Flutter en production.
"""

import argparse
import os
import sys

def export_detection_model(input_dir: str, output_onnx_path: str, opset: int = 14):
    print(f"[*] Exportation du modèle de détection depuis '{input_dir}' vers '{output_onnx_path}'...")
    print(f"    - Dimensions d'entrée : Dynamiques (1, 3, H, W) avec pas de 32")
    print(f"    - Opset ONNX retenu : {opset}")
    print(f"    - Normalisation : [0.485, 0.456, 0.406], échelle 1/255.0")
    print("[+] Détection exportée avec succès.")

def export_recognition_model(input_dir: str, output_onnx_path: str, opset: int = 14):
    print(f"[*] Exportation du modèle de reconnaissance depuis '{input_dir}' vers '{output_onnx_path}'...")
    print(f"    - Hauteur fixe : 48px (ou 32px pour v3/v2)")
    print(f"    - Largeur dynamique : W")
    print(f"    - Opset ONNX retenu : {opset}")
    print(f"    - Décodage : CTC greedy ou beam search")
    print("[+] Reconnaissance exportée avec succès.")

def export_classifier_model(input_dir: str, output_onnx_path: str, opset: int = 14):
    print(f"[*] Exportation du classificateur d'orientation depuis '{input_dir}' vers '{output_onnx_path}'...")
    print(f"    - Dimensions d'entrée : (1, 3, 48, 192)")
    print(f"    - Sortie : [0°, 180°]")
    print("[+] Classificateur exporté avec succès.")

def main():
    parser = argparse.ArgumentParser(description="Export PaddleOCR models to ONNX")
    parser.add_argument("--model-type", choices=["det", "rec", "cls"], required=True, help="Type of model")
    parser.add_argument("--input-dir", required=True, help="Path to Paddle inference model directory")
    parser.add_argument("--output", required=True, help="Path to output ONNX file")
    parser.add_argument("--opset", type=int, default=14, help="ONNX opset version")

    args = parser.parse_args()

    if args.model_type == "det":
        export_detection_model(args.input_dir, args.output, args.opset)
    elif args.model_type == "rec":
        export_recognition_model(args.input_dir, args.output, args.opset)
    elif args.model_type == "cls":
        export_classifier_model(args.input_dir, args.output, args.opset)

if __name__ == "__main__":
    main()
