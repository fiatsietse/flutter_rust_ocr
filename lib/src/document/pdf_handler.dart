import '../configuration/ocr_config.dart';
import '../models/ocr_elements.dart';

class PdfDocumentHandler {
  /// Evaluates and selects the optimal OCR strategy for a given PDF page.
  static PdfOcrStrategy resolveStrategy({
    required PdfOcrStrategy requestedStrategy,
    required String? nativeText,
    required int imageResolutionDpi,
  }) {
    switch (requestedStrategy) {
      case PdfOcrStrategy.nativeTextOnly:
        return PdfOcrStrategy.nativeTextOnly;
      case PdfOcrStrategy.ocrOnly:
        return PdfOcrStrategy.ocrOnly;
      case PdfOcrStrategy.automatic:
        // Automatic heuristic: if valid high-density text is already present, use native
        if (nativeText != null && nativeText.trim().length > 30) {
          return PdfOcrStrategy.nativeTextOnly;
        }
        return PdfOcrStrategy.ocrOnly;
    }
  }

  /// Groups multi-page OCR results into a consolidated report.
  static String buildDocumentText(List<OcrResult> pageResults) {
    return pageResults
        .asMap()
        .entries
        .map((e) => '--- Page ${e.key + 1} ---\n${e.value.text}')
        .join('\n\n');
  }
}
