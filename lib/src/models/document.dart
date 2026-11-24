import 'package:flutter/foundation.dart';
import 'geometry.dart';

@immutable
class DocumentFieldDefinition {
  final String name;
  final String type; // string, date, number, etc.
  final bool required;
  final List<String> labels;
  final String? pattern;
  final OcrRegion? region;

  const DocumentFieldDefinition({
    required this.name,
    this.type = 'string',
    this.required = false,
    this.labels = const [],
    this.pattern,
    this.region,
  });

  factory DocumentFieldDefinition.fromJson(Map<String, dynamic> json) {
    return DocumentFieldDefinition(
      name: json['name'] as String,
      type: json['type'] as String? ?? 'string',
      required: json['required'] as bool? ?? false,
      labels: (json['labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      pattern: json['pattern'] as String?,
      region: json['region'] != null
          ? OcrRegion.fromJson(json['region'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'required': required,
    'labels': labels,
    if (pattern != null) 'pattern': pattern,
    if (region != null) 'region': region!.toJson(),
  };
}

@immutable
class DocumentTemplate {
  final String id;
  final String version;
  final String name;
  final List<DocumentFieldDefinition> fields;

  const DocumentTemplate({
    required this.id,
    required this.version,
    required this.name,
    required this.fields,
  });

  factory DocumentTemplate.fromJson(Map<String, dynamic> json) {
    return DocumentTemplate(
      id: json['id'] as String,
      version: json['version'] as String? ?? '1.0',
      name: json['name'] as String? ?? '',
      fields: (json['fields'] as List<dynamic>)
          .map((f) => DocumentFieldDefinition.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'version': version,
    'name': name,
    'fields': fields.map((f) => f.toJson()).toList(),
  };
}

@immutable
class OcrExtractedField {
  final String name;
  final String rawValue;
  final dynamic normalizedValue;
  final double confidence;
  final OcrBoundingBox? boundingBox;
  final bool isValid;

  const OcrExtractedField({
    required this.name,
    required this.rawValue,
    this.normalizedValue,
    required this.confidence,
    this.boundingBox,
    this.isValid = true,
  });

  factory OcrExtractedField.fromJson(Map<String, dynamic> json) {
    return OcrExtractedField(
      name: json['name'] as String,
      rawValue: json['rawValue'] as String,
      normalizedValue: json['normalizedValue'],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      boundingBox: json['boundingBox'] != null
          ? OcrBoundingBox.fromJson(json['boundingBox'] as Map<String, dynamic>)
          : null,
      isValid: json['isValid'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'rawValue': rawValue,
    if (normalizedValue != null) 'normalizedValue': normalizedValue,
    'confidence': confidence,
    if (boundingBox != null) 'boundingBox': boundingBox!.toJson(),
    'isValid': isValid,
  };
}

@immutable
class OcrDocumentResult {
  final String templateId;
  final Map<String, OcrExtractedField> fields;
  final double overallConfidence;
  final bool isComplete;

  const OcrDocumentResult({
    required this.templateId,
    required this.fields,
    required this.overallConfidence,
    required this.isComplete,
  });

  factory OcrDocumentResult.fromJson(Map<String, dynamic> json) {
    final fieldsMap = <String, OcrExtractedField>{};
    if (json['fields'] is Map<String, dynamic>) {
      (json['fields'] as Map<String, dynamic>).forEach((k, v) {
        fieldsMap[k] = OcrExtractedField.fromJson(v as Map<String, dynamic>);
      });
    }
    return OcrDocumentResult(
      templateId: json['templateId'] as String? ?? '',
      fields: fieldsMap,
      overallConfidence: (json['overallConfidence'] as num?)?.toDouble() ?? 0.0,
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'templateId': templateId,
    'fields': fields.map((k, v) => MapEntry(k, v.toJson())),
    'overallConfidence': overallConfidence,
    'isComplete': isComplete,
  };
}
