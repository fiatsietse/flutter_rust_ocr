import 'package:flutter/foundation.dart';
import 'geometry.dart';

@immutable
class OcrCharacter {
  final String text;
  final double? confidence;
  final OcrBoundingBox? boundingBox;

  const OcrCharacter({
    required this.text,
    this.confidence,
    this.boundingBox,
  });

  factory OcrCharacter.fromJson(Map<String, dynamic> json) {
    return OcrCharacter(
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
      boundingBox: (json['boundingBox'] ?? json['bounding_box']) != null
          ? OcrBoundingBox.fromJson((json['boundingBox'] ?? json['bounding_box']) as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    if (confidence != null) 'confidence': confidence,
    if (boundingBox != null) 'boundingBox': boundingBox!.toJson(),
  };
}

@immutable
class OcrWord {
  final String text;
  final double? confidence;
  final OcrBoundingBox? boundingBox;
  final OcrPolygon? polygon;
  final List<OcrCharacter> characters;

  const OcrWord({
    required this.text,
    this.confidence,
    this.boundingBox,
    this.polygon,
    this.characters = const [],
  });

  factory OcrWord.fromJson(Map<String, dynamic> json) {
    return OcrWord(
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
      boundingBox: (json['boundingBox'] ?? json['bounding_box']) != null
          ? OcrBoundingBox.fromJson((json['boundingBox'] ?? json['bounding_box']) as Map<String, dynamic>)
          : null,
      polygon: json['polygon'] != null ? OcrPolygon.fromJson(json['polygon']) : null,
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => OcrCharacter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    if (confidence != null) 'confidence': confidence,
    if (boundingBox != null) 'boundingBox': boundingBox!.toJson(),
    if (polygon != null) 'polygon': polygon!.toJson(),
    if (characters.isNotEmpty)
      'characters': characters.map((c) => c.toJson()).toList(),
  };
}

@immutable
class OcrLine {
  final String text;
  final double? confidence;
  final OcrBoundingBox? boundingBox;
  final OcrPolygon? polygon;
  final List<OcrWord> words;

  const OcrLine({
    required this.text,
    this.confidence,
    this.boundingBox,
    this.polygon,
    this.words = const [],
  });

  factory OcrLine.fromJson(Map<String, dynamic> json) {
    return OcrLine(
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
      boundingBox: (json['boundingBox'] ?? json['bounding_box']) != null
          ? OcrBoundingBox.fromJson((json['boundingBox'] ?? json['bounding_box']) as Map<String, dynamic>)
          : null,
      polygon: json['polygon'] != null ? OcrPolygon.fromJson(json['polygon']) : null,
      words: (json['words'] as List<dynamic>?)
              ?.map((e) => OcrWord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    if (confidence != null) 'confidence': confidence,
    if (boundingBox != null) 'boundingBox': boundingBox!.toJson(),
    if (polygon != null) 'polygon': polygon!.toJson(),
    if (words.isNotEmpty) 'words': words.map((w) => w.toJson()).toList(),
  };
}

@immutable
class OcrParagraph {
  final String text;
  final double? confidence;
  final OcrBoundingBox? boundingBox;
  final List<OcrLine> lines;

  const OcrParagraph({
    required this.text,
    this.confidence,
    this.boundingBox,
    this.lines = const [],
  });

  factory OcrParagraph.fromJson(Map<String, dynamic> json) {
    return OcrParagraph(
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
      boundingBox: (json['boundingBox'] ?? json['bounding_box']) != null
          ? OcrBoundingBox.fromJson((json['boundingBox'] ?? json['bounding_box']) as Map<String, dynamic>)
          : null,
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => OcrLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    if (confidence != null) 'confidence': confidence,
    if (boundingBox != null) 'boundingBox': boundingBox!.toJson(),
    if (lines.isNotEmpty) 'lines': lines.map((l) => l.toJson()).toList(),
  };
}

@immutable
class OcrBlock {
  final String id;
  final String text;
  final double? confidence;
  final OcrBoundingBox? boundingBox;
  final OcrPolygon? polygon;
  final List<OcrLine> lines;
  final List<OcrParagraph> paragraphs;

  const OcrBlock({
    required this.id,
    required this.text,
    this.confidence,
    this.boundingBox,
    this.polygon,
    this.lines = const [],
    this.paragraphs = const [],
  });

  factory OcrBlock.fromJson(Map<String, dynamic> json) {
    return OcrBlock(
      id: json['id'] as String? ?? '',
      text: json['text'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
      boundingBox: (json['boundingBox'] ?? json['bounding_box']) != null
          ? OcrBoundingBox.fromJson((json['boundingBox'] ?? json['bounding_box']) as Map<String, dynamic>)
          : null,
      polygon: json['polygon'] != null ? OcrPolygon.fromJson(json['polygon']) : null,
      lines: (json['lines'] as List<dynamic>?)
              ?.map((e) => OcrLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      paragraphs: (json['paragraphs'] as List<dynamic>?)
              ?.map((e) => OcrParagraph.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    if (confidence != null) 'confidence': confidence,
    if (boundingBox != null) 'boundingBox': boundingBox!.toJson(),
    if (polygon != null) 'polygon': polygon!.toJson(),
    if (lines.isNotEmpty) 'lines': lines.map((l) => l.toJson()).toList(),
    if (paragraphs.isNotEmpty)
      'paragraphs': paragraphs.map((p) => p.toJson()).toList(),
  };
}

@immutable
class OcrPage {
  final int pageNumber;
  final int width;
  final int height;
  final String text;
  final List<OcrBlock> blocks;

  const OcrPage({
    required this.pageNumber,
    required this.width,
    required this.height,
    required this.text,
    this.blocks = const [],
  });

  factory OcrPage.fromJson(Map<String, dynamic> json) {
    return OcrPage(
      pageNumber: json['pageNumber'] as int? ?? 1,
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
      text: json['text'] as String? ?? '',
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) => OcrBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'width': width,
    'height': height,
    'text': text,
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };
}

@immutable
class OcrResult {
  final String text;
  final double? confidence;
  final int processingTimeMs;
  final int imageWidth;
  final int imageHeight;
  final List<OcrBlock> blocks;
  final List<OcrPage> pages;

  const OcrResult({
    required this.text,
    this.confidence,
    required this.processingTimeMs,
    required this.imageWidth,
    required this.imageHeight,
    this.blocks = const [],
    this.pages = const [],
  });

  Duration get processingTime => Duration(milliseconds: processingTimeMs);

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      text: json['text'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble(),
      processingTimeMs: (json['processingTimeMs'] ?? json['processing_time_ms']) as int? ?? 0,
      imageWidth: (json['imageWidth'] ?? json['image_width']) as int? ?? 0,
      imageHeight: (json['imageHeight'] ?? json['image_height']) as int? ?? 0,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((e) => OcrBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pages: (json['pages'] as List<dynamic>?)
              ?.map((e) => OcrPage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    if (confidence != null) 'confidence': confidence,
    'processingTimeMs': processingTimeMs,
    'imageWidth': imageWidth,
    'imageHeight': imageHeight,
    'blocks': blocks.map((b) => b.toJson()).toList(),
    if (pages.isNotEmpty) 'pages': pages.map((p) => p.toJson()).toList(),
  };
}
