import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prince_maker/jsonl.dart';
import 'package:prince_maker/ui_state_gallery.dart';

Future<Map<String, String>> loadLocale(String locale) async =>
    decodeJsonlCatalog(utf8.decode(
        (await rootBundle.load('story/locales/$locale.jsonl'))
            .buffer
            .asUint8List()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('named Canvas variants render the ko design evidence',
      (tester) async {
    final locale = await loadLocale('ko');
    await tester.pumpWidget(SizedBox(
        width: 760,
        height: 700,
        child: RepaintBoundary(
            key: const ValueKey('canvas-design-system-ko'),
            child: CustomPaint(
                painter: CanvasDesignSystemGalleryPainter(
                    (key, fallback) => locale[key] ?? fallback)))));
    await expectLater(find.byKey(const ValueKey('canvas-design-system-ko')),
        matchesGoldenFile('goldens/design-system-ko.png'));
  });

  testWidgets('named Canvas variants render the en design evidence',
      (tester) async {
    final locale = await loadLocale('en');
    await tester.pumpWidget(SizedBox(
        width: 760,
        height: 700,
        child: RepaintBoundary(
            key: const ValueKey('canvas-design-system-en'),
            child: CustomPaint(
                painter: CanvasDesignSystemGalleryPainter(
                    (key, fallback) => locale[key] ?? fallback)))));
    await expectLater(find.byKey(const ValueKey('canvas-design-system-en')),
        matchesGoldenFile('goldens/design-system-en.png'));
  });
}
