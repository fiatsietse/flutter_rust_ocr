import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_rust_ocr_example/main.dart';

void main() {
  testWidgets('Example app boots and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(const OcrDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter Rust OCR Demo'), findsOneWidget);
    expect(find.text('Image OCR'), findsOneWidget);
  });
}
