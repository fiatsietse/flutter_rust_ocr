import 'package:flutter/foundation.dart';

@immutable
class OcrPoint {
  final double x;
  final double y;

  const OcrPoint({required this.x, required this.y});

  factory OcrPoint.fromJson(Map<String, dynamic> json) {
    return OcrPoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  @override
  String toString() => 'OcrPoint($x, $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}

@immutable
class OcrBoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;

  const OcrBoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get left => x;
  double get top => y;
  double get right => x + width;
  double get bottom => y + height;

  factory OcrBoundingBox.fromJson(Map<String, dynamic> json) {
    return OcrBoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };

  @override
  String toString() => 'OcrBoundingBox(x: $x, y: $y, w: $width, h: $height)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OcrBoundingBox &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);
}

@immutable
class OcrPolygon {
  final List<OcrPoint> points;

  const OcrPolygon({required this.points});

  factory OcrPolygon.fromJson(dynamic json) {
    if (json is List) {
      return OcrPolygon(
        points: json
            .map((p) => OcrPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
    }
    return const OcrPolygon(points: []);
  }

  List<Map<String, dynamic>> toJson() => points.map((p) => p.toJson()).toList();

  @override
  String toString() => 'OcrPolygon(${points.length} points)';
}

@immutable
class OcrRegion {
  final double x;
  final double y;
  final double width;
  final double height;
  final bool isNormalized;

  const OcrRegion({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.isNormalized = false,
  });

  factory OcrRegion.fromJson(Map<String, dynamic> json) {
    return OcrRegion(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      isNormalized: json['isNormalized'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'isNormalized': isNormalized,
  };

  @override
  String toString() =>
      'OcrRegion(x: $x, y: $y, w: $width, h: $height, norm: $isNormalized)';
}
