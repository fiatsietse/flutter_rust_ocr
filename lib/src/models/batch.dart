import 'dart:async';
import 'package:flutter/foundation.dart';
import 'ocr_elements.dart';

@immutable
class OcrProgress {
  final int total;
  final int completed;
  final int failed;
  final String? currentItem;

  const OcrProgress({
    required this.total,
    required this.completed,
    this.failed = 0,
    this.currentItem,
  });

  double get percentage => total > 0 ? (completed + failed) / total : 0.0;

  @override
  String toString() =>
      'OcrProgress($completed/$total, failed: $failed, ${(percentage * 100).toStringAsFixed(1)}%)';
}

class OcrBatchTask {
  final Stream<OcrProgress> progress;
  final Future<List<OcrResult>> result;
  final void Function() _onCancel;

  OcrBatchTask({
    required this.progress,
    required this.result,
    required void Function() onCancel,
  }) : _onCancel = onCancel;

  void cancel() => _onCancel();
}
